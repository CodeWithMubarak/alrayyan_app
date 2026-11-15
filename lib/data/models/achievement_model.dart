enum AchievementType {
  attendance,     // وسام المواظبة
  memorization,   // وسام إتقان الحفظ
  revision,       // وسام المراجعة
  excellence,     // وسام التميز
  competition,    // جائزة مسابقة
  special,        // إنجاز خاص
}

extension AchievementTypeExtension on AchievementType {
  String get displayName {
    switch (this) {
      case AchievementType.attendance: return 'وسام المواظبة';
      case AchievementType.memorization: return 'وسام إتقان الحفظ';
      case AchievementType.revision: return 'وسام المراجعة';
      case AchievementType.excellence: return 'وسام التميز';
      case AchievementType.competition: return 'جائزة مسابقة';
      case AchievementType.special: return 'إنجاز خاص';
    }
  }

  String get icon {
    switch (this) {
      case AchievementType.attendance: return '⭐';
      case AchievementType.memorization: return '🏅';
      case AchievementType.revision: return '📖';
      case AchievementType.excellence: return '🏆';
      case AchievementType.competition: return '🥇';
      case AchievementType.special: return '✨';
    }
  }

  int get colorValue {
    switch (this) {
      case AchievementType.attendance: return 0xFF1976D2;
      case AchievementType.memorization: return 0xFF103D32;
      case AchievementType.revision: return 0xFF388E3C;
      case AchievementType.excellence: return 0xFFC6A45C;
      case AchievementType.competition: return 0xFFD32F2F;
      case AchievementType.special: return 0xFF7B1FA2;
    }
  }

  String get value {
    switch (this) {
      case AchievementType.attendance: return 'attendance';
      case AchievementType.memorization: return 'memorization';
      case AchievementType.revision: return 'revision';
      case AchievementType.excellence: return 'excellence';
      case AchievementType.competition: return 'competition';
      case AchievementType.special: return 'special';
    }
  }

  static AchievementType fromString(String v) {
    switch (v) {
      case 'attendance': return AchievementType.attendance;
      case 'memorization': return AchievementType.memorization;
      case 'revision': return AchievementType.revision;
      case 'excellence': return AchievementType.excellence;
      case 'competition': return AchievementType.competition;
      default: return AchievementType.special;
    }
  }
}

class AchievementModel {
  final String id;
  final String studentId;
  final String studentName;
  final AchievementType type;
  final String title;
  final String description;
  final DateTime awardedAt;
  final String awardedBy;
  final String awardedByName;
  final String? circleId;

  const AchievementModel({
    required this.id,
    required this.studentId,
    required this.studentName,
    required this.type,
    required this.title,
    required this.description,
    required this.awardedAt,
    required this.awardedBy,
    required this.awardedByName,
    this.circleId,
  });
}
