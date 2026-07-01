import 'package:flutter/material.dart';
import 'workout_screen.dart';
import 'exercise_log_screen.dart';
import 'package:fitmeadi/providers/workout_provider.dart';
import 'package:fitmeadi/exerciselist.dart';

const List<String> _monthNames = [
  'January', 'February', 'March', 'April', 'May', 'June',
  'July', 'August', 'September', 'October', 'November', 'December'
];
const List<String> _dayLetters = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late DateTime selectedDate;
  late DateTime weekStart;

  @override
  void initState() {
    super.initState();
    selectedDate = DateTime.now();
    weekStart = _mondayOf(selectedDate);
  }

  // Finds the Monday of whatever week `date` falls in.
  // DateTime.weekday is 1 (Monday) through 7 (Sunday).
  DateTime _mondayOf(DateTime date) {
    final cleanDate = DateTime(date.year, date.month, date.day);
    return cleanDate.subtract(Duration(days: cleanDate.weekday - 1));
  }

  void _previousWeek() {
    setState(() => weekStart = weekStart.subtract(const Duration(days: 7)));
  }

  void _nextWeek() {
    setState(() => weekStart = weekStart.add(const Duration(days: 7)));
  }

  void _selectDate(DateTime date) {
    setState(() => selectedDate = date);
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

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
        title: const Text('Home'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Month label + week navigation arrows
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
                    IconButton(
                      icon: const Icon(Icons.chevron_left),
                      onPressed: _previousWeek,
                    ),
                    IconButton(
                      icon: const Icon(Icons.chevron_right),
                      onPressed: _nextWeek,
                    ),
                  ],
                ),
              ],
            ),
          ),

          // The week strip itself: 7 tappable day boxes
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(7, (index) {
                final date = weekStart.add(Duration(days: index));
                final isSelected = _isSameDay(date, selectedDate);

                return GestureDetector(
                  onTap: () => _selectDate(date),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? colorScheme.primary
                          : colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        Text(
                          _dayLetters[index],
                          style: TextStyle(
                            color: isSelected ? colorScheme.onPrimary : colorScheme.onSurface,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${date.day}',
                          style: TextStyle(
                            color: isSelected ? colorScheme.onPrimary : colorScheme.onSurface,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),

          const SizedBox(height: 16),

          // Exercises logged on whichever day is currently selected
          Expanded(
            child: entriesForSelectedDate.isEmpty
                ? Center(
                    child: Text(
                      "No workouts logged on this day",
                      style: textTheme.titleMedium,
                    ),
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
      floatingActionButton: FloatingActionButton(
        shape: const CircleBorder(),
        elevation: 6,
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const WorkoutScreen()),
          );
          setState(() {});
        },
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        elevation: 8,
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        child: const SizedBox(height: 65),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}