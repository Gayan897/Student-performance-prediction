
import 'dart:math';

import 'package:st_performance_predictor/models/student.dart';

class MLPredictor {
  // Weighted regression model
  // Weights tuned for academic performance prediction
  static const double _attendanceWeight = 0.25;
  static const double _midtermWeight = 0.35;
  static const double _assignmentWeight = 0.25;
  static const double _quizWeight = 0.15;

  static PredictionResult predict(Student student) {
    final score = _calculateScore(
      student.attendance,
      student.midtermScore,
      student.assignmentAvg,
      student.quizAvg,
    );

    final grade = _scoreToGrade(score);
    final risk = _assessRisk(score, student.attendance);
    final feedback = _generateFeedback(student, score);

    return PredictionResult(
      student: student,
      score: score,
      grade: grade,
      riskLevel: risk,
      feedback: feedback,
    );
  }

  static double _calculateScore(
    double attendance,
    double midterm,
    double assignment,
    double quiz,
  ) {
    final raw = attendance * _attendanceWeight +
        midterm * _midtermWeight +
        assignment * _assignmentWeight +
        quiz * _quizWeight;
    return double.parse(raw.toStringAsFixed(1));
  }

  static String _scoreToGrade(double score) {
    if (score >= 85) return 'A+';
    if (score >= 75) return 'A';
    if (score >= 65) return 'B';
    if (score >= 55) return 'C';
    if (score >= 45) return 'D';
    return 'F';
  }

  static String _assessRisk(double score, double attendance) {
    if (score >= 80 && attendance >= 85) return 'Excellent';
    if (score >= 70) return 'Good';
    if (score >= 60) return 'Average';
    if (score >= 50) return 'Below Average';
    if (score >= 40 || attendance < 60) return 'At Risk';
    return 'Critical';
  }

  static String _generateFeedback(Student student, double score) {
    final issues = <String>[];
    final strengths = <String>[];

    if (student.attendance < 60) {
      issues.add('Attendance is critically low (${student.attendance.toInt()}%). Minimum 75% required.');
    } else if (student.attendance < 75) {
      issues.add('Attendance needs improvement (${student.attendance.toInt()}%).');
    } else {
      strengths.add('Good attendance (${student.attendance.toInt()}%).');
    }

    if (student.midtermScore < 50) {
      issues.add('Mid-term score (${student.midtermScore.toInt()}) is below passing mark.');
    } else if (student.midtermScore >= 75) {
      strengths.add('Strong mid-term performance (${student.midtermScore.toInt()}).');
    }

    if (student.assignmentAvg < 50) {
      issues.add('Assignment average is low (${student.assignmentAvg.toInt()}).');
    }

    if (issues.isEmpty) return 'Student is performing well. Keep up the good work!';
    return issues.join(' ');
  }

  // Batch prediction for dashboard stats
  static Map<String, dynamic> batchStats(List<Student> students) {
    if (students.isEmpty) {
      return {
        'count': 0,
        'avgScore': 0.0,
        'atRiskCount': 0,
        'gradeDist': <String, int>{},
        'topStudents': <PredictionResult>[],
        'atRiskStudents': <PredictionResult>[],
      };
    }

    final results = students.map((s) => predict(s)).toList();
    results.sort((a, b) => b.score.compareTo(a.score));

    final avgScore = results.fold(0.0, (sum, r) => sum + r.score) / results.length;
    final atRisk = results.where((r) => r.score < 55).toList();

    final gradeDist = <String, int>{};
    for (final r in results) {
      gradeDist[r.grade] = (gradeDist[r.grade] ?? 0) + 1;
    }

    return {
      'count': students.length,
      'avgScore': double.parse(avgScore.toStringAsFixed(1)),
      'atRiskCount': atRisk.length,
      'gradeDist': gradeDist,
      'topStudents': results.take(3).toList(),
      'atRiskStudents': atRisk,
      'allResults': results,
    };
  }
}