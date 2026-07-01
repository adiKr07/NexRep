import 'package:flutter/material.dart';
import 'package:fitmeadi/providers/workout_provider.dart';
import 'package:fitmeadi/exerciselist.dart';
import 'exercise_log_screen.dart';

class HistoryScreen extends StatefulWidget {
  final DateTime date;
  const HistoryScreen({super.key, required this.date});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final entries = workoutManager
        .getWorkoutsForDate(widget.date)
        .expand((w) => w.exercises)
        .toList();

    return Scaffold(
      appBar: AppBar(title: const Text("Workout History"), centerTitle: true),
      body: entries.isEmpty
          ? const Center(child: Text("No workout on this date"))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: entries.length,
              itemBuilder: (context, index) {
                final entry = entries[index];
                return Card(
                  key: ValueKey(entry),
                  margin: const EdgeInsets.only(bottom: 16),
                  child: ListTile(
                    title: Text(entry.exerciseName, style: textTheme.titleMedium),
                    subtitle: Text(entry.sets.map((s) => '${s.reps}×${s.weight}kg').join(', ')),
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
    );
  }
}