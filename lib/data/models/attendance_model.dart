import '../../core/constants/app_enums.dart';

class AttendanceModel {
  final String id;
  final String studentId;
  final String studentName;
  final String circleId;
  final String circleName;
  final DateTime date;
  final String dayName;
  final AttendanceStatus status;
  final String? notes;
  final String teacherId;
  final String teacherName;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final SyncStatus syncStatus;

  AttendanceModel({
    required this.id,
    required this.studentId,
    required this.studentName,
    required this.circleId,
    required this.circleName,
    required this.date,
    required this.dayName,
    required this.status,
    this.notes,
    required this.teacherId,
    required this.teacherName,
    required this.createdAt,
    this.updatedAt,
    this.syncStatus = SyncStatus.synced,
  });

  factory AttendanceModel.fromMap(Map<String, dynamic> map, String id) {
    AttendanceStatus attStatus = AttendanceStatus.present;
    switch (map['status']) {
      case 'absent':
        attStatus = AttendanceStatus.absent;
        break;
      case 'late':
        attStatus = AttendanceStatus.late;
        break;
      case 'excused_absent':
      case 'excused':
        attStatus = AttendanceStatus.excusedAbsent;
        break;
      default:
        attStatus = AttendanceStatus.present;
    }

    return AttendanceModel(
      id: id,
      studentId: map['studentId'] ?? '',
      studentName: map['studentName'] ?? '',
      circleId: map['circleId'] ?? '',
      circleName: map['circleName'] ?? '',
      date: map['date'] != null ? DateTime.tryParse(map['date'].toString()) ?? DateTime.now() : DateTime.now(),
      dayName: map['dayName'] ?? '',
      status: attStatus,
      notes: map['notes'],
      teacherId: map['teacherId'] ?? '',
      teacherName: map['teacherName'] ?? '',
      createdAt: map['createdAt'] != null ? DateTime.tryParse(map['createdAt'].toString()) ?? DateTime.now() : DateTime.now(),
      updatedAt: map['updatedAt'] != null ? DateTime.tryParse(map['updatedAt'].toString()) : null,
      syncStatus: SyncStatus.synced,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'studentId': studentId,
      'studentName': studentName,
      'circleId': circleId,
      'circleName': circleName,
      'date': date.toIso8601String(),
      'dayName': dayName,
      'status': status.value,
      'notes': notes,
      'teacherId': teacherId,
      'teacherName': teacherName,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }
}
