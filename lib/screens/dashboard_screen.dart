import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import '../utils/app_theme.dart';
import '../utils/student_provider.dart';
import '../widgets/common_widgets.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 0.5, color: AppTheme.border),
        ),
      ),
      body: Consumer<StudentProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final stats = provider.dashboardStats;
          final gradeDist = Map<String, int>.from(stats['gradeDist'] ?? {});
          final topStudents = stats['topStudents'] as List? ?? [];
          final atRiskStudents = stats['atRiskStudents'] as List? ?? [];
          final count = stats['count'] as int;
          final avgScore = stats['avgScore'] as double;
          final atRiskCount = stats['atRiskCount'] as int;

          return RefreshIndicator(
            onRefresh: provider.loadStudents,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      StatCard(
                        label: 'Students',
                        value: '$count',
                        color: AppTheme.primary,
                        icon: Icons.people_outline_rounded,
                      ),
                      const SizedBox(width: 10),
                      StatCard(
                        label: 'Avg Score',
                        value: '$avgScore',
                        color: AppTheme.success,
                        icon: Icons.trending_up_rounded,
                      ),
                      const SizedBox(width: 10),
                      StatCard(
                        label: 'At Risk',
                        value: '$atRiskCount',
                        color: AppTheme.danger,
                        icon: Icons.warning_amber_rounded,
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  if (gradeDist.isNotEmpty) ...[
                    const SectionHeader(title: 'Grade Distribution'),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: SizedBox(
                          height: 180,
                          child: _GradeBarChart(gradeDist: gradeDist),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],

                  if (topStudents.isNotEmpty) ...[
                    const SectionHeader(title: 'Top Performers'),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
                        child: Column(
                          children: topStudents
                              .take(3)
                              .map((r) => _StudentResultTile(result: r, rank: topStudents.indexOf(r) + 1))
                              .toList(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],

                  SectionHeader(
                    title: 'At-risk Students',
                    trailing: atRiskStudents.isNotEmpty
                        ? Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppTheme.danger.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '${atRiskStudents.length}',
                              style: const TextStyle(
                                  fontSize: 12, color: AppTheme.danger, fontWeight: FontWeight.w600),
                            ),
                          )
                        : null,
                  ),
                  Card(
                    child: atRiskStudents.isEmpty
                        ? const Padding(
                            padding: EdgeInsets.all(20),
                            child: Center(
                              child: Column(
                                children: [
                                  Icon(Icons.check_circle_outline, color: Color(0xFF0F6E56), size: 32),
                                  SizedBox(height: 8),
                                  Text('No at-risk students',
                                      style: TextStyle(color: Color(0xFF0F6E56), fontWeight: FontWeight.w500)),
                                ],
                              ),
                            ),
                          )
                        : Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
                            child: Column(
                              children: atRiskStudents.map((r) => _RiskTile(result: r)).toList(),
                            ),
                          ),
                  ),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _GradeBarChart extends StatelessWidget {
  final Map<String, int> gradeDist;

  const _GradeBarChart({required this.gradeDist});

  @override
  Widget build(BuildContext context) {
    const gradeOrder = ['A+', 'A', 'B', 'C', 'D', 'F'];
    final bars = gradeOrder.where((g) => gradeDist.containsKey(g)).toList();

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: (gradeDist.values.reduce((a, b) => a > b ? a : b) + 1).toDouble(),
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              return BarTooltipItem(
                '${bars[groupIndex]}\n${rod.toY.toInt()} students',
                const TextStyle(color: Colors.white, fontSize: 12),
              );
            },
          ),
        ),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final idx = value.toInt();
                if (idx >= 0 && idx < bars.length) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      bars[idx],
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.gradeColor(bars[idx]),
                      ),
                    ),
                  );
                }
                return const SizedBox();
              },
              reservedSize: 28,
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 24,
              getTitlesWidget: (v, m) => Text(
                v.toInt().toString(),
                style: const TextStyle(fontSize: 10, color: Color(0xFFAAAAAA)),
              ),
            ),
          ),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        gridData: FlGridData(
          show: true,
          getDrawingHorizontalLine: (v) => const FlLine(color: Color(0xFFF0F0F0), strokeWidth: 1),
          drawVerticalLine: false,
        ),
        borderData: FlBorderData(show: false),
        barGroups: bars.asMap().entries.map((e) {
          final idx = e.key;
          final grade = e.value;
          return BarChartGroupData(
            x: idx,
            barRods: [
              BarChartRodData(
                toY: (gradeDist[grade] ?? 0).toDouble(),
                color: AppTheme.gradeColor(grade),
                width: 28,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }
}

class _StudentResultTile extends StatelessWidget {
  final dynamic result;
  final int rank;

  const _StudentResultTile({required this.result, required this.rank});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: rank == 1
                  ? const Color(0xFFFAC775)
                  : rank == 2
                      ? const Color(0xFFD3D1C7)
                      : const Color(0xFFF5C4B3),
              borderRadius: BorderRadius.circular(12),
            ),
            alignment: Alignment.center,
            child: Text(
              '$rank',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: rank == 1
                    ? const Color(0xFF412402)
                    : rank == 2
                        ? const Color(0xFF2C2C2A)
                        : const Color(0xFF4A1B0C),
              ),
            ),
          ),
          const SizedBox(width: 10),
          StudentAvatar(name: result.student.name),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(result.student.name,
                    style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
                Text(result.student.subject,
                    style: const TextStyle(fontSize: 12, color: Color(0xFF888888))),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              GradeBadge(grade: result.grade),
              const SizedBox(height: 2),
              Text('${result.score}', style: const TextStyle(fontSize: 11, color: Color(0xFF888888))),
            ],
          ),
        ],
      ),
    );
  }
}

class _RiskTile extends StatelessWidget {
  final dynamic result;

  const _RiskTile({required this.result});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppTheme.danger.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            alignment: Alignment.center,
            child: Text(
              result.student.name.split(' ').map((n) => n[0]).take(2).join().toUpperCase(),
              style: const TextStyle(
                color: AppTheme.danger,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(result.student.name,
                    style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
                Text(
                  'Attendance: ${result.student.attendance.toInt()}%  ·  Score: ${result.score}',
                  style: const TextStyle(fontSize: 12, color: Color(0xFF888888)),
                ),
              ],
            ),
          ),
          GradeBadge(grade: result.grade),
        ],
      ),
    );
  }
}