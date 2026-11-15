import '../../core/constants/app_enums.dart';

class FeeModel {
  final String id;
  final String studentId;
  final String studentName;
  final String circleId;
  final int month;
  final int year;
  final double amountDue;
  final double amountPaid;
  final double amountRemaining;
  final DateTime? paymentDate;
  final String? paymentMethod;
  final String? receiverName;
  final String? notes;
  final FeeStatus status;
  final String createdBy;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final SyncStatus syncStatus;

  FeeModel({
    required this.id,
    required this.studentId,
    required this.studentName,
    required this.circleId,
    required this.month,
    required this.year,
    required this.amountDue,
    required this.amountPaid,
    required this.amountRemaining,
    this.paymentDate,
    this.paymentMethod,
    this.receiverName,
    this.notes,
    required this.status,
    required this.createdBy,
    required this.createdAt,
    this.updatedAt,
    this.syncStatus = SyncStatus.synced,
  });

  factory FeeModel.fromMap(Map<String, dynamic> map, String id) {
    FeeStatus fStatus = FeeStatus.unpaid;
    switch (map['status']) {
      case 'paid':
        fStatus = FeeStatus.paid;
        break;
      case 'partial':
        fStatus = FeeStatus.partial;
        break;
      case 'exempt':
        fStatus = FeeStatus.exempt;
        break;
      default:
        fStatus = FeeStatus.unpaid;
    }

    return FeeModel(
      id: id,
      studentId: map['studentId'] ?? '',
      studentName: map['studentName'] ?? '',
      circleId: map['circleId'] ?? '',
      month: map['month'] ?? DateTime.now().month,
      year: map['year'] ?? DateTime.now().year,
      amountDue: (map['amountDue'] ?? 0).toDouble(),
      amountPaid: (map['amountPaid'] ?? 0).toDouble(),
      amountRemaining: (map['amountRemaining'] ?? 0).toDouble(),
      paymentDate: map['paymentDate'] != null ? DateTime.tryParse(map['paymentDate'].toString()) : null,
      paymentMethod: map['paymentMethod'],
      receiverName: map['receiverName'],
      notes: map['notes'],
      status: fStatus,
      createdBy: map['createdBy'] ?? '',
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
      'month': month,
      'year': year,
      'amountDue': amountDue,
      'amountPaid': amountPaid,
      'amountRemaining': amountRemaining,
      'paymentDate': paymentDate?.toIso8601String(),
      'paymentMethod': paymentMethod,
      'receiverName': receiverName,
      'notes': notes,
      'status': status.value,
      'createdBy': createdBy,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }
}
