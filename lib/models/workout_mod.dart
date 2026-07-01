class Workout {
  final DateTime date;
  final List<ExerciseEntry> exercises;

  Workout({required this.date, required this.exercises});

  Map<String,dynamic> toJson(){
    return{
      'date' : date.toIso8601String(),
      'exercises' : exercises.map((s) => s.toJson()).toList(),
    };
  }
  factory Workout.fromJson(Map<String,dynamic> json){
    return Workout(
      date : DateTime.parse(json['date']),
      exercises : (json['exercises']as List).map((s) => ExerciseEntry.fromJson(s)).toList(),
    );
  }
}

class ExerciseEntry {
  final String exerciseName;
  final List<WorkoutSet> sets;

  ExerciseEntry({required this.exerciseName, required this.sets});

  Map<String, dynamic> toJson() {
    return {
      'exerciseName': exerciseName,
      'sets': sets.map((s) => s.toJson()).toList(),
    };
  }

  factory ExerciseEntry.fromJson(Map<String, dynamic> json) {
    return ExerciseEntry(
      exerciseName: json['exerciseName'],
      sets: (json['sets'] as List).map((s) => WorkoutSet.fromJson(s)).toList(),
    );
  }
}

class WorkoutSet {
  int reps;
  double weight;

  WorkoutSet({this.reps = 0, this.weight = 0});
  Map<String, dynamic> toJson() {
    return {'reps': reps, 'weight': weight};
  }

  factory WorkoutSet.fromJson(Map<String, dynamic> json) {
    return WorkoutSet(reps: json['reps'], weight: json['weight']);
  }
}
