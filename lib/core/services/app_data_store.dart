import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_enums.dart';
import '../../data/models/circle_model.dart';
import '../../data/models/student_model.dart';
import '../../data/models/attendance_model.dart';
import '../../data/models/memorization_model.dart';
import '../../data/models/exam_model.dart';
import '../../data/models/grade_model.dart';
import '../../data/models/fee_model.dart';
import '../../data/models/monthly_report_model.dart';
import '../../data/models/user_model.dart';
import '../../data/models/announcement_model.dart';
import '../../data/models/achievement_model.dart';
import '../../data/models/islamic_text_model.dart';
import '../../data/models/quran_progress_model.dart';
import 'firebase_sync_service.dart';

/// مخزن البيانات التفاعلي الشامل للمنظومة
/// يوفر إدارة الحالة والبيانات لجميع أقسام المنظومة
class AppDataStore extends ChangeNotifier {
  static final AppDataStore instance = AppDataStore._internal();
  AppDataStore._internal() {
    _initializeDefaultData();
    _loadFromStorage();
  }

  Future<void> _saveToStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final circlesJson = jsonEncode(circles.map((c) => c.toMap()).toList());
      final studentsJson = jsonEncode(students.map((s) => s.toMap()).toList());
      final usersJson = jsonEncode(users.map((u) => u.toMap()).toList());
      await prefs.setString('alrayyan_circles', circlesJson);
      await prefs.setString('alrayyan_students', studentsJson);
      await prefs.setString('alrayyan_users', usersJson);
    } catch (e) {
      debugPrint('Safe storage save: $e');
    }
  }

  Future<void> _loadFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final circlesStr = prefs.getString('alrayyan_circles');
      if (circlesStr != null && circlesStr.isNotEmpty) {
        final List list = jsonDecode(circlesStr);
        if (list.isNotEmpty) {
          circles.clear();
          for (var i = 0; i < list.length; i++) {
            final map = Map<String, dynamic>.from(list[i]);
            circles.add(CircleModel.fromMap(map, map['id'] ?? 'crc_$i'));
          }
        }
      }

      final studentsStr = prefs.getString('alrayyan_students');
      if (studentsStr != null && studentsStr.isNotEmpty) {
        final List list = jsonDecode(studentsStr);
        if (list.isNotEmpty) {
          students.clear();
          for (var i = 0; i < list.length; i++) {
            final map = Map<String, dynamic>.from(list[i]);
            students.add(StudentModel.fromMap(map, map['id'] ?? 'std_$i'));
          }
        }
      }

      final usersStr = prefs.getString('alrayyan_users');
      if (usersStr != null && usersStr.isNotEmpty) {
        final List list = jsonDecode(usersStr);
        if (list.isNotEmpty) {
          users.clear();
          for (var i = 0; i < list.length; i++) {
            final map = Map<String, dynamic>.from(list[i]);
            users.add(UserModel.fromMap(map, map['id'] ?? 'usr_$i'));
          }
          if (!users.any((u) => u.email == 'hymdyhmbarksyd@gmail.com') && currentUser != null) {
            users.insert(0, currentUser!);
          }
        }
      }
      notifyListeners();
    } catch (e) {
      debugPrint('Safe storage load: $e');
    }
  }

  // المستخدم الحالي المسجل
  UserModel? currentUser;

  // الحلقات
  final List<CircleModel> circles = [];

  // الطلاب
  final List<StudentModel> students = [];

  // الحضور والغياب
  final List<AttendanceModel> attendanceRecords = [];

  // الحفظ والمراجعة
  final List<MemorizationModel> memorizationRecords = [];

  // الاختبارات والدرجات
  final List<ExamModel> exams = [];
  final List<GradeModel> grades = [];

  // الرسوم المالية
  final List<FeeModel> fees = [];

  // التقارير الشهرية
  final List<MonthlyReportModel> reports = [];

  // المستخدمون
  final List<UserModel> users = [];

  // ===== جديد: الإعلانات والأنشطة =====
  final List<AnnouncementModel> announcements = [];

  // ===== جديد: الإنجازات والأوسمة =====
  final List<AchievementModel> achievements = [];

  // ===== جديد: المتون العلمية =====
  final List<IslamicTextModel> islamicTexts = [];
  final List<IslamicTextProgressModel> islamicTextProgress = [];

  // ===== جديد: تقدم الحفظ القرآني لكل طالب =====
  final Map<String, QuranProgressModel> quranProgress = {};

  // ===== وضع الليلي/النهاري =====
  ThemeMode themeMode = ThemeMode.light;

  void toggleTheme() {
    themeMode = themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }

  void _initializeDefaultData() {
    final now = DateTime.now();

    // المدير العام الرسمي
    currentUser = UserModel(
      id: 'admin_official',
      name: 'المدير العام',
      email: 'hymdyhmbarksyd@gmail.com',
      role: UserRole.admin,
      phone: '77815779805',
      isActive: true,
      createdAt: now,
      assignedCircleIds: [],
      permissions: {
        'canAddStudent': true,
        'canManageCircles': true,
        'canViewFees': true,
        'canApproveReports': true,
      },
    );

    // المستخدمون
    users.clear();
    users.add(currentUser!);

    // بيانات أولية معتمدة قابلة للتعديل والإضافة من قبل المدير
    users.add(UserModel(
      id: 'tch_01',
      name: 'الأستاذ أحمد الحضرمي',
      email: 'teacher@alrayyan.com',
      role: UserRole.teacher,
      phone: '770000001',
      password: '123456',
      assignedCircleIds: ['crc_01'],
      createdAt: now,
      permissions: {'canAddStudent': false},
    ));

    // حلقة البداية المعتمدة
    circles.clear();
    circles.add(CircleModel(
      id: 'crc_01',
      name: 'حلقة الإمام الشاطبي',
      circleCode: 'RYN-101',
      accessPassword: '123456',
      teacherId: 'tch_01',
      teacherName: 'الأستاذ أحمد الحضرمي',
      level: 'المستوى المتقدم',
      stage: 'المرحلة المتوسطة',
      studyDays: const ['السبت', 'الأحد', 'الاثنين', 'الثلاثاء', 'الأربعاء'],
      startTime: '16:00',
      endTime: '17:30',
      location: 'مسجد الريان - الجناح الشرقي',
      createdAt: now,
    ));

    // طالب افتراضي معتمد
    students.clear();
    students.add(StudentModel(
      id: 'std_01',
      studentNumber: '2024001',
      fullName: 'محمد سالم باعباد',
      circleId: 'crc_01',
      circleName: 'حلقة الإمام الشاطبي',
      level: 'المستوى المتقدم',
      guardianName: 'سالم باعباد',
      guardianRelation: 'الأب',
      guardianPhone: '770123456',
      password: '123456',
      guardianPassword: '123456',
      enrollmentDate: now,
      createdAt: now,
    ));

    attendanceRecords.clear();
    memorizationRecords.clear();
    fees.clear();
    announcements.clear();
    achievements.clear();
    islamicTextProgress.clear();
    quranProgress.clear();

    // تهيئة المتون الافتراضية
    islamicTexts.clear();
    islamicTexts.addAll(IslamicTextModel.defaultTexts());

    // إعلان ترحيبي افتراضي
    announcements.add(AnnouncementModel(
      id: 'ann_welcome',
      title: 'مرحباً بكم في منصة الريان القرآنية',
      content:
          'بسم الله الرحمن الرحيم\nنبارك لكم انطلاق منصة الريان لإدارة الحلقات القرآنية، ونسأل الله أن يجعل هذا العمل في ميزان حسناتنا.',
      type: AnnouncementType.general,
      createdAt: now,
      createdBy: 'admin_official',
      createdByName: 'المدير العام',
      isPinned: true,
    ));
  }

  // ===== دوال التصفية حسب الصلاحية والأدوار =====
  List<CircleModel> getVisibleCircles() {
    if (currentUser?.role == UserRole.teacher) {
      final assigned = currentUser?.assignedCircleIds ?? [];
      final tId = currentUser?.id ?? '';
      final tName = currentUser?.name.trim() ?? '';
      return circles.where((c) {
        return assigned.contains(c.id) ||
            c.teacherId == tId ||
            (tName.isNotEmpty && c.teacherName.contains(tName));
      }).toList();
    }
    return circles;
  }

  List<StudentModel> getVisibleStudents() {
    if (currentUser?.role == UserRole.teacher) {
      final myCircleIds = getVisibleCircles().map((c) => c.id).toSet();
      return students.where((s) => myCircleIds.contains(s.circleId)).toList();
    }
    return students;
  }

  // ===== إدارة الحلقات =====
  void addCircle(CircleModel circle) {
    circles.insert(0, circle);
    notifyListeners();
    _saveToStorage();
    FirebaseSyncService.instance.syncCircle(circle);
  }

  void updateCircle(CircleModel updated) {
    final index = circles.indexWhere((c) => c.id == updated.id);
    if (index != -1) {
      circles[index] = updated;
      notifyListeners();
      _saveToStorage();
      FirebaseSyncService.instance.syncCircle(updated);
    }
  }

  void deleteCircle(String circleId) {
    circles.removeWhere((c) => c.id == circleId);
    notifyListeners();
    _saveToStorage();
  }

  CircleModel? findCircleByCode(String code) {
    try {
      return circles.firstWhere(
        (c) => c.circleCode.trim().toUpperCase() == code.trim().toUpperCase(),
      );
    } catch (_) {
      return null;
    }
  }

  // ===== إدارة المستخدمين والمعلمين وقواعد الأمان =====
  void addUser(UserModel user) {
    users.insert(0, user);
    notifyListeners();
    _saveToStorage();
  }

  void updateUser(UserModel updated) {
    final index = users.indexWhere((u) => u.id == updated.id);
    if (index != -1) {
      users[index] = updated;
      notifyListeners();
      _saveToStorage();
    }
  }

  void deleteUser(String userId) {
    users.removeWhere((u) => u.id == userId);
    notifyListeners();
    _saveToStorage();
  }

  void updateUserPassword(String userId, String newPassword) {
    final index = users.indexWhere((u) => u.id == userId);
    if (index != -1) {
      final user = users[index];
      users[index] = user.copyWith(
        password: newPassword,
        updatedAt: DateTime.now(),
      );

      // مزامنة كلمة المرور مع الحلقات المرتبطة بهذا المعلم
      for (int i = 0; i < circles.length; i++) {
        final c = circles[i];
        if (c.teacherId == userId || user.assignedCircleIds.contains(c.id)) {
          circles[i] = c.copyWith(accessPassword: newPassword);
        }
      }
      notifyListeners();
      _saveToStorage();
    }
  }

  void updateCirclePassword(String circleId, String newPassword) {
    final index = circles.indexWhere((c) => c.id == circleId);
    if (index != -1) {
      final circle = circles[index];
      circles[index] = circle.copyWith(accessPassword: newPassword);

      // مزامنة كلمة المرور مع المدرس
      final teacherIdx = users.indexWhere((u) => u.id == circle.teacherId);
      if (teacherIdx != -1) {
        users[teacherIdx] = users[teacherIdx].copyWith(password: newPassword);
      }
      notifyListeners();
      _saveToStorage();
    }
  }

  void syncTeachersFromCircles() {
    bool changed = false;
    for (final c in circles) {
      if (c.teacherName.trim().isNotEmpty) {
        final existingIdx = users.indexWhere((u) =>
            u.id == c.teacherId ||
            (u.name.trim() == c.teacherName.trim() && u.role == UserRole.teacher));
        if (existingIdx == -1) {
          users.add(UserModel(
            id: c.teacherId.isNotEmpty ? c.teacherId : 'tch_${c.id}',
            name: c.teacherName,
            email: '${c.circleCode.toLowerCase().replaceAll('-', '_')}@alrayyan.com',
            role: UserRole.teacher,
            password: c.accessPassword,
            phone: '',
            assignedCircleIds: [c.id],
            createdAt: c.createdAt,
          ));
          changed = true;
        } else {
          final u = users[existingIdx];
          final assigned = List<String>.from(u.assignedCircleIds);
          if (!assigned.contains(c.id)) {
            assigned.add(c.id);
            users[existingIdx] = u.copyWith(
              assignedCircleIds: assigned,
              password: u.password ?? c.accessPassword,
            );
            changed = true;
          }
        }
      }
    }
    if (changed) {
      notifyListeners();
    }
  }

  // ===== إدارة الطلاب =====
  void addStudent(StudentModel student) {
    students.insert(0, student);
    // تحديث عدد طلاب الحلقة
    final circleIdx = circles.indexWhere((c) => c.id == student.circleId);
    if (circleIdx != -1) {
      final c = circles[circleIdx];
      circles[circleIdx] = CircleModel(
        id: c.id,
        circleCode: c.circleCode,
        accessPassword: c.accessPassword,
        name: c.name,
        teacherId: c.teacherId,
        teacherName: c.teacherName,
        level: c.level,
        stage: c.stage,
        studyDays: c.studyDays,
        startTime: c.startTime,
        endTime: c.endTime,
        studentCount: c.studentCount + 1,
        location: c.location,
        status: c.status,
        createdAt: c.createdAt,
      );
    }
    // تهيئة تقدم قرآني للطالب
    quranProgress[student.id] = QuranProgressModel(
      studentId: student.id,
      updatedAt: DateTime.now(),
    );
    notifyListeners();
    _saveToStorage();
    FirebaseSyncService.instance.syncStudent(student);
  }

  void updateStudent(StudentModel updated) {
    final index = students.indexWhere((s) => s.id == updated.id);
    if (index != -1) {
      students[index] = updated;
      notifyListeners();
      _saveToStorage();
      FirebaseSyncService.instance.syncStudent(updated);
    }
  }

  void updateStudentPassword(String studentId, String newPassword) {
    final index = students.indexWhere((s) => s.id == studentId);
    if (index != -1) {
      final s = students[index];
      students[index] = StudentModel(
        id: s.id,
        studentNumber: s.studentNumber,
        fullName: s.fullName,
        photoUrl: s.photoUrl,
        birthDate: s.birthDate,
        enrollmentDate: s.enrollmentDate,
        circleId: s.circleId,
        circleName: s.circleName,
        level: s.level,
        status: s.status,
        guardianName: s.guardianName,
        guardianRelation: s.guardianRelation,
        guardianPhone: s.guardianPhone,
        guardianPhone2: s.guardianPhone2,
        address: s.address,
        adminNotes: s.adminNotes,
        educationalNotes: s.educationalNotes,
        password: newPassword,
        guardianPassword: s.guardianPassword,
        createdAt: s.createdAt,
        updatedAt: DateTime.now(),
        createdBy: s.createdBy,
        updatedBy: s.updatedBy,
      );
      notifyListeners();
      _saveToStorage();
    }
  }

  void updateGuardianPassword(String studentId, String newPassword) {
    final index = students.indexWhere((s) => s.id == studentId);
    if (index != -1) {
      final s = students[index];
      students[index] = StudentModel(
        id: s.id,
        studentNumber: s.studentNumber,
        fullName: s.fullName,
        photoUrl: s.photoUrl,
        birthDate: s.birthDate,
        enrollmentDate: s.enrollmentDate,
        circleId: s.circleId,
        circleName: s.circleName,
        level: s.level,
        status: s.status,
        guardianName: s.guardianName,
        guardianRelation: s.guardianRelation,
        guardianPhone: s.guardianPhone,
        guardianPhone2: s.guardianPhone2,
        address: s.address,
        adminNotes: s.adminNotes,
        educationalNotes: s.educationalNotes,
        password: s.password,
        guardianPassword: newPassword,
        createdAt: s.createdAt,
        updatedAt: DateTime.now(),
        createdBy: s.createdBy,
        updatedBy: s.updatedBy,
      );
      notifyListeners();
      _saveToStorage();
    }
  }

  void deleteStudent(String studentId) {
    students.removeWhere((s) => s.id == studentId);
    quranProgress.remove(studentId);
    notifyListeners();
    _saveToStorage();
  }

  List<StudentModel> getStudentsByCircle(String circleId) {
    return students.where((s) => s.circleId == circleId).toList();
  }

  // ===== الحضور والغياب =====
  void recordAttendance(List<AttendanceModel> records) {
    for (final rec in records) {
      attendanceRecords.removeWhere(
        (a) =>
            a.studentId == rec.studentId &&
            a.date.year == rec.date.year &&
            a.date.month == rec.date.month &&
            a.date.day == rec.date.day,
      );
      attendanceRecords.insert(0, rec);
      FirebaseSyncService.instance.syncAttendance(rec);
    }
    notifyListeners();
  }

  List<AttendanceModel> getStudentAttendance(String studentId) {
    return attendanceRecords
        .where((a) => a.studentId == studentId)
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  double getStudentAttendanceRate(String studentId) {
    final records = getStudentAttendance(studentId);
    if (records.isEmpty) return 0;
    final present = records
        .where((a) =>
            a.status == AttendanceStatus.present ||
            a.status == AttendanceStatus.late)
        .length;
    return (present / records.length) * 100;
  }

  // ===== الحفظ والمراجعة =====
  void addMemorizationSession(MemorizationModel session) {
    memorizationRecords.insert(0, session);
    notifyListeners();
  }

  List<MemorizationModel> getStudentMemorization(String studentId) {
    return memorizationRecords
        .where((m) => m.studentId == studentId)
        .toList()
      ..sort((a, b) => b.sessionDate.compareTo(a.sessionDate));
  }

  // ===== تقدم القرآن =====
  QuranProgressModel getQuranProgress(String studentId) {
    return quranProgress[studentId] ??
        QuranProgressModel(studentId: studentId, updatedAt: DateTime.now());
  }

  void updateQuranProgress(QuranProgressModel progress) {
    quranProgress[progress.studentId] = progress;
    notifyListeners();
  }

  // ===== الرسوم المالية =====
  void addFeePayment(FeeModel fee) {
    fees.insert(0, fee);
    notifyListeners();
    FirebaseSyncService.instance.syncFee(fee);
  }

  // ===== الإعلانات =====
  void addAnnouncement(AnnouncementModel announcement) {
    announcements.insert(0, announcement);
    notifyListeners();
  }

  void updateAnnouncement(AnnouncementModel updated) {
    final index = announcements.indexWhere((a) => a.id == updated.id);
    if (index != -1) {
      announcements[index] = updated;
      notifyListeners();
    }
  }

  void deleteAnnouncement(String id) {
    announcements.removeWhere((a) => a.id == id);
    notifyListeners();
  }

  // ===== الإنجازات =====
  void addAchievement(AchievementModel achievement) {
    achievements.insert(0, achievement);
    notifyListeners();
  }

  List<AchievementModel> getStudentAchievements(String studentId) {
    return achievements.where((a) => a.studentId == studentId).toList();
  }

  // ===== المتون العلمية =====
  void addIslamicText(IslamicTextModel text) {
    islamicTexts.add(text);
    notifyListeners();
  }

  void deleteIslamicText(String id) {
    islamicTexts.removeWhere((t) => t.id == id);
    islamicTextProgress.removeWhere((p) => p.textId == id);
    notifyListeners();
  }

  void updateIslamicTextProgress(IslamicTextProgressModel progress) {
    final index = islamicTextProgress.indexWhere(
        (p) => p.studentId == progress.studentId && p.textId == progress.textId);
    if (index != -1) {
      islamicTextProgress[index] = progress;
    } else {
      islamicTextProgress.insert(0, progress);
    }
    notifyListeners();
  }

  List<IslamicTextProgressModel> getStudentTextProgress(String studentId) {
    return islamicTextProgress.where((p) => p.studentId == studentId).toList();
  }

  // ===== إحصائيات سريعة =====
  int get totalPresentToday {
    final today = DateTime.now();
    return attendanceRecords
        .where((a) =>
            a.date.year == today.year &&
            a.date.month == today.month &&
            a.date.day == today.day &&
            a.status == AttendanceStatus.present)
        .length;
  }

  int get totalAbsentToday {
    final today = DateTime.now();
    return attendanceRecords
        .where((a) =>
            a.date.year == today.year &&
            a.date.month == today.month &&
            a.date.day == today.day &&
            a.status == AttendanceStatus.absent)
        .length;
  }

  double get totalFeesCollected =>
      fees.fold(0.0, (sum, f) => sum + f.amountPaid);
  double get totalFeesDue => fees.fold(0.0, (sum, f) => sum + f.amountDue);

  // أفضل الطلاب حسب الحضور
  List<StudentModel> get topStudentsByAttendance {
    final visible = getVisibleStudents();
    final sorted = visible.toList()
      ..sort((a, b) =>
          getStudentAttendanceRate(b.id)
              .compareTo(getStudentAttendanceRate(a.id)));
    return sorted.take(5).toList();
  }

  // الطلاب الذين يحتاجون متابعة (حضور أقل من 70%)
  List<StudentModel> get studentsNeedingAttention {
    return getVisibleStudents()
        .where((s) =>
            attendanceRecords.any((a) => a.studentId == s.id) &&
            getStudentAttendanceRate(s.id) < 70)
        .toList();
  }
}

final appDataStoreProvider = ChangeNotifierProvider<AppDataStore>((ref) {
  return AppDataStore.instance;
});
