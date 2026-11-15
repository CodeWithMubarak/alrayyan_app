import '../../core/constants/app_enums.dart';

class MonthlyReportModel {
  final String id;
  final String circleId;
  final String circleName;
  final String teacherId;
  final String teacherName;
  final String? supervisorId;
  final String? supervisorName;
  final int month;
  final int year;
  final String academicYear;
  final int studentCount;
  final int studyDays;
  final int totalPresent;
  final int totalAbsent;
  final double attendanceRate;
  final String memorizationSummary;
  final String revisionSummary;
  final String? examResults;
  final String? notes;
  final String? recommendations;
  final String preparedBy;
  final String? approvedBy;
  final ReportStatus status;
  final String? pdfUrl;
  final DateTime createdAt;
  final DateTime? updatedAt;

  MonthlyReportModel({
    required this.id,
    required this.circleId,
    required this.circleName,
    required this.teacherId,
    required this.teacherName,
    this.supervisorId,
    this.supervisorName,
    required this.month,
    required this.year,
    this.academicYear = '2026–2027',
    this.studentCount = 0,
    this.studyDays = 0,
    this.totalPresent = 0,
    this.totalAbsent = 0,
    this.attendanceRate = 0.0,
    this.memorizationSummary = '',
    this.revisionSummary = '',
    this.examResults,
    this.notes,
    this.recommendations,
    required this.preparedBy,
    this.approvedBy,
    this.status = ReportStatus.draft,
    this.pdfUrl,
    required this.createdAt,
    this.updatedAt,
  });

  factory MonthlyReportModel.fromMap(Map<String, dynamic> map, String id) {
    ReportStatus repStatus = ReportStatus.draft;
    switch (map['status']) {
      case 'under_review':
        repStatus = ReportStatus.underReview;
        break;
      case 'needs_revision':
        repStatus = ReportStatus.needsRevision;
        break;
      case 'approved':
        repStatus = ReportStatus.approved;
        break;
      case 'archived':
        repStatus = ReportStatus.archived;
        break;
      default:
        repStatus = ReportStatus.draft;
    }

    return MonthlyReportModel(
      id: id,
      circleId: map['circleId'] ?? '',
      circleName: map['circleName'] ?? '',
      teacherId: map['teacherId'] ?? '',
      teacherName: map['teacherName'] ?? '',
      supervisorId: map['supervisorId'],
      supervisorName: map['supervisorName'],
      month: map['month'] ?? DateTime.now().month,
      year: map['year'] ?? DateTime.now().year,
      academicYear: map['academicYear'] ?? '2026–2027',
      studentCount: map['studentCount'] ?? 0,
      studyDays: map['studyDays'] ?? 0,
      totalPresent: map['totalPresent'] ?? 0,
      totalAbsent: map['totalAbsent'] ?? 0,
      attendanceRate: (map['attendanceRate'] ?? 0).toDouble(),
      memorizationSummary: map['memorizationSummary'] ?? '',
      revisionSummary: map['revisionSummary'] ?? '',
      examResults: map['examResults'],
      notes: map['notes'],
      recommendations: map['recommendations'],
      preparedBy: map['preparedBy'] ?? '',
      approvedBy: map['approvedBy'],
      status: repStatus,
      pdfUrl: map['pdfUrl'],
      createdAt: map['createdAt'] != null ? DateTime.tryParse(map['createdAt'].toString()) ?? DateTime.now() : DateTime.now(),
      updatedAt: map['updatedAt'] != null ? DateTime.tryParse(map['updatedAt'].toString()) : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'circleId': circleId,
      'circleName': circleName,
      'teacherId': teacherId,
      'teacherName': teacherName,
      'supervisorId': supervisorId,
      'supervisorName': supervisorName,
      'month': month,
      'year': year,
      'academicYear': academicYear,
      'studentCount': studentCount,
      'studyDays': studyDays,
      'totalPresent': totalPresent,
      'totalAbsent': totalAbsent,
      'attendanceRate': attendanceRate,
      'memorizationSummary': memorizationSummary,
      'revisionSummary': revisionSummary,
      'examResults': examResults,
      'notes': notes,
      'recommendations': recommendations,
      'preparedBy': preparedBy,
      'approvedBy': approvedBy,
      'status': status.value,
      'pdfUrl': pdfUrl,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }
}
