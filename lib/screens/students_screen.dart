import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/student.dart';
import '../utils/app_theme.dart';
import '../utils/ml_predictor.dart';
import '../utils/student_provider.dart';
import '../widgets/common_widgets.dart';

class StudentsScreen extends StatelessWidget {
  const StudentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Students'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 0.5, color: AppTheme.border),
        ),
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Consumer<StudentProvider>(
              builder: (context, provider, _) => TextField(
                decoration: const InputDecoration(
                  hintText: 'Search by name or subject...',
                  prefixIcon: Icon(Icons.search, size: 20, color: Color(0xFF888888)),
                ),
                onChanged: provider.setSearchQuery,
              ),
            ),
          ),
          const SizedBox(height: 8),

          // List
          Expanded(
            child: Consumer<StudentProvider>(
              builder: (context, provider, _) {
                if (provider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                final students = provider.filteredStudents;

                if (students.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.people_outline, size: 48, color: Colors.grey[300]),
                        const SizedBox(height: 12),
                        const Text('No students found',
                            style: TextStyle(color: Color(0xFF888888), fontSize: 15)),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
                  itemCount: students.length,
                  itemBuilder: (context, index) {
                    return _StudentCard(student: students[index]);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _StudentCard extends StatelessWidget {
  final Student student;

  const _StudentCard({required this.student});

  @override
  Widget build(BuildContext context) {
    final result = MLPredictor.predict(student);
    final color = AppTheme.gradeColor(result.grade);

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => _showDetail(context, result),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              StudentAvatar(name: student.name),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(student.name,
                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                    const SizedBox(height: 2),
                    Text(student.subject,
                        style: const TextStyle(fontSize: 12, color: Color(0xFF888888))),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        _chip(Icons.event_available_outlined,
                            '${student.attendance.toInt()}%',
                            student.attendance >= 75 ? AppTheme.success : AppTheme.danger),
                        const SizedBox(width: 8),
                        _chip(Icons.quiz_outlined, '${result.score}', color),
                      ],
                    ),
                  ],
                ),
              ),
              Column(
                children: [
                  GradeBadge(grade: result.grade, fontSize: 14),
                  const SizedBox(height: 4),
                  const Icon(Icons.chevron_right, size: 16, color: Color(0xFFCCCCCC)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _chip(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Icon(icon, size: 11, color: color),
          const SizedBox(width: 3),
          Text(label, style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  void _showDetail(BuildContext context, PredictionResult result) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _StudentDetailSheet(result: result),
    );
  }
}

class _StudentDetailSheet extends StatelessWidget {
  final PredictionResult result;

  const _StudentDetailSheet({required this.result});

  @override
  Widget build(BuildContext context) {
    final color = AppTheme.gradeColor(result.grade);
    final s = result.student;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 36),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: const Color(0xFFDDDDDD),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),

          // Header
          Row(
            children: [
              StudentAvatar(name: s.name, size: 52),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(s.name,
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                    Text(s.subject,
                        style: const TextStyle(fontSize: 14, color: Color(0xFF888888))),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    result.grade,
                    style: TextStyle(fontSize: 32, fontWeight: FontWeight.w700, color: color),
                  ),
                  RiskBadge(risk: result.riskLevel),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Progress bar
          ScoreProgressBar(score: result.score, color: color),
          const SizedBox(height: 20),

          // Detail grid
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFF8F9FA),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                _detailRow('Attendance', '${s.attendance.toInt()}%',
                    s.attendance >= 75 ? AppTheme.success : AppTheme.danger),
                const Divider(height: 16, color: Color(0xFFEEEEEE)),
                _detailRow('Mid-term score', '${s.midtermScore.toInt()} / 100', color),
                const Divider(height: 16, color: Color(0xFFEEEEEE)),
                _detailRow('Assignment average', '${s.assignmentAvg.toInt()} / 100', color),
                const Divider(height: 16, color: Color(0xFFEEEEEE)),
                _detailRow('Quiz average', '${s.quizAvg.toInt()} / 100', color),
              ],
            ),
          ),

          if (result.feedback.isNotEmpty) ...[
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.05),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: color.withOpacity(0.2), width: 0.5),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.lightbulb_outline, size: 16, color: color),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      result.feedback,
                      style: TextStyle(fontSize: 13, color: color.withOpacity(0.8)),
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 14),

          // Delete button
          if (s.id != null)
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _confirmDelete(context),
                    icon: const Icon(Icons.delete_outline, size: 16, color: AppTheme.danger),
                    label: const Text('Delete', style: TextStyle(color: AppTheme.danger)),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppTheme.danger, width: 0.5),
                      minimumSize: const Size.fromHeight(46),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(46),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Done'),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 13, color: Color(0xFF666666))),
        Text(value,
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: color)),
      ],
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete student?'),
        content: Text('Remove ${result.student.name} from the database?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              context.read<StudentProvider>().deleteStudent(result.student.id!);
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('Delete', style: TextStyle(color: AppTheme.danger)),
          ),
        ],
      ),
    );
  }
}