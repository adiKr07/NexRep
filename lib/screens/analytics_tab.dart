import 'package:flutter/material.dart';
import 'package:fitmeadi/providers/workout_provider.dart';
import '../exerciselist.dart';
import 'exercise_library_analytics_screen.dart';
import 'charts_screen.dart';
import '../theme/app_colors.dart';

const Color _cardColor = AppColors.surface;

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  // static const Color _cardColor = Color(0xFF1C1C1E);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: const Text('Analytics',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.7,
            children: [
              _StatTile(
                label: 'Total Workouts',
                value: workoutManager.totalWorkouts.toString(),
                unit: '',
                icon: Icons.event_available_rounded,
                accent: AppColors.neonGreen,
              ),
              _StatTile(
                label: 'Total Sets',
                value: workoutManager.totalSets.toString(),
                unit: '',
                icon: Icons.format_list_numbered_rounded,
                accent: AppColors.statAccent2,
              ),
              _StatTile(
                label: 'Total Reps',
                value: workoutManager.totalReps.toString(),
                unit: '',
                icon: Icons.repeat_rounded,
                accent: AppColors.statAccent3,
              ),
              _StatTile(
                label: 'Total Volume',
                value: workoutManager.totalVolume.toStringAsFixed(0),
                unit: 'kg',
                icon: Icons.stacked_bar_chart_rounded,
                accent: AppColors.statAccent4,
              ),
            ],
          ),

          const SizedBox(height: 20),

          _NavCard(
            icon: Icons.fitness_center_rounded,
            title: 'Exercise Library',
            subtitle: 'View stats per exercise',
            accent: AppColors.neonGreen,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ExerciseLibraryAnalyticsScreen()),
              );
            },
          ),
          const SizedBox(height: 12),
          _NavCard(
            icon: Icons.insert_chart_rounded,
            title: 'View Charts',
            subtitle: 'Volume trend & muscle breakdown',
            accent: AppColors.statAccent2,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ChartsScreen()),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _NavCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color accent;
  final VoidCallback onTap;

  const _NavCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.accent,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _cardColor,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Icon(icon, color: accent),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          color: Colors.white, fontSize: 15, fontWeight: FontWeight.w500)),
                  Text(subtitle, style: const TextStyle(color: Colors.white60, fontSize: 12)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.white54),
          ],
        ),
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  final String label;
  final String value;
  final String unit;
  final IconData icon;
  final Color accent;

  const _StatTile({
    required this.label,
    required this.value,
    required this.unit,
    required this.icon,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: accent.withOpacity(0.12),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: accent.withOpacity(0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Icon(icon, color: accent, size: 16),
              const SizedBox(width: 6),
              Expanded(
                child: Text(label,
                    style: TextStyle(color: accent, fontSize: 12), overflow: TextOverflow.ellipsis),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            unit.isEmpty ? value : '$value $unit',
            style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}