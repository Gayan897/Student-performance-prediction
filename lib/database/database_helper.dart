import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:st_performance_predictor/models/student.dart';


class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('student_predictor.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE students (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        subject TEXT NOT NULL,
        attendance REAL NOT NULL,
        midterm_score REAL NOT NULL,
        assignment_avg REAL NOT NULL,
        quiz_avg REAL NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');

    // Seed sample data
    final samples = [
      Student(name: 'Kavindu Perera', subject: 'Mathematics', attendance: 82, midtermScore: 78, assignmentAvg: 80, quizAvg: 75),
      Student(name: 'Nimesha Silva', subject: 'Science', attendance: 91, midtermScore: 88, assignmentAvg: 85, quizAvg: 90),
      Student(name: 'Dilshan Fernando', subject: 'ICT', attendance: 65, midtermScore: 52, assignmentAvg: 58, quizAvg: 48),
      Student(name: 'Sachini Jayawardena', subject: 'English', attendance: 95, midtermScore: 94, assignmentAvg: 92, quizAvg: 89),
      Student(name: 'Ruwan Bandara', subject: 'History', attendance: 70, midtermScore: 63, assignmentAvg: 67, quizAvg: 61),
      Student(name: 'Thisara Wickrama', subject: 'Mathematics', attendance: 88, midtermScore: 81, assignmentAvg: 79, quizAvg: 82),
      Student(name: 'Minoli Ranasinghe', subject: 'Science', attendance: 55, midtermScore: 44, assignmentAvg: 50, quizAvg: 42),
      Student(name: 'Ashen Gunaratne', subject: 'ICT', attendance: 78, midtermScore: 72, assignmentAvg: 74, quizAvg: 70),
    ];

    for (final s in samples) {
      await db.insert('students', s.toMap());
    }
  }

  Future<int> insertStudent(Student student) async {
    final db = await database;
    return await db.insert('students', student.toMap());
  }

  Future<List<Student>> getAllStudents() async {
    final db = await database;
    final maps = await db.query('students', orderBy: 'name ASC');
    return maps.map((m) => Student.fromMap(m)).toList();
  }

  Future<int> updateStudent(Student student) async {
    final db = await database;
    return await db.update(
      'students',
      student.toMap(),
      where: 'id = ?',
      whereArgs: [student.id],
    );
  }

  Future<int> deleteStudent(int id) async {
    final db = await database;
    return await db.delete('students', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Student>> searchStudents(String query) async {
    final db = await database;
    final maps = await db.query(
      'students',
      where: 'name LIKE ? OR subject LIKE ?',
      whereArgs: ['%$query%', '%$query%'],
      orderBy: 'name ASC',
    );
    return maps.map((m) => Student.fromMap(m)).toList();
  }

  Future close() async {
    final db = await database;
    db.close();
  }
}