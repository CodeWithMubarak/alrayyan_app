enum AnnouncementType {
  general,       // إعلان عام
  exam,          // موعد اختبار
  competition,   // مسابقة
  event,         // فعالية
  holiday,       // إجازة
  urgent,        // عاجل
}

extension AnnouncementTypeExtension on AnnouncementType {
  String get displayName {
    switch (this) {
      case AnnouncementType.general: return 'إعلان عام';
      case AnnouncementType.exam: return 'موعد اختبار';
      case AnnouncementType.competition: return 'مسابقة';
      case AnnouncementType.event: return 'فعالية';
      case AnnouncementType.holiday: return 'إجازة';
      case AnnouncementType.urgent: return 'عاجل';
    }
  }

  String get icon {
    switch (this) {
      case AnnouncementType.general: return '📢';
      case AnnouncementType.exam: return '📝';
      case AnnouncementType.competition: return '🏆';
      case AnnouncementType.event: return '🎉';
      case AnnouncementType.holiday: return '🌙';
      case AnnouncementType.urgent: return '🔔';
    }
  }

  int get colorValue {
    switch (this) {
      case AnnouncementType.general: return 0xFF103D32;
      case AnnouncementType.exam: return 0xFF1976D2;
      case AnnouncementType.competition: return 0xFFC6A45C;
      case AnnouncementType.event: return 0xFF388E3C;
      case AnnouncementType.holiday: return 0xFF7B1FA2;
      case AnnouncementType.urgent: return 0xFFD32F2F;
    }
  }

  String get value {
    switch (this) {
      case AnnouncementType.general: return 'general';
      case AnnouncementType.exam: return 'exam';
      case AnnouncementType.competition: return 'competition';
      case AnnouncementType.event: return 'event';
      case AnnouncementType.holiday: return 'holiday';
      case AnnouncementType.urgent: return 'urgent';
    }
  }

  static AnnouncementType fromString(String v) {
    switch (v) {
      case 'exam': return AnnouncementType.exam;
      case 'competition': return AnnouncementType.competition;
      case 'event': return AnnouncementType.event;
      case 'holiday': return AnnouncementType.holiday;
      case 'urgent': return AnnouncementType.urgent;
      default: return AnnouncementType.general;
    }
  }
}

class AnnouncementModel {
  final String id;
  final String title;
  final String content;
  final AnnouncementType type;
  final DateTime createdAt;
  final DateTime? eventDate;
  final String createdBy;
  final String createdByName;
  final bool isPinned;
  final List<String> targetCircleIds; // empty = all circles

  const AnnouncementModel({
    required this.id,
    required this.title,
    required this.content,
    this.type = AnnouncementType.general,
    required this.createdAt,
    this.eventDate,
    required this.createdBy,
    required this.createdByName,
    this.isPinned = false,
    this.targetCircleIds = const [],
  });

  AnnouncementModel copyWith({
    String? id,
    String? title,
    String? content,
    AnnouncementType? type,
    DateTime? createdAt,
    DateTime? eventDate,
    String? createdBy,
    String? createdByName,
    bool? isPinned,
    List<String>? targetCircleIds,
  }) {
    return AnnouncementModel(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      type: type ?? this.type,
      createdAt: createdAt ?? this.createdAt,
      eventDate: eventDate ?? this.eventDate,
      createdBy: createdBy ?? this.createdBy,
      createdByName: createdByName ?? this.createdByName,
      isPinned: isPinned ?? this.isPinned,
      targetCircleIds: targetCircleIds ?? this.targetCircleIds,
    );
  }
}
