class NotificationModel {
  final String id;
  final String title;
  final String body;
  final String type;
  final List<String> targetRoles;
  final String? targetCircleId;
  final Map<String, dynamic>? data;
  final bool isRead;
  final DateTime createdAt;
  final String? createdBy;

  NotificationModel({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    this.targetRoles = const [],
    this.targetCircleId,
    this.data,
    this.isRead = false,
    required this.createdAt,
    this.createdBy,
  });

  factory NotificationModel.fromMap(Map<String, dynamic> map, String id) {
    return NotificationModel(
      id: id,
      title: map['title'] ?? '',
      body: map['body'] ?? '',
      type: map['type'] ?? 'general',
      targetRoles: List<String>.from(map['targetRoles'] ?? []),
      targetCircleId: map['targetCircleId'],
      data: map['data'],
      isRead: map['isRead'] ?? false,
      createdAt: map['createdAt'] != null ? DateTime.tryParse(map['createdAt'].toString()) ?? DateTime.now() : DateTime.now(),
      createdBy: map['createdBy'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'body': body,
      'type': type,
      'targetRoles': targetRoles,
      'targetCircleId': targetCircleId,
      'data': data,
      'isRead': isRead,
      'createdAt': createdAt.toIso8601String(),
      'createdBy': createdBy,
    };
  }
}
