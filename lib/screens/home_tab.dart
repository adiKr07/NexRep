import 'package:flutter/material.dart';
import 'package:fitmeadi/providers/workout_provider.dart';
import '../theme/app_colors.dart';
import 'stopwatch_screen.dart';
import 'timer_screen.dart';
import 'workout_screen.dart';

class HomeTab extends StatelessWidget {
  const HomeTab({super.key});

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  @override
  Widget build(BuildContext context) {
    final todaysExercises = workoutManager
        .getWorkoutsForDate(DateTime.now())
        .expand((w) => w.exercises)
        .toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Text(
          _greeting(),
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ---- Today's snapshot ----
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _MiniStat(
                    label: 'Today',
                    value: '${todaysExercises.length}',
                    unit: todaysExercises.length == 1 ? 'exercise' : 'exercises',
                  ),
                ),
                Container(width: 1, height: 36, color: AppColors.divider),
                Expanded(
                  child: _MiniStat(
                    label: 'All Time',
                    value: '${workoutManager.totalWorkouts}',
                    unit: 'workouts',
                  ),
                ),
                Container(width: 1, height: 36, color: AppColors.divider),
                Expanded(
                  child: _MiniStat(
                    label: 'Volume',
                    value: workoutManager.totalVolume >= 1000
                        ? '${(workoutManager.totalVolume / 1000).toStringAsFixed(1)}k'
                        : workoutManager.totalVolume.toStringAsFixed(0),
                    unit: 'kg',
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // ---- Primary action ----
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.add),
              label: const Text('Log New Workout'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 18),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const WorkoutScreen()),
                );
              },
            ),
          ),

          const SizedBox(height: 24),

          // ---- Today's exercises preview ----
          if (todaysExercises.isNotEmpty) ...[
            const Text(
              "Today's Workout",
              style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 10),
            ...todaysExercises.map((entry) => Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle, color: AppColors.neonGreen, size: 18),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(entry.exerciseName,
                            style: const TextStyle(color: Colors.white, fontSize: 14)),
                      ),
                      Text('${entry.sets.length} sets',
                          style: const TextStyle(color: Colors.white54, fontSize: 13)),
                    ],
                  ),
                )),
            const SizedBox(height: 24),
          ],

          // ---- Tools ----
          const Text(
            'Tools',
            style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _ToolCard(
                  icon: Icons.timer_outlined,
                  label: 'Stopwatch',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const StopwatchScreen()),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _ToolCard(
                  icon: Icons.hourglass_bottom,
                  label: 'Timer',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const TimerScreen()),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),
          Center(child: Text('More features coming soon!', style: TextStyle(color: Colors.white54, fontSize: 13))),
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String label;
  final String value;
  final String unit;

  const _MiniStat({required this.label, required this.value, required this.unit});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value,
            style: const TextStyle(
                color: AppColors.neonGreen, fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 2),
        Text(unit, style: const TextStyle(color: Colors.white38, fontSize: 11)),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(color: Colors.white54, fontSize: 12)),
      ],
    );
  }
}

class _ToolCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ToolCard({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Icon(icon, color: AppColors.neonGreen, size: 26),
            const SizedBox(height: 8),
            Text(label, style: const TextStyle(color: Colors.white, fontSize: 13)),
          ],
        ),
      ),
    );
  }
}