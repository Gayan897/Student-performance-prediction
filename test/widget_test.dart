import 'package:flutter_test/flutter_test.dart';
import 'package:st_performance_predictor/models/student.dart';
import 'package:st_performance_predictor/utils/ml_predictor.dart';


void main() {
  group('MLPredictor tests', () {
    test('predicts A+ for excellent student', () {
      final student = Student(
        name: 'Test Student',
        subject: 'Mathematics',
        attendance: 95,
        midtermScore: 90,
        assignmentAvg: 88,
        quizAvg: 92,
      );
      final result = MLPredictor.predict(student);
      expect(result.grade, equals('A+'));
      expect(result.score, greaterThanOrEqualTo(85));
    });

    test('predicts F for failing student', () {
      final student = Student(
        name: 'Test Student',
        subject: 'Science',
        attendance: 30,
        midtermScore: 20,
        assignmentAvg: 25,
        quizAvg: 15,
      );
      final result = MLPredictor.predict(student);
      expect(result.grade, equals('F'));
      expect(result.score, lessThan(45));
    });

    test('predicts B for average student', () {
      final student = Student(
        name: 'Test Student',
        subject: 'English',
        attendance: 75,
        midtermScore: 68,
        assignmentAvg: 70,
        quizAvg: 65,
      );
      final result = MLPredictor.predict(student);
      expect(result.grade, equals('B'));
      expect(result.score, inInclusiveRange(65, 74));
    });

    test('score is weighted correctly', () {
      final student = Student(
        name: 'Test Student',
        subject: 'ICT',
        attendance: 100,
        midtermScore: 100,
        assignmentAvg: 100,
        quizAvg: 100,
      );
      final result = MLPredictor.predict(student);
      expect(result.score, equals(100.0));
    });

    test('at risk flag for low score', () {
      final student = Student(
        name: 'Test Student',
        subject: 'History',
        attendance: 50,
        midtermScore: 40,
        assignmentAvg: 45,
        quizAvg: 38,
      );
      final result = MLPredictor.predict(student);
      expect(result.riskLevel, anyOf(['At Risk', 'Critical', 'Below Average']));
    });

    test('batch stats returns correct count', () {
      final students = [
        Student(name: 'A', subject: 'Math', attendance: 90, midtermScore: 85, assignmentAvg: 88, quizAvg: 82),
        Student(name: 'B', subject: 'Math', attendance: 60, midtermScore: 50, assignmentAvg: 55, quizAvg: 48),
        Student(name: 'C', subject: 'Math', attendance: 75, midtermScore: 70, assignmentAvg: 72, quizAvg: 68),
      ];
      final stats = MLPredictor.batchStats(students);
      expect(stats['count'], equals(3));
      expect(stats['avgScore'], isA<double>());
      expect(stats['gradeDist'], isA<Map<String, int>>());
    });

    test('empty batch returns zero count', () {
      final stats = MLPredictor.batchStats([]);
      expect(stats['count'], equals(0));
      expect(stats['avgScore'], equals(0.0));
    });
  });
}