import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fitmeadi/models/workout_mod.dart';

import '../exerciselist.dart'; // for MuscleGrps and eachMuscleExercises

// Pairs an individual set with its date for the history view
class ExerciseHistoryRow {
  final ExerciseEntry entry;
  final WorkoutSet set;
  final DateTime date;

  ExerciseHistoryRow({required this.entry, required this.set, required this.date});
}
class VolumePoint {
  final DateTime date;
  final double volume;
  VolumePoint(this.date, this.volume);
}
class WorkoutManager {
  final List<Workout> _workouts = [];
  static const String _storageKey = 'workouts';

  List<Workout> get workouts => _workouts;

  Future<void> loadWorkouts() async {
    final pref = await SharedPreferences.getInstance();
    final savedString = pref.getString(_storageKey);
    if (savedString == null) return;
    final decoded = jsonDecode(savedString) as List;
    _workouts.clear();
    _workouts.addAll(decoded.map((w) => Workout.fromJson(w)));
  }
  // ---- Overall analytics ----

  int get totalWorkouts => _workouts.length;

  int get totalSets => _workouts.fold(
        0,
        (sum, w) => sum + w.exercises.fold(0, (s, e) => s + e.sets.length),
      );

  int get totalReps => _workouts.fold(
        0,
        (sum, w) => sum +
            w.exercises.fold(
              0,
              (s, e) => s + e.sets.fold(0, (s2, set) => s2 + set.reps),
            ),
      );

  double get totalVolume => _workouts.fold(
        0.0,
        (sum, w) => sum +
            w.exercises.fold(
              0.0,
              (s, e) => s + e.sets.fold(0.0, (s2, set) => s2 + set.reps * set.weight),
            ),
      );

  // Volume per workout day, sorted oldest -> newest (for the trend chart)
  List<VolumePoint> getVolumeTrend() {
    final points = _workouts.map((w) {
      final vol = w.exercises.fold<double>(
        0,
        (sum, e) => sum + e.sets.fold<double>(0, (s, set) => s + set.reps * set.weight),
      );
      return VolumePoint(w.date, vol);
    }).toList();
    points.sort((a, b) => a.date.compareTo(b.date));
    return points;
  }

  // Reverse lookup: exercise name -> muscle group, built once and cached
  final Map<String, MuscleGrps> _exerciseGroupCache = {};

  MuscleGrps? _groupForExercise(String name) {
    if (_exerciseGroupCache.isEmpty) {
      for (final entry in eachMuscleExercises.entries) {
        for (final ex in entry.value) {
          _exerciseGroupCache[ex.label] = entry.key;
        }
      }
    }
    return _exerciseGroupCache[name];
  }

  // Sets performed per muscle group, across all logged history
  Map<MuscleGrps, int> getSetsByMuscleGroup() {
    final result = <MuscleGrps, int>{};
    for (final w in _workouts) {
      for (final e in w.exercises) {
        final group = _groupForExercise(e.exerciseName);
        if (group == null) continue;
        result[group] = (result[group] ?? 0) + e.sets.length;
      }
    }
    return result;
  }

  Future<ExerciseEntry> addSetToExercise(
    String exerciseName,
    ExerciseEntry? entry,
    WorkoutSet newSet,
  ) async {
    final today = DateTime.now();

    Workout? targetWorkout;
    for(final w in _workouts){
      if (w.date.year == today.year && w.date.month == today.month && w.date.day == today.day) {
        targetWorkout = w;
        break;
      }
    }
    if(targetWorkout == null){
      targetWorkout = Workout(date: today,exercises: []);
      _workouts.add(targetWorkout);
    }

    ExerciseEntry? targetEntry;

    for( final e in targetWorkout.exercises){
      if (e.exerciseName == exerciseName) {
        targetEntry = e;
        break;
      }    
    }

    if (targetEntry == null) {
      targetEntry = ExerciseEntry(exerciseName: exerciseName, sets: []);
      targetWorkout.exercises.add(targetEntry);
    }

    targetEntry.sets
      .add(newSet);

    await saveWorkouts();
    return targetEntry;
  }

  Map<double, int> getMaxRepsPerWeight(String exerciseName) {
  final result = <double, int>{};
  for (final workout in _workouts) {
    for (final entry in workout.exercises) {
      if (entry.exerciseName == exerciseName) {
        for (final set in entry.sets) {
          if (!result.containsKey(set.weight) || set.reps > result[set.weight]!) {
            result[set.weight] = set.reps;
          }
        }
      }
    }
  }
  return result;
}

  Future<void> saveWorkouts() async {
    final pre = await SharedPreferences.getInstance();
    final encoded = jsonEncode(_workouts.map((w) => w.toJson()).toList());
    await pre.setString(_storageKey, encoded);
  }

  List<Workout> getWorkoutsForDate(DateTime date) {
    return _workouts.where((w) =>
        w.date.year == date.year &&
        w.date.month == date.month &&
        w.date.day == date.day).toList();
  }
  ExerciseEntry? getTodaysEntryFor(String exerciseName) {
    final today = DateTime.now();
    for (final w in _workouts) {
      if (w.date.year == today.year && w.date.month == today.month && w.date.day == today.day) {
        for (final e in w.exercises) {
          if (e.exerciseName == exerciseName) return e;
        }
      }
    }
    return null;
  }
  Future<void> logExercise(String exerciseName, List<WorkoutSet> newSets) async {
    final today = DateTime.now();

    Workout? targetWorkout;
    for (final w in _workouts) {
      if (w.date.year == today.year && w.date.month == today.month && w.date.day == today.day) {
        targetWorkout = w;
        break;
      }
    }
    if (targetWorkout == null) {
      targetWorkout = Workout(date: today, exercises: []);
      _workouts.add(targetWorkout);
    }

    ExerciseEntry? targetEntry;
    for (final e in targetWorkout.exercises) {
      if (e.exerciseName == exerciseName) {
        targetEntry = e;
        break;
      }
    }
    if (targetEntry == null) {
      targetEntry = ExerciseEntry(exerciseName: exerciseName, sets: []);
      targetWorkout.exercises.add(targetEntry);
    }

    targetEntry.sets
      ..clear()
      ..addAll(newSets);

    await saveWorkouts();
  }

  // Overwrite the sets on an already-known entry (editing a specific day's log)
  Future<void> updateEntrySets(ExerciseEntry entry, List<WorkoutSet> newSets) async {
    entry.sets
      ..clear()
      ..addAll(newSets);
    await saveWorkouts();
  }

  // Remove a whole exercise entry (a day's full log for one exercise)
  Future<void> removeEntry(ExerciseEntry entry) async {
    for (final workout in _workouts) {
      workout.exercises.remove(entry);
    }
    _workouts.removeWhere((w) => w.exercises.isEmpty);
    await saveWorkouts();
  }

  // Every individual set ever logged for this exercise, across all days, most recent first
  List<ExerciseHistoryRow> getHistoryForExercise(String exerciseName) {
    final result = <ExerciseHistoryRow>[];
    for (final workout in _workouts) {
      for (final entry in workout.exercises) {
        if (entry.exerciseName == exerciseName) {
          for (final set in entry.sets) {
            result.add(ExerciseHistoryRow(entry: entry, set: set, date: workout.date));
          }
        }
      }
    }
    result.sort((a, b) => b.date.compareTo(a.date));
    return result;
  }

  // Delete one specific historical set; cleans up now-empty entries/workouts
  Future<void> deleteSet(ExerciseEntry entry, WorkoutSet set) async {
    entry.sets.remove(set);
    for (final workout in _workouts) {
      workout.exercises.removeWhere((e) => e.sets.isEmpty);
    }
    _workouts.removeWhere((w) => w.exercises.isEmpty);
    await saveWorkouts();
  }

  // Edit one specific historical set's reps/weight in place
  Future<void> updateSet(WorkoutSet set, {required int reps, required double weight}) async {
    set.reps = reps;
    set.weight = weight;
    await saveWorkouts();
  }

  double getMaxWeightForExercise(String name) {
    double maxWeight = 0;
    for (final workout in _workouts) {
      for (final exercise in workout.exercises) {
        if (exercise.exerciseName == name) {
          for (final set in exercise.sets) {
            if (set.weight > maxWeight) maxWeight = set.weight;
          }
        }
      }
    }
    return maxWeight;
  }
}

final workoutManager = WorkoutManager();