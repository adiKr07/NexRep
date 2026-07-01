import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:fitmeadi/providers/workout_provider.dart';
import '../exerciselist.dart';
import '../theme/app_colors.dart';

const Color _cardColor = AppColors.surface;

enum _Period { m1, m3, m6, y1, all }

extension on _Period {
  String get label => switch (this) {
        _Period.m1 => '1m',
        _Period.m3 => '3m',
        _Period.m6 => '6m',
        _Period.y1 => '1y',
        _Period.all => 'all',
      };

  DateTime? cutoff(DateTime now) => switch (this) {
        _Period.m1 => DateTime(now.year, now.month - 1, now.day),
        _Period.m3 => DateTime(now.year, now.month - 3, now.day),
        _Period.m6 => DateTime(now.year, now.month - 6, now.day),
        _Period.y1 => DateTime(now.year - 1, now.month, now.day),
        _Period.all => null,
      };
}

const Map<MuscleGrps, Color> _groupColors = {
  MuscleGrps.chest: Colors.redAccent,
  MuscleGrps.back: Colors.lightBlueAccent,
  MuscleGrps.shoulders: Colors.purpleAccent,
  MuscleGrps.legs: Colors.tealAccent,
  MuscleGrps.biceps: Colors.orangeAccent,
  MuscleGrps.triceps: Colors.greenAccent,
  MuscleGrps.forearms: Color(0xFF66FF99),
};

class ChartsScreen extends StatefulWidget {
  const ChartsScreen({super.key});

  @override
  State<ChartsScreen> createState() => _ChartsScreenState();
}

class _ChartsScreenState extends State<ChartsScreen> with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  _Period selectedPeriod = _Period.m6;
  MuscleGrps? highlightedGroup;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  String _formatDate(DateTime d) => '${d.day}/${d.month}';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: const Text('Charts',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.neonGreen,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white54,
          tabs: const [
            Tab(text: 'VOLUME TREND'),
            Tab(text: 'BREAKDOWN'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _VolumeTrendTab(
            selectedPeriod: selectedPeriod,
            onPeriodChanged: (p) => setState(() => selectedPeriod = p),
          ),
          _BreakdownTab(
            highlightedGroup: highlightedGroup,
            onGroupTap: (g) => setState(() => highlightedGroup = g),
          ),
        ],
      ),
    );
  }
}



class _VolumeTrendTab extends StatelessWidget {
  final _Period selectedPeriod;
  final ValueChanged<_Period> onPeriodChanged;

  const _VolumeTrendTab({required this.selectedPeriod, required this.onPeriodChanged});

  String _formatDate(DateTime d) => '${d.day}/${d.month}';

  @override
  Widget build(BuildContext context) {
    final trend = workoutManager.getVolumeTrend();
    final now = DateTime.now();
    final cutoff = selectedPeriod.cutoff(now);
    final filteredTrend =
        cutoff == null ? trend : trend.where((p) => p.date.isAfter(cutoff)).toList();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          children: _Period.values.map((p) {
            final selected = p == selectedPeriod;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Text(p.label),
                selected: selected,
                onSelected: (_) => onPeriodChanged(p),
                backgroundColor: _cardColor,
                selectedColor: AppColors.neonGreen.withOpacity(0.3),
                labelStyle: TextStyle(color: selected ? AppColors.neonGreen : Colors.white70),
                side: BorderSide.none,
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 16),
        if (filteredTrend.length < 2)
          Container(
            height: 260,
            alignment: Alignment.center,
            decoration: BoxDecoration(color: _cardColor, borderRadius: BorderRadius.circular(16)),
            child: const Text('Not enough data yet for this period.',
                style: TextStyle(color: Colors.white60)),
          )
        else
          Container(
            height: 320,
            padding: const EdgeInsets.fromLTRB(8, 20, 20, 8),
            decoration: BoxDecoration(color: _cardColor, borderRadius: BorderRadius.circular(16)),
            child: Builder(builder: (context) {
              final values = filteredTrend.map((p) => p.volume).toList();
              final minVal = values.reduce((a, b) => a < b ? a : b);
              final maxVal = values.reduce((a, b) => a > b ? a : b);
              final padding =
                  (maxVal - minVal) == 0 ? (maxVal == 0 ? 1.0 : maxVal * 0.1) : (maxVal - minVal) * 0.1;
              final yMin = (minVal - padding) < 0 ? 0.0 : minVal - padding;
              final yMax = maxVal + padding;
              final yInterval = (yMax - yMin) <= 0 ? 1.0 : (yMax - yMin) / 4;

              return LineChart(
                LineChartData(
                  minY: yMin,
                  maxY: yMax,
                  gridData: FlGridData(show: true, drawVerticalLine: false, horizontalInterval: yInterval),
                  titlesData: FlTitlesData(
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 44,
                        interval: yInterval,
                        getTitlesWidget: (value, meta) => Text(
                          value.toStringAsFixed(0),
                          style: const TextStyle(fontSize: 10, color: Colors.white60),
                        ),
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 26,
                        interval: (filteredTrend.length / 4).clamp(1, filteredTrend.length).ceilToDouble(),
                        getTitlesWidget: (value, meta) {
                          final i = value.toInt();
                          if (i < 0 || i >= filteredTrend.length) return const SizedBox.shrink();
                          return Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Text(_formatDate(filteredTrend[i].date),
                                style: const TextStyle(fontSize: 10, color: Colors.white60)),
                          );
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  lineTouchData: LineTouchData(
                    touchTooltipData: LineTouchTooltipData(
                      getTooltipItems: (spots) => spots.map((s) {
                        final pt = filteredTrend[s.x.toInt()];
                        return LineTooltipItem(
                          '${_formatDate(pt.date)}\n${s.y.toStringAsFixed(0)} kg',
                          const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                        );
                      }).toList(),
                    ),
                  ),
                  lineBarsData: [
                    LineChartBarData(
                      spots: [
                        for (int i = 0; i < filteredTrend.length; i++)
                          FlSpot(i.toDouble(), filteredTrend[i].volume),
                      ],
                      isCurved: true,
                      color: AppColors.neonGreen,
                      barWidth: 3,
                      dotData: const FlDotData(show: true),
                      belowBarData: BarAreaData(show: true, color: AppColors.neonGreen.withOpacity(0.2)),
                    ),
                  ],
                ),
              );
            }),
          ),
        const SizedBox(height: 16),
        if (filteredTrend.isNotEmpty)
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: _cardColor, borderRadius: BorderRadius.circular(14)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Total this period', style: TextStyle(color: Colors.white70)),
                Text(
                  '${filteredTrend.fold<double>(0, (s, p) => s + p.volume).toStringAsFixed(0)} kg',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ],
            ),
          ),
      ],
    );
  }
}



class _BreakdownTab extends StatelessWidget {
  final MuscleGrps? highlightedGroup;
  final ValueChanged<MuscleGrps> onGroupTap;

  const _BreakdownTab({required this.highlightedGroup, required this.onGroupTap});

  String _formatGrpName(MuscleGrps group) {
    final name = group.name;
    return name[0].toUpperCase() + name.substring(1);
  }

  @override
  Widget build(BuildContext context) {
    final groupSets = workoutManager.getSetsByMuscleGroup();
    final totalGroupSets = groupSets.values.fold(0, (a, b) => a + b);

    if (totalGroupSets == 0) {
      return const Center(
        child: Text('Log some workouts to see your breakdown.',
            style: TextStyle(color: Colors.white60)),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        SizedBox(
          height: 240,
          child: PieChart(
            PieChartData(
              sectionsSpace: 2,
              centerSpaceRadius: 60,
              sections: groupSets.entries.map((e) {
                final isHighlighted = highlightedGroup == e.key;
                return PieChartSectionData(
                  value: e.value.toDouble(),
                  color: _groupColors[e.key] ?? Colors.grey,
                  radius: isHighlighted ? 46 : 40,
                  showTitle: false,
                );
              }).toList(),
              pieTouchData: PieTouchData(
                touchCallback: (event, response) {
                  if (response?.touchedSection == null) return;
                  final idx = response!.touchedSection!.touchedSectionIndex;
                  if (idx < 0 || idx >= groupSets.length) return;
                  onGroupTap(groupSets.keys.elementAt(idx));
                },
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        ...groupSets.entries.map((e) {
          final pct = (e.value / totalGroupSets * 100).toStringAsFixed(2);
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(color: _cardColor, borderRadius: BorderRadius.circular(10)),
            child: Row(
              children: [
                CircleAvatar(radius: 5, backgroundColor: _groupColors[e.key] ?? Colors.grey),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(_formatGrpName(e.key),
                      style: const TextStyle(color: Colors.white, fontSize: 14)),
                ),
                Text('${e.value} sets', style: const TextStyle(color: Colors.white70, fontSize: 13)),
                const SizedBox(width: 12),
                Text('$pct%', style: const TextStyle(color: Colors.white54, fontSize: 13)),
              ],
            ),
          );
        }),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: _cardColor, borderRadius: BorderRadius.circular(14)),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    Text('${workoutManager.totalWorkouts}',
                        style: const TextStyle(
                            color: Colors.tealAccent, fontSize: 22, fontWeight: FontWeight.bold)),
                    const Text('Total Workouts', style: TextStyle(color: Colors.white60, fontSize: 12)),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  children: [
                    Text('$totalGroupSets',
                        style: const TextStyle(
                            color: Colors.tealAccent, fontSize: 22, fontWeight: FontWeight.bold)),
                    const Text('Total Sets', style: TextStyle(color: Colors.white60, fontSize: 12)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}