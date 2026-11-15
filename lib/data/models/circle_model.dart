import '../../core/constants/app_enums.dart';

class CircleModel {
  final String id;
  final String circleCode; // كود الحلقة الفريد لتسجيل الدخول السريع
  final String accessPassword; // كلمة مرور الحلقة التي ينشئها المدير ويوزعها على المدرس
  final String name;
  final String teacherId;
  final String teacherName;
  final String? supervisorId;
  final String? supervisorName;
  final String level;
  final String stage;
  final List<String> studyDays;
  final String startTime;
  final String endTime;
  final int studentCount;
  final String location;
  final CircleStatus status;
  final String? notes;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? createdBy;
  final String? updatedBy;

  CircleModel({
    required this.id,
    required this.circleCode,
    required this.accessPassword,
    required this.name,
    required this.teacherId,
    required this.teacherName,
    this.supervisorId,
    this.supervisorName,
    required this.level,
    required this.stage,
    required this.studyDays,
    required this.startTime,
    required this.endTime,
    this.studentCount = 0,
    required this.location,
    this.status = CircleStatus.active,
    this.notes,
    required this.createdAt,
    this.updatedAt,
    this.createdBy,
    this.updatedBy,
  });

  factory CircleModel.fromMap(Map<String, dynamic> map, String id) {
    return CircleModel(
      id: id,
      circleCode: map['circleCode'] ?? 'ALR-${id.substring(0, 3).toUpperCase()}',
      accessPassword: map['accessPassword'] ?? '123456',
      name: map['name'] ?? '',
      teacherId: map['teacherId'] ?? '',
      teacherName: map['teacherName'] ?? '',
      supervisorId: map['supervisorId'],
      supervisorName: map['supervisorName'],
      level: map['level'] ?? '',
      stage: map['stage'] ?? '',
      studyDays: List<String>.from(map['studyDays'] ?? []),
      startTime: map['startTime'] ?? '',
      endTime: map['endTime'] ?? '',
      studentCount: map['studentCount'] ?? 0,
      location: map['location'] ?? '',
      status: (map['status'] == 'inactive') ? CircleStatus.inactive : CircleStatus.active,
      notes: map['notes'],
      createdAt: map['createdAt'] != null ? DateTime.tryParse(map['createdAt'].toString()) ?? DateTime.now() : DateTime.now(),
      updatedAt: map['updatedAt'] != null ? DateTime.tryParse(map['updatedAt'].toString()) : null,
      createdBy: map['createdBy'],
      updatedBy: map['updatedBy'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'circleCode': circleCode,
      'accessPassword': accessPassword,
      'name': name,
      'teacherId': teacherId,
      'teacherName': teacherName,
      'supervisorId': supervisorId,
      'supervisorName': supervisorName,
      'level': level,
      'stage': stage,
      'studyDays': studyDays,
      'startTime': startTime,
      'endTime': endTime,
      'studentCount': studentCount,
      'location': location,
      'status': status.value,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'createdBy': createdBy,
      'updatedBy': updatedBy,
    };
  }

  CircleModel copyWith({
    String? id,
    String? circleCode,
    String? accessPassword,
    String? name,
    String? teacherId,
    String? teacherName,
    String? supervisorId,
    String? supervisorName,
    String? level,
    String? stage,
    List<String>? studyDays,
    String? startTime,
    String? endTime,
    int? studentCount,
    String? location,
    CircleStatus? status,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? createdBy,
    String? updatedBy,
  }) {
    return CircleModel(
      id: id ?? this.id,
      circleCode: circleCode ?? this.circleCode,
      accessPassword: accessPassword ?? this.accessPassword,
      name: name ?? this.name,
      teacherId: teacherId ?? this.teacherId,
      teacherName: teacherName ?? this.teacherName,
      supervisorId: supervisorId ?? this.supervisorId,
      supervisorName: supervisorName ?? this.supervisorName,
      level: level ?? this.level,
      stage: stage ?? this.stage,
      studyDays: studyDays ?? this.studyDays,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      studentCount: studentCount ?? this.studentCount,
      location: location ?? this.location,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      createdBy: createdBy ?? this.createdBy,
      updatedBy: updatedBy ?? this.updatedBy,
    );
  }
}
