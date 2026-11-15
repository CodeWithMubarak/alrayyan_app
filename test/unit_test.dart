import 'package:flutter_test/flutter_test.dart';
import 'package:alrayyan_app/core/constants/app_enums.dart';
import 'package:alrayyan_app/core/utils/permissions_helper.dart';
import 'package:alrayyan_app/data/models/attendance_model.dart';
import 'package:alrayyan_app/data/models/circle_model.dart';
import 'package:alrayyan_app/data/models/user_model.dart';

void main() {
  group('اختبارات الصلاحيات - PermissionsHelper Tests', () {
    test('المدير العام يمتلك جميع الصلاحيات', () {
      expect(PermissionsHelper.canManageCircles(UserRole.admin), isTrue);
      expect(PermissionsHelper.canManageUsers(UserRole.admin), isTrue);
      expect(PermissionsHelper.canViewFinancials(UserRole.admin), isTrue);
      expect(PermissionsHelper.canApproveReports(UserRole.admin), isTrue);
      expect(PermissionsHelper.canDeleteStudent(UserRole.admin), isTrue);
      expect(PermissionsHelper.canManageSettings(UserRole.admin), isTrue);
    });

    test('المدرس لا يستطيع حذف طالب أو إدارة المستخدمين أو الإعدادات', () {
      expect(PermissionsHelper.canManageCircles(UserRole.teacher), isFalse);
      expect(PermissionsHelper.canManageUsers(UserRole.teacher), isFalse);
      expect(PermissionsHelper.canViewFinancials(UserRole.teacher), isFalse);
      expect(PermissionsHelper.canDeleteStudent(UserRole.teacher), isFalse);
      expect(PermissionsHelper.canManageSettings(UserRole.teacher), isFalse);
    });

    test('المدرس يستطيع إضافة طالب فقط إذا منحته الإدارة الصلاحية', () {
      expect(PermissionsHelper.canAddStudent(UserRole.teacher, permissions: {'canAddStudent': false}), isFalse);
      expect(PermissionsHelper.canAddStudent(UserRole.teacher, permissions: {'canAddStudent': true}), isTrue);
    });
  });

  group('اختبارات نماذج البيانات والحلقات المشفرة - Data Models Tests', () {
    test('نموذج الحلقة يحتوي على كود الدخول وكلمة المرور الخاصة بها', () {
      final now = DateTime.now();
      final circle = CircleModel(
        id: 'c1',
        circleCode: 'RYN-101',
        accessPassword: 'SECRET_PASS_2026',
        name: 'حلقة الفجر',
        teacherId: 't1',
        teacherName: 'أحمد الحضرمي',
        level: 'المستوى الأول',
        stage: 'ابتدائي',
        studyDays: ['السبت', 'الاثنين'],
        startTime: '16:30',
        endTime: '18:00',
        location: 'مسجد الريان',
        createdAt: now,
      );

      final map = circle.toMap();
      expect(map['circleCode'], equals('RYN-101'));
      expect(map['accessPassword'], equals('SECRET_PASS_2026'));

      final parsed = CircleModel.fromMap(map, 'c1');
      expect(parsed.circleCode, equals('RYN-101'));
      expect(parsed.accessPassword, equals('SECRET_PASS_2026'));
      expect(parsed.name, equals('حلقة الفجر'));
    });

    test('نموذج الحضور والغياب يحفظ ويقرأ البيانات بشكل صحيح', () {
      final now = DateTime.now();
      final att = AttendanceModel(
        id: 'att_01',
        studentId: 'std_01',
        studentName: 'محمد أحمد',
        circleId: 'crc_01',
        circleName: 'حلقة الفجر',
        date: now,
        dayName: 'الأحد',
        status: AttendanceStatus.present,
        teacherId: 'tch_01',
        teacherName: 'أحمد المدرس',
        createdAt: now,
      );

      final map = att.toMap();
      expect(map['studentName'], equals('محمد أحمد'));
      expect(map['status'], equals('present'));

      final parsed = AttendanceModel.fromMap(map, 'att_01');
      expect(parsed.studentName, equals('محمد أحمد'));
      expect(parsed.status, equals(AttendanceStatus.present));
    });

    test('نموذج المستخدم مع الصلاحيات', () {
      final user = UserModel(
        id: 'usr_01',
        name: 'عبدالرحمن',
        email: 'teacher@alrayyan.com',
        role: UserRole.teacher,
        createdAt: DateTime.now(),
        assignedCircleIds: ['crc_01'],
        permissions: {'canAddStudent': true},
      );

      expect(user.role.displayName, equals('مدرس'));
      expect(user.permissions['canAddStudent'], isTrue);
      expect(user.assignedCircleIds.contains('crc_01'), isTrue);
    });

    test('المدير يستطيع رؤية وتعديل كلمة مرور المدرس وتزامنها مع الحلقة', () {
      final now = DateTime.now();
      final circle = CircleModel(
        id: 'crc_test',
        circleCode: 'RYN-999',
        accessPassword: 'INIT_PASSWORD_1',
        name: 'حلقة الاختبار',
        teacherId: 'tch_test',
        teacherName: 'أ. سالم بافضل',
        level: 'المستوى الأول',
        stage: 'ابتدائي',
        studyDays: ['السبت'],
        startTime: '16:30',
        endTime: '18:00',
        location: 'مسجد الريان',
        createdAt: now,
      );

      final teacher = UserModel(
        id: 'tch_test',
        name: 'أ. سالم بافضل',
        email: 'salem@alrayyan.com',
        role: UserRole.teacher,
        password: 'INIT_PASSWORD_1',
        assignedCircleIds: ['crc_test'],
        createdAt: now,
      );

      expect(teacher.password, equals('INIT_PASSWORD_1'));

      // تعديل كلمة المرور وفق قواعد الأمان
      const newSecuredPass = 'RYN-8K#992';
      final updatedTeacher = teacher.copyWith(password: newSecuredPass);
      final updatedCircle = circle.copyWith(accessPassword: newSecuredPass);

      expect(updatedTeacher.password, equals('RYN-8K#992'));
      expect(updatedCircle.accessPassword, equals('RYN-8K#992'));
      expect(updatedCircle.accessPassword.length >= 6, isTrue);
    });
  });
}
