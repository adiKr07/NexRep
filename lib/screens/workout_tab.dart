import 'package:flutter/material.dart';
import 'package:fitmeadi/providers/workout_provider.dart';
import 'package:fitmeadi/exerciselist.dart';
import 'exercise_log_screen.dart';
import 'workout_screen.dart';

const List<String> _monthNames = [
  'January', 'February', 'March', 'April', 'May', 'June',
  'July', 'August', 'September', 'October', 'November', 'December'
];
const List<String> _dayLetters = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

class WorkoutTab extends StatefulWidget {
  const WorkoutTab({super.key});

  @override
  State<WorkoutTab> createState() => _WorkoutTabState();
}

class _WorkoutTabState extends State<WorkoutTab> {
  late DateTime selectedDate;
  late DateTime weekStart;

  @override
  void initState() {
    super.initState();
    selectedDate = DateTime.now();
    weekStart = _mondayOf(selectedDate);
  }

  DateTime _mondayOf(DateTime date) {
    final cleanDate = DateTime(date.year, date.month, date.day);
    return cleanDate.subtract(Duration(days: cleanDate.weekday - 1));
  }

  void _previousWeek() => setState(() => weekStart = weekStart.subtract(const Duration(days: 7)));
  void _nextWeek() => setState(() => weekStart = weekStart.add(const Duration(days: 7)));
  void _selectDate(DateTime date) => setState(() => selectedDate = date);

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  Future<void> _openFullCalendar() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        selectedDate = picked;
        weekStart = _mondayOf(picked);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    final entriesForSelectedDate = workoutManager
        .getWorkoutsForDate(selectedDate)
        .expand((w) => w.exercises)
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Workout'),
        centerTitle: true,
        // backgroundColor: Colors.black,
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_month),
            onPressed: _openFullCalendar,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: ElevatedButton.icon(
              icon: const Icon(Icons.add),
              label: const Text('Log New Workout'),
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const WorkoutScreen()),
                );
                setState(() {});
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${_monthNames[weekStart.month - 1]} ${weekStart.year}',
                  style: textTheme.titleMedium,
                ),
                Row(
                  children: [
                    IconButton(icon: const Icon(Icons.chevron_left), onPressed: _previousWeek),
                    IconButton(icon: const Icon(Icons.chevron_right), onPressed: _nextWeek),
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
            child: Container(
              height: 56,
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: List.generate(7, (index) {
                  final date = weekStart.add(Duration(days: index));
                  final isSelected = _isSameDay(date, selectedDate);

                  return Expanded(
                    child: GestureDetector(
                      onTap: () => _selectDate(date),
                      behavior: HitTestBehavior.opaque,
                      child: Center(
                        child: AnimatedSlide(
                          duration: const Duration(milliseconds: 250),
                          curve: Curves.easeInOut,
                          offset: isSelected ? const Offset(0, -0.2) : Offset.zero,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            curve: Curves.easeInOut,
                            width: isSelected ? 48 : 40,
                            height: isSelected ? 70 : 40,
                            decoration: BoxDecoration(
                              color: isSelected ? colorScheme.primary : Colors.transparent,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: isSelected
                                  ? [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.3),
                                        blurRadius: 8,
                                        offset: const Offset(0, 4),
                                      ),
                                    ]
                                  : [],
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                AnimatedDefaultTextStyle(
                                  duration: const Duration(milliseconds: 250),
                                  style: TextStyle(
                                    color: isSelected
                                        ? colorScheme.onPrimary
                                        : colorScheme.onSurface.withOpacity(0.6),
                                    fontSize: 12,
                                  ),
                                  child: Text(_dayLetters[index]),
                                ),
                                const SizedBox(height: 4),
                                AnimatedDefaultTextStyle(
                                  duration: const Duration(milliseconds: 250),
                                  style: TextStyle(
                                    color: isSelected ? colorScheme.onPrimary : colorScheme.onSurface,
                                    fontWeight: FontWeight.bold,
                                    fontSize: isSelected ? 16 : 15,
                                  ),
                                  child: Text('${date.day}'),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),
          const SizedBox(height: 28),
          Expanded(
            child: entriesForSelectedDate.isEmpty
                ? Center(
                    child: Text("No workouts logged on this day", style: textTheme.titleMedium),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: entriesForSelectedDate.length,
                    itemBuilder: (context, index) {
                      final entry = entriesForSelectedDate[index];
                      return Card(
                        key: ValueKey(entry),
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          title: Text(entry.exerciseName),
                          subtitle: Text('${entry.sets.length} sets'),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ExerciseLogScreen(
                                  exercise: Exerciselist(label: entry.exerciseName, imagePath: eachMuscleExercises.entries
                                      .firstWhere((e) => e.value.any((ex) => ex.label == entry.exerciseName))
                                      .value
                                      .firstWhere((ex) => ex.label == entry.exerciseName)
                                      .imagePath),
                                  existingEntry: entry,
                                ),
                              ),
                            );
                            setState(() {});
                          },
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}