import '../../core/constants/app_enums.dart';

class MemorizationModel {
  final String id;
  final String studentId;
  final String studentName;
  final String circleId;
  final DateTime date;
  DateTime get sessionDate => date;
  final String surah;
  final int fromAyah;
  final int toAyah;
  final String? amountDescription;
  final MemorizationQuality quality;
  final String? notes;
  final String teacherId;
  final String teacherName;
  final bool isRevision; // هل هو مراجعة أو حفظ جديد
  final DateTime createdAt;
  final DateTime? updatedAt;
  final SyncStatus syncStatus;

  MemorizationModel({
    required this.id,
    required this.studentId,
    required this.studentName,
    required this.circleId,
    required this.date,
    required this.surah,
    required this.fromAyah,
    required this.toAyah,
    this.amountDescription,
    this.quality = MemorizationQuality.excellent,
    this.notes,
    required this.teacherId,
    required this.teacherName,
    this.isRevision = false,
    required this.createdAt,
    this.updatedAt,
    this.syncStatus = SyncStatus.synced,
  });

  factory MemorizationModel.fromMap(Map<String, dynamic> map, String id) {
    MemorizationQuality qual = MemorizationQuality.excellent;
    switch (map['quality']) {
      case 'very_good':
        qual = MemorizationQuality.veryGood;
        break;
      case 'good':
        qual = MemorizationQuality.good;
        break;
      case 'needs_improvement':
        qual = MemorizationQuality.needsImprovement;
        break;
      default:
        qual = MemorizationQuality.excellent;
    }

    return MemorizationModel(
      id: id,
      studentId: map['studentId'] ?? '',
      studentName: map['studentName'] ?? '',
      circleId: map['circleId'] ?? '',
      date: map['date'] != null ? DateTime.tryParse(map['date'].toString()) ?? DateTime.now() : DateTime.now(),
      surah: map['surah'] ?? '',
      fromAyah: map['fromAyah'] ?? 1,
      toAyah: map['toAyah'] ?? 1,
      amountDescription: map['amountDescription'],
      quality: qual,
      notes: map['notes'],
      teacherId: map['teacherId'] ?? '',
      teacherName: map['teacherName'] ?? '',
      isRevision: map['isRevision'] ?? false,
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
      'date': date.toIso8601String(),
      'surah': surah,
      'fromAyah': fromAyah,
      'toAyah': toAyah,
      'amountDescription': amountDescription,
      'quality': quality.value,
      'notes': notes,
      'teacherId': teacherId,
      'teacherName': teacherName,
      'isRevision': isRevision,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }
}
