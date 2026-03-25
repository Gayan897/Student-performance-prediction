class Student {
  final int? id;
  final String name;
  final String subject;
  final double attendance;
  final double midtermScore;
  final double assignmentAvg;
  final double quizAvg;
  final DateTime createdAt;

  Student({
    this.id,
    required this.name,
    required this.subject,
    required this.attendance,
    required this.midtermScore,
    required this.assignmentAvg,
    required this.quizAvg,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'subject': subject,
      'attendance': attendance,
      'midterm_score': midtermScore,
      'assignment_avg': assignmentAvg,
      'quiz_avg': quizAvg,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory Student.fromMap(Map<String, dynamic> map) {
    return Student(
      id: map['id'],
      name: map['name'],
      subject: map['subject'],
      attendance: map['attendance'].toDouble(),
      midtermScore: map['midterm_score'].toDouble(),
      assignmentAvg: map['assignment_avg'].toDouble(),
      quizAvg: map['quiz_avg'].toDouble(),
      createdAt: DateTime.parse(map['created_at']),
    );
  }

  Student copyWith({
    int? id,
    String? name,
    String? subject,
    double? attendance,
    double? midtermScore,
    double? assignmentAvg,
    double? quizAvg,
  }) {
    return Student(
      id: id ?? this.id,
      name: name ?? this.name,
      subject: subject ?? this.subject,
      attendance: attendance ?? this.attendance,
      midtermScore: midtermScore ?? this.midtermScore,
      assignmentAvg: assignmentAvg ?? this.assignmentAvg,
      quizAvg: quizAvg ?? this.quizAvg,
      createdAt: createdAt,
    );
  }
}

class PredictionResult {
  final Student student;
  final double score;
  final String grade;
  final String riskLevel;
  final String feedback;

  PredictionResult({
    required this.student,
    required this.score,
    required this.grade,
    required this.riskLevel,
    required this.feedback,
  });
}