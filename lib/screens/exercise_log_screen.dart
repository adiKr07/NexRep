import 'package:flutter/material.dart';
import '../exerciselist.dart';
import 'package:fitmeadi/providers/workout_provider.dart';
import 'package:fitmeadi/models/workout_mod.dart';
import '../theme/app_colors.dart';

class ExerciseLogScreen extends StatefulWidget {
  final Exerciselist exercise;
  final ExerciseEntry? existingEntry;

  const ExerciseLogScreen({
    super.key,
    required this.exercise,
    this.existingEntry,
  });

  @override
  State<ExerciseLogScreen> createState() => _ExerciseLogScreenState();
}

class _ExerciseLogScreenState extends State<ExerciseLogScreen> {
  ExerciseEntry? entry;

  @override
  void initState() {
    super.initState();
    entry = widget.existingEntry;
  }

  List<WorkoutSet> get sets => entry?.sets ?? [];

  // Future<void> _save() async {
  //   if (widget.existingEntry != null) {
  //     await workoutManager.updateEntrySets(widget.existingEntry!, sets);
  //   } else {
  //     await workoutManager.logExercise(widget.exercise.label, sets);
  //   }
  //   if (mounted) Navigator.pop(context);
  // }

  Future<void> _deleteEntireEntry() async {
    if (widget.existingEntry != null) {
      await workoutManager.removeEntry(widget.existingEntry!);
      if (mounted) Navigator.pop(context);
    }
  }
  
  
  Future<bool> _showSetDialog(WorkoutSet set) async {
    int reps = set.reps;
    double weight = set.weight;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Set Details'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _DialogCounter(
                    label: 'Reps',
                    value: reps,
                    onIncrement: () => setDialogState(() => reps++),
                    onDecrement: () => setDialogState(() {
                      if (reps > 0) reps--;
                    }),
                  ),
                  const SizedBox(height: 16),
                  _DialogCounter(
                    label: 'Weight',
                    value: weight,
                    onIncrement: () => setDialogState(() => weight += 2.5),
                    onDecrement: () => setDialogState(() {
                      if (weight > 0) weight -= 2.5;
                    }),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );

    if (confirmed == true) {
      set.reps = reps;
      set.weight = weight;
      return true;
    }
    return false;
  }

  Future<void> _addSet() async {
    final newSet = WorkoutSet();
    final confirmed = await _showSetDialog(newSet);
    if (confirmed && newSet.reps > 0 && newSet.weight > 0) {
      entry =  await workoutManager.addSetToExercise(widget.exercise.label,entry,newSet);
      setState(() {});
    }
  }

  Future<void> _editSet(int index) async {
    final originalReps = sets[index].reps;
    final originalWeight = sets[index].weight;

    final confirmed = await _showSetDialog(sets[index]);

    if (confirmed && sets[index].reps > 0 && sets[index].weight > 0) {
        await workoutManager.saveWorkouts();
        setState(() {});
    } else if (confirmed) {
        sets[index].reps = originalReps;
        sets[index].weight = originalWeight;
        ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Reps and weight must be greater than 0')),
        );
    }
}

  Future<void> _deleteSet(int index) async {
    await workoutManager.deleteSet(entry!, sets[index]);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final maxRepsPerWeight = workoutManager.getMaxRepsPerWeight(widget.exercise.label);
    
    return Scaffold(
      appBar: AppBar(
        // backgroundColor: Colors.black,
        title: Text(widget.exercise.label),
        actions: [
          if (widget.existingEntry != null)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: _deleteEntireEntry,
            ),
        ],
      ),
      body: sets.isEmpty
          ? Center(
              child: ElevatedButton(
                onPressed: _addSet,
                child: const Text('Add Set'),
              ),
            )
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      itemCount: sets.length,
                      itemBuilder: (context, index) {
                        final currentSet = sets[index];
                        final bestRepsForThisWeight = maxRepsPerWeight[currentSet.weight] ?? 0;
                        final isPR = currentSet.reps > 0 && currentSet.reps == bestRepsForThisWeight;
                        return Card(
                          color: AppColors.surface,
                          margin: const EdgeInsets.only(bottom: 12),
                          child: ListTile(
                            title: Text('Set ${index + 1}'),
                            subtitle: Text(
                              '${sets[index].reps} reps × ${sets[index].weight} kg${isPR ? ' 🏆' : ''}',
                            ),
                            trailing: PopupMenuButton<String>(
                              onSelected: (value) {
                                if (value == 'edit') _editSet(index);
                                if (value == 'delete') _deleteSet(index);
                              },
                              itemBuilder: (context) => [
                                const PopupMenuItem(value: 'edit', child: Text('Edit')),
                                const PopupMenuItem(value: 'delete', child: Text('Delete')),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  ElevatedButton(onPressed: _addSet, child: const Text('Add Set')),
                ],
              ),
            ),
    );
  }
}

class _DialogCounter extends StatelessWidget {
  final String label;
  final num value;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

  const _DialogCounter({
    required this.label,
    required this.value,
    required this.onIncrement,
    required this.onDecrement,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(icon: const Icon(Icons.remove), onPressed: onDecrement),
            Text(value.toString(), style: const TextStyle(fontSize: 20)),
            IconButton(icon: const Icon(Icons.add), onPressed: onIncrement),
          ],
        ),
      ],
    );
  }
}