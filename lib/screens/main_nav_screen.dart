import 'package:flutter/material.dart';
import 'home_tab.dart';
import 'workout_tab.dart';
import 'analytics_tab.dart';
import 'pill_nav_bar.dart';
import 'mini_session_bar.dart';

class MainNavScreen extends StatefulWidget {
  const MainNavScreen({super.key});

  @override
  State<MainNavScreen> createState() => _MainNavScreenState();
}

class _MainNavScreenState extends State<MainNavScreen> {
  int _selectedIndex = 0;

  void _onTabSelected(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          IndexedStack(
            index: _selectedIndex,
            children: const [
              HomeTab(),
              WorkoutTab(),
              AnalyticsScreen(),
            ],
          ),
          
          const SafeArea(
            child: Align(
              alignment: Alignment.topCenter,
              child: MiniSessionBar(),
            ),
          ),
        ],
      ),
      bottomNavigationBar: PillNavBar(
        currentIndex: _selectedIndex,
        onTabSelected: _onTabSelected,
      ),
    );
  }
}