/// أنواع المستخدمين والأدوار في النظام
enum UserRole {
  admin,       // مدير عام
  viceAdmin,   // نائب المدير
  supervisor,  // مشرف
  teacher,     // مدرس
  parent,      // ولي أمر
  student,     // طالب
}

extension UserRoleExtension on UserRole {
  String get displayName {
    switch (this) {
      case UserRole.admin:
        return 'مدير عام';
      case UserRole.viceAdmin:
        return 'نائب المدير';
      case UserRole.supervisor:
        return 'مشرف';
      case UserRole.teacher:
        return 'مدرس';
      case UserRole.parent:
        return 'ولي أمر';
      case UserRole.student:
        return 'طالب';
    }
  }

  String get value {
    switch (this) {
      case UserRole.admin:
        return 'admin';
      case UserRole.viceAdmin:
        return 'vice_admin';
      case UserRole.supervisor:
        return 'supervisor';
      case UserRole.teacher:
        return 'teacher';
      case UserRole.parent:
        return 'parent';
      case UserRole.student:
        return 'student';
    }
  }

  static UserRole fromString(String value) {
    switch (value) {
      case 'admin':
        return UserRole.admin;
      case 'vice_admin':
        return UserRole.viceAdmin;
      case 'supervisor':
        return UserRole.supervisor;
      case 'teacher':
        return UserRole.teacher;
      case 'parent':
        return UserRole.parent;
      case 'student':
        return UserRole.student;
      default:
        return UserRole.teacher;
    }
  }
}

/// حالات الطالب
enum StudentStatus {
  active,       // نشط
  suspended,    // متوقف
  transferred,  // منقول
  graduated,    // متخرج
}

extension StudentStatusExtension on StudentStatus {
  String get displayName {
    switch (this) {
      case StudentStatus.active: return 'نشط';
      case StudentStatus.suspended: return 'متوقف';
      case StudentStatus.transferred: return 'منقول';
      case StudentStatus.graduated: return 'متخرج';
    }
  }
  String get value {
    switch (this) {
      case StudentStatus.active: return 'active';
      case StudentStatus.suspended: return 'suspended';
      case StudentStatus.transferred: return 'transferred';
      case StudentStatus.graduated: return 'graduated';
    }
  }
  static StudentStatus fromString(String v) {
    switch (v) {
      case 'active': return StudentStatus.active;
      case 'suspended': return StudentStatus.suspended;
      case 'transferred': return StudentStatus.transferred;
      case 'graduated': return StudentStatus.graduated;
      default: return StudentStatus.active;
    }
  }
}

/// حالات الحضور
enum AttendanceStatus {
  present,       // حاضر
  absent,        // غائب
  late,          // متأخر
  excusedAbsent, // غياب بعذر
}

extension AttendanceStatusExtension on AttendanceStatus {
  String get displayName {
    switch (this) {
      case AttendanceStatus.present: return 'حاضر';
      case AttendanceStatus.absent: return 'غائب';
      case AttendanceStatus.late: return 'متأخر';
      case AttendanceStatus.excusedAbsent: return 'غياب بعذر';
    }
  }
  String get value {
    switch (this) {
      case AttendanceStatus.present: return 'present';
      case AttendanceStatus.absent: return 'absent';
      case AttendanceStatus.late: return 'late';
      case AttendanceStatus.excusedAbsent: return 'excused_absent';
    }
  }
}

/// حالة الحلقة
enum CircleStatus {
  active,   // نشطة
  inactive, // متوقفة
}

extension CircleStatusExtension on CircleStatus {
  String get displayName {
    switch (this) {
      case CircleStatus.active: return 'نشطة';
      case CircleStatus.inactive: return 'متوقفة';
    }
  }
  String get value {
    switch (this) {
      case CircleStatus.active: return 'active';
      case CircleStatus.inactive: return 'inactive';
    }
  }
}

/// جودة الحفظ والمراجعة
enum MemorizationQuality {
  excellent,         // ممتاز
  veryGood,          // جيد جداً
  good,              // جيد
  needsImprovement,  // يحتاج إلى تحسين
}

extension MemorizationQualityExtension on MemorizationQuality {
  String get displayName {
    switch (this) {
      case MemorizationQuality.excellent: return 'ممتاز';
      case MemorizationQuality.veryGood: return 'جيد جداً';
      case MemorizationQuality.good: return 'جيد';
      case MemorizationQuality.needsImprovement: return 'يحتاج إلى تحسين';
    }
  }
  String get value {
    switch (this) {
      case MemorizationQuality.excellent: return 'excellent';
      case MemorizationQuality.veryGood: return 'very_good';
      case MemorizationQuality.good: return 'good';
      case MemorizationQuality.needsImprovement: return 'needs_improvement';
    }
  }
}

/// أنواع الاختبارات
enum ExamType {
  memorization,    // اختبار حفظ
  revision,        // اختبار مراجعة
  arabic,          // اختبار لغة عربية
  islamicStudies,  // اختبار علوم شرعية
  general,         // اختبار عام
}

extension ExamTypeExtension on ExamType {
  String get displayName {
    switch (this) {
      case ExamType.memorization: return 'اختبار حفظ';
      case ExamType.revision: return 'اختبار مراجعة';
      case ExamType.arabic: return 'اختبار لغة عربية';
      case ExamType.islamicStudies: return 'اختبار علوم شرعية';
      case ExamType.general: return 'اختبار عام';
    }
  }
  String get value {
    switch (this) {
      case ExamType.memorization: return 'memorization';
      case ExamType.revision: return 'revision';
      case ExamType.arabic: return 'arabic';
      case ExamType.islamicStudies: return 'islamic_studies';
      case ExamType.general: return 'general';
    }
  }
}

/// حالات الرسوم
enum FeeStatus {
  paid,     // مدفوع
  partial,  // مدفوع جزئياً
  unpaid,   // غير مدفوع
  exempt,   // معفى
}

extension FeeStatusExtension on FeeStatus {
  String get displayName {
    switch (this) {
      case FeeStatus.paid: return 'مدفوع';
      case FeeStatus.partial: return 'مدفوع جزئياً';
      case FeeStatus.unpaid: return 'غير مدفوع';
      case FeeStatus.exempt: return 'معفى';
    }
  }
  String get value {
    switch (this) {
      case FeeStatus.paid: return 'paid';
      case FeeStatus.partial: return 'partial';
      case FeeStatus.unpaid: return 'unpaid';
      case FeeStatus.exempt: return 'exempt';
    }
  }
}

/// حالات التقرير
enum ReportStatus {
  draft,          // مسودة
  underReview,    // قيد المراجعة
  needsRevision,  // يحتاج إلى تعديل
  approved,       // معتمد
  archived,       // مؤرشف
}

extension ReportStatusExtension on ReportStatus {
  String get displayName {
    switch (this) {
      case ReportStatus.draft: return 'مسودة';
      case ReportStatus.underReview: return 'قيد المراجعة';
      case ReportStatus.needsRevision: return 'يحتاج إلى تعديل';
      case ReportStatus.approved: return 'معتمد';
      case ReportStatus.archived: return 'مؤرشف';
    }
  }
  String get value {
    switch (this) {
      case ReportStatus.draft: return 'draft';
      case ReportStatus.underReview: return 'under_review';
      case ReportStatus.needsRevision: return 'needs_revision';
      case ReportStatus.approved: return 'approved';
      case ReportStatus.archived: return 'archived';
    }
  }
}

/// حالة المزامنة
enum SyncStatus {
  synced,  // متزامن
  pending, // في الانتظار
  failed,  // فشل
}
