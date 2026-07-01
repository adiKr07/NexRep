import 'package:flutter/material.dart';
import '../exerciselist.dart';
import 'exercise_analytics_tab.dart';
import '../theme/app_colors.dart';

class ExerciseLibraryAnalyticsScreen extends StatelessWidget {
  const ExerciseLibraryAnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: const Text(
          'Exercise Library',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: MuscleGrps.values.map((group) {
            final exercises = eachMuscleExercises[group] ?? [];
            return _MuscleGroupTile(
              exercises: exercises,
              formattedName: _formatGrpName(group),
            );
          }).toList(),
        ),
      ),
    );
  }

  String _formatGrpName(MuscleGrps group) {
    final name = group.name;
    return name[0].toUpperCase() + name.substring(1);
  }
}

class _MuscleGroupTile extends StatefulWidget {
  final List<dynamic> exercises;
  final String formattedName;

  const _MuscleGroupTile({
    required this.exercises,
    required this.formattedName,
  });

  @override
  State<_MuscleGroupTile> createState() => _MuscleGroupTileState();
}

class _MuscleGroupTileState extends State<_MuscleGroupTile> {
  bool _expanded = false;

  static const Color _cardColor = AppColors.surface;
  static const Color _dividerColor = AppColors.divider;
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(14),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: () => setState(() => _expanded = !_expanded),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.formattedName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  AnimatedRotation(
                    turns: _expanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ),
          AnimatedCrossFade(
            firstChild: const SizedBox(width: double.infinity, height: 0),
            secondChild: Column(
              children: widget.exercises.map<Widget>((exercise) {
                return Column(
                  children: [
                    Divider(height: 1, color: _dividerColor, indent: 16, endIndent: 16),
                    ListTile(
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.asset(
                          exercise.imagePath,
                          width: 48,
                          height: 48,
                          fit: BoxFit.cover,
                        ),
                      ),
                      title: Text(
                        exercise.label,
                        style: const TextStyle(color: Colors.white, fontSize: 15),
                      ),
                      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ExerciseAnalyticsScreen(
                              initialExercise: exercise.label,
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                );
              }).toList(),
            ),
            crossFadeState:
                _expanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 200),
          ),
        ],
      ),
    );
  }
}