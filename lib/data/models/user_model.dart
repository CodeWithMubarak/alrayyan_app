import '../../core/constants/app_enums.dart';

class UserModel {
  final String id;
  final String name;
  final String email;
  final UserRole role;
  final String? phone;
  final String? password; // كلمة المرور الخاصة بحساب المستخدم
  final List<String> assignedCircleIds;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? createdBy;
  final String? updatedBy;
  final Map<String, bool> permissions;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.phone,
    this.password,
    this.assignedCircleIds = const [],
    this.isActive = true,
    required this.createdAt,
    this.updatedAt,
    this.createdBy,
    this.updatedBy,
    this.permissions = const {},
  });

  factory UserModel.fromMap(Map<String, dynamic> map, String id) {
    return UserModel(
      id: id,
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      role: UserRoleExtension.fromString(map['role'] ?? 'teacher'),
      phone: map['phone'],
      password: map['password'],
      assignedCircleIds: List<String>.from(map['assignedCircleIds'] ?? []),
      isActive: map['isActive'] ?? true,
      createdAt: map['createdAt'] != null ? DateTime.tryParse(map['createdAt'].toString()) ?? DateTime.now() : DateTime.now(),
      updatedAt: map['updatedAt'] != null ? DateTime.tryParse(map['updatedAt'].toString()) : null,
      createdBy: map['createdBy'],
      updatedBy: map['updatedBy'],
      permissions: Map<String, bool>.from(map['permissions'] ?? {}),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'role': role.value,
      'phone': phone,
      'password': password,
      'assignedCircleIds': assignedCircleIds,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'createdBy': createdBy,
      'updatedBy': updatedBy,
      'permissions': permissions,
    };
  }

  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    UserRole? role,
    String? phone,
    String? password,
    List<String>? assignedCircleIds,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? createdBy,
    String? updatedBy,
    Map<String, bool>? permissions,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      phone: phone ?? this.phone,
      password: password ?? this.password,
      assignedCircleIds: assignedCircleIds ?? this.assignedCircleIds,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      createdBy: createdBy ?? this.createdBy,
      updatedBy: updatedBy ?? this.updatedBy,
      permissions: permissions ?? this.permissions,
    );
  }
}
