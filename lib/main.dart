import 'package:flutter/material.dart';
// import 'screens/home_screen.dart';
import 'package:fitmeadi/providers/workout_provider.dart';
import 'screens/main_nav_screen.dart';
import 'theme/app_theme.dart';

void main() async {
    WidgetsFlutterBinding.ensureInitialized();
    await workoutManager.loadWorkouts();
    runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Workout Tracker',
      theme: AppTheme.dark,
      home: const MainNavScreen(),
    );
  }
}