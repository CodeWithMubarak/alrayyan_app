import '../../core/constants/app_enums.dart';

class ExamQuestion {
  final int questionNumber;
  final String description;
  final double maxGrade;

  ExamQuestion({
    required this.questionNumber,
    required this.description,
    required this.maxGrade,
  });

  factory ExamQuestion.fromMap(Map<String, dynamic> map) {
    return ExamQuestion(
      questionNumber: map['questionNumber'] ?? 1,
      description: map['description'] ?? '',
      maxGrade: (map['maxGrade'] ?? 10).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'questionNumber': questionNumber,
      'description': description,
      'maxGrade': maxGrade,
    };
  }
}

class ExamModel {
  final String id;
  final String name;
  final String circleId;
  final String circleName;
  final DateTime date;
  final ExamType type;
  final String subject;
  final double fullMark;
  final int questionCount;
  final List<ExamQuestion> questionsBreakdown;
  final String? notes;
  final String createdBy;
  final DateTime createdAt;
  final DateTime? updatedAt;

  ExamModel({
    required this.id,
    required this.name,
    required this.circleId,
    required this.circleName,
    required this.date,
    required this.type,
    required this.subject,
    required this.fullMark,
    required this.questionCount,
    this.questionsBreakdown = const [],
    this.notes,
    required this.createdBy,
    required this.createdAt,
    this.updatedAt,
  });

  factory ExamModel.fromMap(Map<String, dynamic> map, String id) {
    ExamType exType = ExamType.memorization;
    switch (map['type']) {
      case 'revision':
        exType = ExamType.revision;
        break;
      case 'arabic':
        exType = ExamType.arabic;
        break;
      case 'islamic_studies':
        exType = ExamType.islamicStudies;
        break;
      case 'general':
        exType = ExamType.general;
        break;
      default:
        exType = ExamType.memorization;
    }

    return ExamModel(
      id: id,
      name: map['name'] ?? '',
      circleId: map['circleId'] ?? '',
      circleName: map['circleName'] ?? '',
      date: map['date'] != null ? DateTime.tryParse(map['date'].toString()) ?? DateTime.now() : DateTime.now(),
      type: exType,
      subject: map['subject'] ?? '',
      fullMark: (map['fullMark'] ?? 100).toDouble(),
      questionCount: map['questionCount'] ?? 1,
      questionsBreakdown: (map['questionsBreakdown'] as List<dynamic>?)
              ?.map((q) => ExamQuestion.fromMap(q as Map<String, dynamic>))
              .toList() ??
          [],
      notes: map['notes'],
      createdBy: map['createdBy'] ?? '',
      createdAt: map['createdAt'] != null ? DateTime.tryParse(map['createdAt'].toString()) ?? DateTime.now() : DateTime.now(),
      updatedAt: map['updatedAt'] != null ? DateTime.tryParse(map['updatedAt'].toString()) : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'circleId': circleId,
      'circleName': circleName,
      'date': date.toIso8601String(),
      'type': type.value,
      'subject': subject,
      'fullMark': fullMark,
      'questionCount': questionCount,
      'questionsBreakdown': questionsBreakdown.map((q) => q.toMap()).toList(),
      'notes': notes,
      'createdBy': createdBy,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }
}
