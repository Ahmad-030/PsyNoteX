import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../models/note_model.dart';
import '../providers/app_provider.dart';
import '../utils/app_theme.dart';
import '../widgets/shared_widgets.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<AppProvider>();
    final cs = Theme.of(context).extension<AppColorScheme>()!;

    return SafeArea(
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Text(
                'Insights',
                style: TextStyle(
                  color: cs.textPrimary,
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                ),
              ).animate().fadeIn().slideY(begin: -0.2, end: 0),
            ),
          ),
          SliverToBoxAdapter(child: _StatsRow(prov: prov)),
          SliverToBoxAdapter(child: _WeeklyChart(prov: prov)),
          SliverToBoxAdapter(child: _MoodPieChart(prov: prov)),
          SliverToBoxAdapter(child: _HeatmapSection(prov: prov)),
          SliverToBoxAdapter(child: _InsightsSection(prov: prov)),
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }
}

class _StatsRow extends StatelessWidget {
  final AppProvider prov;
  const _StatsRow({required this.prov});

  @override
  Widget build(BuildContext context) {
    final streak = prov.getStreak();
    final dist = prov.getMoodDistribution();
    final positiveMoods = (dist[Mood.happy] ?? 0) +
        (dist[Mood.excited] ?? 0) +
        (dist[Mood.grateful] ?? 0);
    final total = prov.notes.length;
    final pct = total == 0 ? 0 : ((positiveMoods / total) * 100).round();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          _StatCard(label: 'Total Notes', value: '$total', icon: '📝'),
          const SizedBox(width: 10),
          _StatCard(label: 'Day Streak', value: '$streak 🔥', icon: '🗓️'),
          const SizedBox(width: 10),
          _StatCard(label: 'Positivity', value: '$pct%', icon: '✨'),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final String icon;
  const _StatCard(
      {required this.label, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).extension<AppColorScheme>()!;
    return Expanded(
      child: GlassCard(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Text(icon, style: const TextStyle(fontSize: 20)),
            const SizedBox(height: 6),
            Text(value,
                style: TextStyle(
                    color: cs.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w800)),
            const SizedBox(height: 2),
            Text(label,
                style: TextStyle(color: cs.textHint, fontSize: 10),
                textAlign: TextAlign.center),
          ],
        ),
      ).animate().fadeIn(delay: 100.ms).scale(begin: const Offset(0.9, 0.9)),
    );
  }
}

class _WeeklyChart extends StatelessWidget {
  final AppProvider prov;
  const _WeeklyChart({required this.prov});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).extension<AppColorScheme>()!;
    final data = prov.getWeeklyMoodScores();
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: GlassCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Weekly Mood',
                style: TextStyle(
                    color: cs.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w700)),
            const SizedBox(height: 4),
            Text('Mood score over past 7 days',
                style: TextStyle(color: cs.textHint, fontSize: 12)),
            const SizedBox(height: 16),
            SizedBox(
              height: 140,
              child: BarChart(
                BarChartData(
                  maxY: 5,
                  minY: 0,
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    getDrawingHorizontalLine: (_) => FlLine(
                      color: cs.divider,
                      strokeWidth: 0.5,
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  titlesData: FlTitlesData(
                    leftTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (v, _) => Text(
                          days[v.toInt()],
                          style: TextStyle(color: cs.textHint, fontSize: 10),
                        ),
                      ),
                    ),
                  ),
                  barGroups: List.generate(7, (i) {
                    final val = (data[i] ?? 0).toDouble();
                    return BarChartGroupData(
                      x: i,
                      barRods: [
                        BarChartRodData(
                          toY: val,
                          width: 20,
                          borderRadius: BorderRadius.circular(6),
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [
                              AppColors.primary,
                              cs.accent.withOpacity(0.8),
                            ],
                          ),
                        ),
                      ],
                    );
                  }),
                ),
              ),
            ),
          ],
        ),
      ).animate().fadeIn(delay: 150.ms).slideY(begin: 0.2, end: 0),
    );
  }
}

class _MoodPieChart extends StatefulWidget {
  final AppProvider prov;
  const _MoodPieChart({required this.prov});

  @override
  State<_MoodPieChart> createState() => _MoodPieChartState();
}

class _MoodPieChartState extends State<_MoodPieChart> {
  int _touched = -1;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).extension<AppColorScheme>()!;
    final dist = widget.prov.getMoodDistribution();
    if (dist.isEmpty) return const SizedBox.shrink();

    final sections = dist.entries.map((e) {
      final i = e.key.index;
      final isTouched = i == _touched;
      return PieChartSectionData(
        value: e.value.toDouble(),
        title: isTouched ? '${e.key.emoji}\n${e.value}' : e.key.emoji,
        radius: isTouched ? 60 : 48,
        color: AppColors.tagColors[i % AppColors.tagColors.length],
        titleStyle: const TextStyle(fontSize: 12),
      );
    }).toList();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: GlassCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Mood Distribution',
                style: TextStyle(
                    color: cs.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w700)),
            const SizedBox(height: 16),
            Row(
              children: [
                SizedBox(
                  height: 160,
                  width: 160,
                  child: PieChart(
                    PieChartData(
                      sections: sections,
                      centerSpaceRadius: 36,
                      pieTouchData: PieTouchData(
                        touchCallback: (ev, resp) {
                          setState(() {
                            if (!ev.isInterestedForInteractions ||
                                resp == null ||
                                resp.touchedSection == null) {
                              _touched = -1;
                            } else {
                              _touched =
                                  resp.touchedSection!.touchedSectionIndex;
                            }
                          });
                        },
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: dist.entries.map((e) {
                      final c = AppColors.tagColors[
                          e.key.index % AppColors.tagColors.length];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Row(
                          children: [
                            NeonDot(color: c, size: 8),
                            const SizedBox(width: 8),
                            Text(e.key.emoji,
                                style: const TextStyle(fontSize: 14)),
                            const SizedBox(width: 4),
                            Text(e.key.label,
                                style: TextStyle(
                                    color: cs.textSecondary, fontSize: 12)),
                            const Spacer(),
                            Text('${e.value}',
                                style: TextStyle(
                                    color: cs.textPrimary,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700)),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ],
        ),
      ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2, end: 0),
    );
  }
}

class _HeatmapSection extends StatelessWidget {
  final AppProvider prov;
  const _HeatmapSection({required this.prov});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).extension<AppColorScheme>()!;
    final heatmap = prov.getHeatmapData();
    final now = DateTime.now();
    const weeks = 10;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: GlassCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Activity Heatmap',
                style: TextStyle(
                    color: cs.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w700)),
            const SizedBox(height: 4),
            Text('Past 10 weeks',
                style: TextStyle(color: cs.textHint, fontSize: 12)),
            const SizedBox(height: 12),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: List.generate(weeks, (w) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 3),
                    child: Column(
                      children: List.generate(7, (d) {
                        final date = now.subtract(
                            Duration(days: (weeks - 1 - w) * 7 + (6 - d)));
                        final key =
                            DateTime(date.year, date.month, date.day);
                        final count = heatmap[key] ?? 0;
                        final opacity =
                            count == 0 ? 0.06 : (count / 5).clamp(0.2, 1.0);
                        return Container(
                          width: 12,
                          height: 12,
                          margin: const EdgeInsets.only(bottom: 3),
                          decoration: BoxDecoration(
                            color: cs.accent.withOpacity(opacity),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        );
                      }),
                    ),
                  );
                }),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text('Less',
                    style: TextStyle(color: cs.textHint, fontSize: 10)),
                const SizedBox(width: 4),
                ...List.generate(5, (i) {
                  return Container(
                    width: 10,
                    height: 10,
                    margin: const EdgeInsets.only(left: 2),
                    decoration: BoxDecoration(
                      color: cs.accent.withOpacity(0.1 + i * 0.18),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  );
                }),
                const SizedBox(width: 4),
                Text('More',
                    style: TextStyle(color: cs.textHint, fontSize: 10)),
              ],
            ),
          ],
        ),
      ).animate().fadeIn(delay: 250.ms).slideY(begin: 0.2, end: 0),
    );
  }
}

class _InsightsSection extends StatelessWidget {
  final AppProvider prov;
  const _InsightsSection({required this.prov});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).extension<AppColorScheme>()!;
    final insights = prov.getInsights();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Text('Smart Insights',
                style: TextStyle(
                    color: cs.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w700)),
          ),
          ...insights.asMap().entries.map((e) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: GlassCard(
                padding: const EdgeInsets.all(14),
                borderRadius: 12,
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(Icons.lightbulb_outline,
                          color: cs.accent, size: 18),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(e.value,
                          style: TextStyle(
                              color: cs.textPrimary,
                              fontSize: 13,
                              height: 1.4)),
                    ),
                  ],
                ),
              )
                  .animate()
                  .fadeIn(delay: Duration(milliseconds: 100 * e.key))
                  .slideX(begin: -0.2, end: 0),
            );
          }),
        ],
      ),
    );
  }
}
