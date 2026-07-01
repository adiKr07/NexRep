import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:fitmeadi/providers/workout_provider.dart';
import 'package:fitmeadi/models/workout_mod.dart';
import '../theme/app_colors.dart';


enum _GraphType { est1rm, maxWeight, maxReps, volume, totalReps }

extension on _GraphType {
  String get label => switch (this) {
        _GraphType.est1rm => 'Estimated 1RM',
        _GraphType.maxWeight => 'Max Weight',
        _GraphType.maxReps => 'Max Reps',
        _GraphType.volume => 'Workout Volume',
        _GraphType.totalReps => 'Workout Reps',
      };
}

class _SessionStat {
  final DateTime date;
  final double maxWeight;
  final int maxReps;
  final double volume;
  final int totalReps;
  final double est1rm;

  _SessionStat({
    required this.date,
    required this.maxWeight,
    required this.maxReps,
    required this.volume,
    required this.totalReps,
    required this.est1rm,
  });
}

class ExerciseAnalyticsScreen extends StatefulWidget {
  final String initialExercise;
  const ExerciseAnalyticsScreen({super.key, required this.initialExercise});

  @override
  State<ExerciseAnalyticsScreen> createState() => _ExerciseAnalyticsScreenState();
}

class _ExerciseAnalyticsScreenState extends State<ExerciseAnalyticsScreen> {
  late String selectedExercise;
  _GraphType selectedGraph = _GraphType.est1rm;

  @override
  void initState() {
    super.initState();
    selectedExercise = widget.initialExercise;
  }

  double _epley(WorkoutSet s) => s.reps == 1 ? s.weight : s.weight * (1 + s.reps / 30.0);

  List<_SessionStat> _buildSessionStats() {
    final byDay = <DateTime, List<WorkoutSet>>{};
    for (final row in workoutManager.getHistoryForExercise(selectedExercise)) {
      final day = DateTime(row.date.year, row.date.month, row.date.day);
      byDay.putIfAbsent(day, () => []).add(row.set);
    }

    final stats = byDay.entries.map((e) {
      final sets = e.value;
      double maxWeight = 0, volume = 0, bestEst1rm = 0;
      int maxReps = 0, totalReps = 0;
      for (final s in sets) {
        if (s.weight > maxWeight) maxWeight = s.weight;
        if (s.reps > maxReps) maxReps = s.reps;
        volume += s.reps * s.weight;
        totalReps += s.reps;
        final est = _epley(s);
        if (est > bestEst1rm) bestEst1rm = est;
      }
      return _SessionStat(
        date: e.key,
        maxWeight: maxWeight,
        maxReps: maxReps,
        volume: volume,
        totalReps: totalReps,
        est1rm: bestEst1rm,
      );
    }).toList();

    stats.sort((a, b) => a.date.compareTo(b.date));
    return stats;
  }

  double _valueFor(_SessionStat s, _GraphType type) => switch (type) {
        _GraphType.est1rm => s.est1rm,
        _GraphType.maxWeight => s.maxWeight,
        _GraphType.maxReps => s.maxReps.toDouble(),
        _GraphType.volume => s.volume,
        _GraphType.totalReps => s.totalReps.toDouble(),
      };

  String _formatDate(DateTime d) => '${d.day}/${d.month}';

  Widget _buildGraphSelector(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () => _openGraphPicker(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.neonGreen.withOpacity(0.3),
          ),
        ),
        child: Row(
          children: [
            Icon(Icons.show_chart_rounded, color: colorScheme.primary, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(selectedGraph.label, style: textTheme.titleSmall),
            ),
            Icon(Icons.unfold_more_rounded, color: colorScheme.onSurface.withOpacity(0.6)),
          ],
        ),
      ),
    );
  }

  Future<void> _openGraphPicker(BuildContext context) async {
    final colorScheme = Theme.of(context).colorScheme;
    final picked = await showModalBottomSheet<_GraphType>(
      context: context,
      backgroundColor: colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: colorScheme.onSurface.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                for (final type in _GraphType.values)
                  ListTile(
                    title: Text(type.label),
                    trailing: type == selectedGraph
                        ? Icon(Icons.check_circle, color: colorScheme.primary)
                        : null,
                    onTap: () => Navigator.pop(context, type),
                  ),
              ],
            ),
          ),
        );
      },
    );
    if (picked != null) setState(() => selectedGraph = picked);
  }

  String _unitFor(_GraphType type) => switch (type) {
  _GraphType.est1rm => 'kg',
  _GraphType.maxWeight => 'kg',
  _GraphType.maxReps => 'reps',
  _GraphType.volume => 'kg lifted',
  _GraphType.totalReps => 'reps',
};

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final stats = _buildSessionStats();

    final history = workoutManager.getHistoryForExercise(selectedExercise);
    final allTimeMaxWeight = workoutManager.getMaxWeightForExercise(selectedExercise);
    final allTimeTotalVolume = history.fold<double>(0, (sum, r) => sum + r.set.reps * r.set.weight);
    final allTimeTotalSets = history.length;
    final allTimeBestEst1rm = history.isEmpty
        ? 0.0
        : history.map((r) => _epley(r.set)).reduce((a, b) => a > b ? a : b);

    return Scaffold(
      appBar: AppBar(title: Text(selectedExercise), centerTitle: true),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildGraphSelector(context),
          const SizedBox(height: 20),

          if (stats.length < 2)
            Container(
              height: 240,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                'Not enough data yet — log at least 2 sessions to see a trend.',
                textAlign: TextAlign.center,
                style: textTheme.bodyMedium,
              ),
            )
          else
            Container(
              height: 280,
              padding: const EdgeInsets.fromLTRB(8, 30, 20, 8),
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Color.fromRGBO(255, 254, 254, 0.5),
                ),
              ),
              child: Builder(
                builder: (context) {
                  final values = [for (final s in stats) _valueFor(s, selectedGraph)];
                  final minVal = values.reduce((a, b) => a < b ? a : b);
                  final maxVal = values.reduce((a, b) => a > b ? a : b);
                  final padding = (maxVal - minVal) == 0
                      ? (maxVal == 0 ? 1.0 : maxVal * 0.1)
                      : (maxVal - minVal) * 0.1;
                  final yMin = (minVal - padding) < 0 ? 0.0 : minVal - padding;
                  final yMax = maxVal + padding;
                  final yInterval = (yMax - yMin) <= 0 ? 1.0 : (yMax - yMin) / 4;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 8, bottom: 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              selectedGraph.label,
                              style: textTheme.titleSmall?.copyWith(color: Colors.white),
                            ),
                            Text(
                              _unitFor(selectedGraph),
                              style: textTheme.bodySmall?.copyWith(color: Colors.white60),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: LineChart(
                          LineChartData(
                            minY: yMin,
                            maxY: yMax,
                            gridData: FlGridData(
                              show: true,
                              drawVerticalLine: false,
                              horizontalInterval: yInterval,
                            ),
                            titlesData: FlTitlesData(
                              topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                              rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                              leftTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  reservedSize: 48,
                                  interval: yInterval,
                                  getTitlesWidget: (value, meta) {
                                    return Text(
                                      value.toStringAsFixed(1),
                                      style: const TextStyle(fontSize: 11),
                                      maxLines: 1,
                                      overflow: TextOverflow.visible,
                                    );
                                  },
                                ),
                              ),
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  reservedSize: 28,
                                  interval: (stats.length / 4).clamp(1, stats.length).ceilToDouble(),
                                  getTitlesWidget: (value, meta) {
                                    final i = value.toInt();
                                    if (i < 0 || i >= stats.length) return const SizedBox.shrink();
                                    return Padding(
                                      padding: const EdgeInsets.only(top: 6),
                                      child: Text(_formatDate(stats[i].date), style: const TextStyle(fontSize: 10)),
                                    );
                                  },
                                ),
                              ),
                            ),
                            borderData: FlBorderData(show: false),
                            lineTouchData: LineTouchData(
                              touchTooltipData: LineTouchTooltipData(
                                getTooltipItems: (spots) => spots.map((s) {
                                  final stat = stats[s.x.toInt()];
                                  return LineTooltipItem(
                                    '${_formatDate(stat.date)}\n${s.y.toStringAsFixed(1)}',
                                    const TextStyle(fontWeight: FontWeight.bold),
                                  );
                                }).toList(),
                              ),
                            ),
                            lineBarsData: [
                              LineChartBarData(
                                spots: [
                                  for (int i = 0; i < stats.length; i++)
                                    FlSpot(i.toDouble(), _valueFor(stats[i], selectedGraph)),
                                ],
                                isCurved: true,
                                color: colorScheme.primary,
                                barWidth: 3,
                                dotData: const FlDotData(show: true),
                                belowBarData: BarAreaData(
                                  show: true,
                                  color: colorScheme.primary.withOpacity(0.25),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),

          const SizedBox(height: 24),
          Text('Stats', style: textTheme.titleMedium),
          const SizedBox(height: 8),

          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.6,
            children: [
              _StatTile(
                label: 'Best Est. 1RM',
                value: allTimeBestEst1rm.toStringAsFixed(1),
                unit: 'kg',
                icon: Icons.trending_up_rounded,
                accent: AppColors.neonGreen,
              ),
              _StatTile(
                label: 'Max Weight',
                value: allTimeMaxWeight.toStringAsFixed(1),
                unit: 'kg',
                icon: Icons.fitness_center_rounded,
                accent: AppColors.statAccent2,
              ),
              _StatTile(
                label: 'Total Volume',
                value: allTimeTotalVolume.toStringAsFixed(0),
                unit: 'kg',
                icon: Icons.stacked_bar_chart_rounded,
                accent: AppColors.statAccent3,
              ),
              _StatTile(
                label: 'Total Sets',
                value: allTimeTotalSets.toString(),
                unit: '',
                icon: Icons.format_list_numbered_rounded,
                accent: AppColors.statAccent4,
              ),
              _StatTile(
                label: 'Sessions',
                value: stats.length.toString(),
                unit: '',
                icon: Icons.event_repeat_rounded,
                accent: AppColors.neonGreenDim,
              ),
            ],
          ),
        ],
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
    final textTheme = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.neonGreen.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Icon(icon, color: accent, size: 18),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  label,
                  style: textTheme.bodySmall?.copyWith(color: accent),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            unit.isEmpty ? value : '$value $unit',
            style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}