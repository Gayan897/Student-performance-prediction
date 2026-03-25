import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/student.dart';
import '../utils/app_theme.dart';
import '../utils/student_provider.dart';
import '../widgets/common_widgets.dart';

class PredictScreen extends StatefulWidget {
  const PredictScreen({super.key});

  @override
  State<PredictScreen> createState() => _PredictScreenState();
}

class _PredictScreenState extends State<PredictScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  String _subject = 'Mathematics';
  double _attendance = 75;
  final _midtermCtrl = TextEditingController(text: '70');
  final _assignCtrl = TextEditingController(text: '70');
  final _quizCtrl = TextEditingController(text: '70');

  PredictionResult? _result;
  bool _showResult = false;

  final List<String> _subjects = ['Mathematics', 'Science', 'English', 'ICT', 'History', 'Commerce'];

  @override
  void dispose() {
    _nameCtrl.dispose();
    _midtermCtrl.dispose();
    _assignCtrl.dispose();
    _quizCtrl.dispose();
    super.dispose();
  }

  void _predict() {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();

    final student = Student(
      name: _nameCtrl.text.trim(),
      subject: _subject,
      attendance: _attendance,
      midtermScore: double.parse(_midtermCtrl.text),
      assignmentAvg: double.parse(_assignCtrl.text),
      quizAvg: double.parse(_quizCtrl.text),
    );

    final result = context.read<StudentProvider>().predictForStudent(student);
    setState(() {
      _result = result;
      _showResult = true;
    });
  }

  Future<void> _saveStudent() async {
    if (_result == null) return;
    await context.read<StudentProvider>().addStudent(_result!.student);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${_result!.student.name} saved successfully'),
          backgroundColor: AppTheme.success,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Predict Grade'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 0.5, color: AppTheme.border),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Student info card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Student info',
                          style: TextStyle(fontSize: 12, color: Color(0xFF888888))),
                      const SizedBox(height: 12),
                      LabeledField(
                        label: 'Full name',
                        child: TextFormField(
                          controller: _nameCtrl,
                          decoration: const InputDecoration(hintText: 'e.g. Kavindu Perera'),
                          validator: (v) => (v == null || v.isEmpty) ? 'Name is required' : null,
                        ),
                      ),
                      const SizedBox(height: 12),
                      LabeledField(
                        label: 'Subject',
                        child: DropdownButtonFormField<String>(
                          value: _subject,
                          decoration: const InputDecoration(),
                          items: _subjects
                              .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                              .toList(),
                          onChanged: (v) => setState(() => _subject = v!),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Attendance card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Attendance',
                              style: TextStyle(fontSize: 12, color: Color(0xFF888888))),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                            decoration: BoxDecoration(
                              color: _attendance >= 75
                                  ? AppTheme.success.withOpacity(0.1)
                                  : AppTheme.danger.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              '${_attendance.toInt()}%',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                                color: _attendance >= 75 ? AppTheme.success : AppTheme.danger,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Slider(
                        value: _attendance,
                        min: 0,
                        max: 100,
                        divisions: 100,
                        activeColor: _attendance >= 75 ? AppTheme.success : AppTheme.danger,
                        onChanged: (v) => setState(() => _attendance = v),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('0%', style: TextStyle(fontSize: 11, color: Colors.grey[400])),
                          Text('75% minimum', style: TextStyle(fontSize: 11, color: Colors.grey[400])),
                          Text('100%', style: TextStyle(fontSize: 11, color: Colors.grey[400])),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // Past marks card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Past marks (0 – 100)',
                          style: TextStyle(fontSize: 12, color: Color(0xFF888888))),
                      const SizedBox(height: 12),
                      LabeledField(
                        label: 'Mid-term score',
                        child: TextFormField(
                          controller: _midtermCtrl,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(hintText: '0 – 100'),
                          validator: _validateScore,
                        ),
                      ),
                      const SizedBox(height: 12),
                      LabeledField(
                        label: 'Assignment average',
                        child: TextFormField(
                          controller: _assignCtrl,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(hintText: '0 – 100'),
                          validator: _validateScore,
                        ),
                      ),
                      const SizedBox(height: 12),
                      LabeledField(
                        label: 'Quiz average',
                        child: TextFormField(
                          controller: _quizCtrl,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(hintText: '0 – 100'),
                          validator: _validateScore,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              ElevatedButton.icon(
                onPressed: _predict,
                icon: const Icon(Icons.auto_graph_rounded),
                label: const Text('Predict Performance'),
              ),

              if (_showResult && _result != null) ...[
                const SizedBox(height: 16),
                _buildResultCard(_result!),
              ],

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResultCard(PredictionResult result) {
    final color = AppTheme.gradeColor(result.grade);
    return Column(
      children: [
        // Grade hero
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 24),
          decoration: BoxDecoration(
            color: color.withOpacity(0.07),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withOpacity(0.3), width: 0.5),
          ),
          child: Column(
            children: [
              Text(
                '${AppTheme.gradeEmoji(result.grade)}  ${result.student.name}',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: color),
              ),
              const SizedBox(height: 8),
              Text(
                result.grade,
                style: TextStyle(fontSize: 64, fontWeight: FontWeight.w700, color: color, height: 1),
              ),
              const SizedBox(height: 4),
              Text('Predicted grade', style: TextStyle(fontSize: 13, color: color.withOpacity(0.7))),
              const SizedBox(height: 10),
              RiskBadge(risk: result.riskLevel),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Score breakdown
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                ScoreProgressBar(score: result.score, color: color),
                const SizedBox(height: 16),
                const Divider(height: 1, color: Color(0xFFEEEEEE)),
                const SizedBox(height: 14),
                Row(
                  children: [
                    _miniStat('Attendance', '${result.student.attendance.toInt()}%'),
                    _miniStat('Mid-term', '${result.student.midtermScore.toInt()}'),
                    _miniStat('Assignments', '${result.student.assignmentAvg.toInt()}'),
                    _miniStat('Quizzes', '${result.student.quizAvg.toInt()}'),
                  ],
                ),
                if (result.feedback.isNotEmpty) ...[
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F5F5),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.info_outline, size: 16, color: Color(0xFF888888)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            result.feedback,
                            style: const TextStyle(fontSize: 13, color: Color(0xFF555555)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),

        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => setState(() => _showResult = false),
                icon: const Icon(Icons.close, size: 16),
                label: const Text('Clear'),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(46),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _saveStudent,
                icon: const Icon(Icons.save_outlined, size: 16),
                label: const Text('Save'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(46),
                  backgroundColor: AppTheme.success,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _miniStat(String label, String value) {
    return Expanded(
      child: Column(
        children: [
          Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          Text(label, style: const TextStyle(fontSize: 10, color: Color(0xFF888888))),
        ],
      ),
    );
  }

  String? _validateScore(String? v) {
    if (v == null || v.isEmpty) return 'Required';
    final n = double.tryParse(v);
    if (n == null || n < 0 || n > 100) return '0 – 100 only';
    return null;
  }
}