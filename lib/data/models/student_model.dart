import '../../core/constants/app_enums.dart';

class StudentModel {
  final String id;
  final String studentNumber;
  final String fullName;
  final String? photoUrl;
  final DateTime? birthDate;
  final DateTime enrollmentDate;
  final String circleId;
  final String circleName;
  final String level;
  final StudentStatus status;
  final String guardianName;
  final String guardianRelation;
  final String guardianPhone;
  final String? guardianPhone2;
  final String? address;
  final String? adminNotes;
  final String? educationalNotes;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? createdBy;
  final String? updatedBy;

  StudentModel({
    required this.id,
    required this.studentNumber,
    required this.fullName,
    this.photoUrl,
    this.birthDate,
    required this.enrollmentDate,
    required this.circleId,
    required this.circleName,
    required this.level,
    this.status = StudentStatus.active,
    required this.guardianName,
    required this.guardianRelation,
    required this.guardianPhone,
    this.guardianPhone2,
    this.address,
    this.adminNotes,
    this.educationalNotes,
    required this.createdAt,
    this.updatedAt,
    this.createdBy,
    this.updatedBy,
  });

  factory StudentModel.fromMap(Map<String, dynamic> map, String id) {
    return StudentModel(
      id: id,
      studentNumber: map['studentNumber'] ?? '',
      fullName: map['fullName'] ?? '',
      photoUrl: map['photoUrl'],
      birthDate: map['birthDate'] != null ? DateTime.tryParse(map['birthDate'].toString()) : null,
      enrollmentDate: map['enrollmentDate'] != null ? DateTime.tryParse(map['enrollmentDate'].toString()) ?? DateTime.now() : DateTime.now(),
      circleId: map['circleId'] ?? '',
      circleName: map['circleName'] ?? '',
      level: map['level'] ?? '',
      status: StudentStatusExtension.fromString(map['status'] ?? 'active'),
      guardianName: map['guardianName'] ?? '',
      guardianRelation: map['guardianRelation'] ?? '',
      guardianPhone: map['guardianPhone'] ?? '',
      guardianPhone2: map['guardianPhone2'],
      address: map['address'],
      adminNotes: map['adminNotes'],
      educationalNotes: map['educationalNotes'],
      createdAt: map['createdAt'] != null ? DateTime.tryParse(map['createdAt'].toString()) ?? DateTime.now() : DateTime.now(),
      updatedAt: map['updatedAt'] != null ? DateTime.tryParse(map['updatedAt'].toString()) : null,
      createdBy: map['createdBy'],
      updatedBy: map['updatedBy'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'studentNumber': studentNumber,
      'fullName': fullName,
      'photoUrl': photoUrl,
      'birthDate': birthDate?.toIso8601String(),
      'enrollmentDate': enrollmentDate.toIso8601String(),
      'circleId': circleId,
      'circleName': circleName,
      'level': level,
      'status': status.value,
      'guardianName': guardianName,
      'guardianRelation': guardianRelation,
      'guardianPhone': guardianPhone,
      'guardianPhone2': guardianPhone2,
      'address': address,
      'adminNotes': adminNotes,
      'educationalNotes': educationalNotes,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'createdBy': createdBy,
      'updatedBy': updatedBy,
    };
  }
}
