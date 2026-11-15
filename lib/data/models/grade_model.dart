import '../../core/constants/app_enums.dart';

class QuestionGrade {
  final int questionNumber;
  final double grade;
  final double maxGrade;

  QuestionGrade({
    required this.questionNumber,
    required this.grade,
    required this.maxGrade,
  });

  factory QuestionGrade.fromMap(Map<String, dynamic> map) {
    return QuestionGrade(
      questionNumber: map['questionNumber'] ?? 1,
      grade: (map['grade'] ?? 0).toDouble(),
      maxGrade: (map['maxGrade'] ?? 10).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'questionNumber': questionNumber,
      'grade': grade,
      'maxGrade': maxGrade,
    };
  }
}

class GradeModel {
  final String id;
  final String examId;
  final String examName;
  final String studentId;
  final String studentName;
  final String circleId;
  final List<QuestionGrade> questionsGrades;
  final double totalGrade;
  final double fullMark;
  final double percentage;
  final String appreciation; // ممتاز، جيد جداً، جيد، مقبول، ضعيف
  final String? notes;
  final String teacherId;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final SyncStatus syncStatus;

  GradeModel({
    required this.id,
    required this.examId,
    required this.examName,
    required this.studentId,
    required this.studentName,
    required this.circleId,
    required this.questionsGrades,
    required this.totalGrade,
    required this.fullMark,
    required this.percentage,
    required this.appreciation,
    this.notes,
    required this.teacherId,
    required this.createdAt,
    this.updatedAt,
    this.syncStatus = SyncStatus.synced,
  });

  factory GradeModel.fromMap(Map<String, dynamic> map, String id) {
    return GradeModel(
      id: id,
      examId: map['examId'] ?? '',
      examName: map['examName'] ?? '',
      studentId: map['studentId'] ?? '',
      studentName: map['studentName'] ?? '',
      circleId: map['circleId'] ?? '',
      questionsGrades: (map['questionsGrades'] as List<dynamic>?)
              ?.map((q) => QuestionGrade.fromMap(q as Map<String, dynamic>))
              .toList() ??
          [],
      totalGrade: (map['totalGrade'] ?? 0).toDouble(),
      fullMark: (map['fullMark'] ?? 100).toDouble(),
      percentage: (map['percentage'] ?? 0).toDouble(),
      appreciation: map['appreciation'] ?? '',
      notes: map['notes'],
      teacherId: map['teacherId'] ?? '',
      createdAt: map['createdAt'] != null ? DateTime.tryParse(map['createdAt'].toString()) ?? DateTime.now() : DateTime.now(),
      updatedAt: map['updatedAt'] != null ? DateTime.tryParse(map['updatedAt'].toString()) : null,
      syncStatus: SyncStatus.synced,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'examId': examId,
      'examName': examName,
      'studentId': studentId,
      'studentName': studentName,
      'circleId': circleId,
      'questionsGrades': questionsGrades.map((q) => q.toMap()).toList(),
      'totalGrade': totalGrade,
      'fullMark': fullMark,
      'percentage': percentage,
      'appreciation': appreciation,
      'notes': notes,
      'teacherId': teacherId,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }
}
