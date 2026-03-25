import 'package:flutter/foundation.dart';
import '../models/student.dart';
import '../database/database_helper.dart';
import '../utils/ml_predictor.dart';

class StudentProvider extends ChangeNotifier {
  List<Student> _students = [];
  bool _isLoading = false;
  String _searchQuery = '';

  List<Student> get students => _students;
  bool get isLoading => _isLoading;
  String get searchQuery => _searchQuery;

  List<Student> get filteredStudents {
    if (_searchQuery.isEmpty) return _students;
    return _students
        .where((s) =>
            s.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            s.subject.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();
  }

  Map<String, dynamic> get dashboardStats => MLPredictor.batchStats(_students);

  Future<void> loadStudents() async {
    _isLoading = true;
    notifyListeners();
    _students = await DatabaseHelper.instance.getAllStudents();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> addStudent(Student student) async {
    final id = await DatabaseHelper.instance.insertStudent(student);
    _students.add(student.copyWith(id: id));
    _students.sort((a, b) => a.name.compareTo(b.name));
    notifyListeners();
  }

  Future<void> updateStudent(Student student) async {
    await DatabaseHelper.instance.updateStudent(student);
    final index = _students.indexWhere((s) => s.id == student.id);
    if (index != -1) {
      _students[index] = student;
      notifyListeners();
    }
  }

  Future<void> deleteStudent(int id) async {
    await DatabaseHelper.instance.deleteStudent(id);
    _students.removeWhere((s) => s.id == id);
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  PredictionResult predictForStudent(Student student) {
    return MLPredictor.predict(student);
  }
}