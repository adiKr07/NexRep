enum MuscleGrps {
  chest,
  back,
  // cardio,
  legs,
  forearms,
  biceps,
  triceps,
  shoulders
}

class Exerciselist {
  final String label;
  final String imagePath;

  const Exerciselist({
    required this.label,
    required this.imagePath,
  });
}

final Map<MuscleGrps, List<Exerciselist>> eachMuscleExercises = {
  MuscleGrps.chest: [
    Exerciselist(label: 'Flat Barbell Bench Press', imagePath: 'assets/images/Barbell-Bench-Press_Chest.gif'),
    Exerciselist(label: 'Incline Barbell Bench Press', imagePath: 'assets/images/Barbell-Incline-Bench-Press_Chest.gif'),
    Exerciselist(label: 'High Cable Crossover', imagePath: 'assets/images/High_cable_crossovers.gif'),
  ],

  MuscleGrps.back: [
    Exerciselist(label: 'Wide Grip Pull Ups', imagePath: 'assets/images/Wide-Grip-Pull-Up.gif'),
    Exerciselist(label: 'Barbell Row', imagePath: 'assets/images/Barbell-Bent-Over-Row_Back.gif'),
    Exerciselist(label: 'Lat Pulldown', imagePath: 'assets/images/lat_pulldown.gif'),
  ],

  MuscleGrps.biceps: [
    Exerciselist(label: 'Ez Barbell Curl', imagePath: 'assets/images/ez-bar-bicep-curl.gif'),
    Exerciselist(label: 'Seated Dumbbell Hammer Curl', imagePath: 'assets/images/seated_dumbbell_hammer_curl.gif'),
  ],

  MuscleGrps.triceps: [
    Exerciselist(label: 'Tricep Pushdown', imagePath: 'assets/images/tricep_pushdown.gif'),
    Exerciselist(label: 'Skull Crushers', imagePath: 'assets/images/Barbell-Lying-Triceps-Extension_Upper-Arms.gif'),
  ],

  MuscleGrps.shoulders: [
    Exerciselist(label: 'Overhead Press', imagePath: 'assets/images/Dumbbell-Shoulder-Press.gif'),
    Exerciselist(label: 'Lateral Raises', imagePath: 'assets/images/lateral_raises.gif'),
  ],

  MuscleGrps.legs: [
    Exerciselist(label: 'Squats', imagePath: 'assets/images/squats.gif'),
    Exerciselist(label: 'Leg Press', imagePath: 'assets/images/leg_press.gif'),
  ],

  // MuscleGrps.cardio: [
  //   Exerciselist(label: 'Running'),
  //   Exerciselist(label: 'Cycling'),
  // ],

  MuscleGrps.forearms: [
    Exerciselist(label: 'One Arm Reverse Wrist Curls', imagePath: 'assets/images/One-Arm-Reverse-Wrist-Curl_Forearms.gif'),
    // Exerciselist(label: 'Farmers Walk'),
  ],
};