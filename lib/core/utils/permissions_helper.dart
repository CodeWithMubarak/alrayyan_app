import '../constants/app_enums.dart';

class PermissionsHelper {
  PermissionsHelper._();

  static bool canManageCircles(UserRole role) {
    return role == UserRole.admin || role == UserRole.viceAdmin;
  }

  static bool canAddStudent(UserRole role, {Map<String, bool>? permissions}) {
    if (role == UserRole.admin || role == UserRole.viceAdmin) return true;
    if (role == UserRole.teacher && permissions?['canAddStudent'] == true) return true;
    return false;
  }

  static bool canEditStudent(UserRole role) {
    return role == UserRole.admin || role == UserRole.viceAdmin || role == UserRole.teacher;
  }

  static bool canDeleteStudent(UserRole role) {
    return role == UserRole.admin;
  }

  static bool canManageUsers(UserRole role) {
    return role == UserRole.admin;
  }

  static bool canViewFinancials(UserRole role, {Map<String, bool>? permissions}) {
    if (role == UserRole.admin || role == UserRole.viceAdmin) return true;
    if (role == UserRole.supervisor && permissions?['canViewFees'] == true) return true;
    return false;
  }

  static bool canApproveReports(UserRole role, {Map<String, bool>? permissions}) {
    if (role == UserRole.admin) return true;
    if (role == UserRole.viceAdmin && permissions?['canApproveReports'] == true) return true;
    return false;
  }

  static bool canViewAllCircles(UserRole role) {
    return role == UserRole.admin || role == UserRole.viceAdmin;
  }

  static bool canExportData(UserRole role) {
    return role == UserRole.admin || role == UserRole.viceAdmin;
  }

  static bool canManageSettings(UserRole role) {
    return role == UserRole.admin;
  }

  static bool canViewGuardianInfo(UserRole role) {
    // متاح للإدارة والمشرف والمدرس لطلب التواصل مع ولي الأمر
    return true;
  }
}
