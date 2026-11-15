import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../constants/app_routes.dart';
import '../constants/app_colors.dart';
import '../constants/app_enums.dart';
import '../services/app_data_store.dart';
import '../../features/authentication/presentation/screens/splash_screen.dart';
import '../../features/authentication/presentation/screens/login_screen.dart';
import '../../features/authentication/presentation/screens/admin_login_screen.dart';
import '../../features/dashboard/presentation/screens/admin_dashboard_screen.dart';
import '../../features/dashboard/presentation/screens/teacher_dashboard_screen.dart';
import '../../features/dashboard/presentation/screens/student_dashboard_screen.dart';
import '../../features/dashboard/presentation/screens/parent_dashboard_screen.dart';
import '../../features/announcements/presentation/screens/announcements_screen.dart';
import '../../features/achievements/presentation/screens/achievements_screen.dart';
import '../../features/islamic_texts/presentation/screens/islamic_texts_screen.dart';
import '../../features/circles/presentation/screens/circles_screen.dart';
import '../../features/circles/presentation/screens/add_circle_screen.dart';
import '../../features/circles/presentation/screens/circle_detail_screen.dart';
import '../../features/students/presentation/screens/students_screen.dart';
import '../../features/students/presentation/screens/add_student_screen.dart';
import '../../features/students/presentation/screens/student_detail_screen.dart';
import '../../features/attendance/presentation/screens/attendance_screen.dart';
import '../../features/memorization/presentation/screens/memorization_screen.dart';
import '../../features/exams/presentation/screens/exams_screen.dart';
import '../../features/fees/presentation/screens/fees_screen.dart';
import '../../features/reports/presentation/screens/reports_screen.dart';
import '../../features/users/presentation/screens/users_screen.dart';
import '../../features/settings/presentation/screens/settings_screen.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: AppRoutes.splash,
    debugLogDiagnostics: false,
    routes: [
      // ===== شاشة البداية =====
      GoRoute(
        path: AppRoutes.splash,
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),

      // ===== تسجيل الدخول العام للطلاب والمعلمين وأولياء الأمور =====
      GoRoute(
        path: AppRoutes.login,
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),

      // ===== بوابة تسجيل دخول المدير العام المستقلة تماماً =====
      GoRoute(
        path: AppRoutes.adminLogin,
        name: 'adminLogin',
        builder: (context, state) => const AdminLoginScreen(),
      ),

      // ===== لوحة التحكم حسب الدور =====
      GoRoute(
        path: AppRoutes.dashboard,
        name: 'dashboard',
        builder: (context, state) {
          final user = AppDataStore.instance.currentUser;
          if (user?.role == UserRole.student) {
            return const StudentDashboardScreen();
          } else if (user?.role == UserRole.parent) {
            return const ParentDashboardScreen();
          } else if (user?.role == UserRole.teacher) {
            return const TeacherDashboardScreen();
          }
          return const AdminDashboardScreen();
        },
        routes: [
          GoRoute(
            path: 'admin',
            name: 'adminDashboard',
            builder: (context, state) {
              final user = AppDataStore.instance.currentUser;
              if (user?.role != UserRole.admin && user?.role != UserRole.viceAdmin) {
                return const _UnauthorizedScreen();
              }
              return const AdminDashboardScreen();
            },
          ),
          GoRoute(
            path: 'teacher',
            name: 'teacherDashboard',
            builder: (context, state) => const TeacherDashboardScreen(),
          ),
          GoRoute(
            path: 'student',
            name: 'studentDashboard',
            builder: (context, state) => const StudentDashboardScreen(),
          ),
          GoRoute(
            path: 'parent',
            name: 'parentDashboard',
            builder: (context, state) => const ParentDashboardScreen(),
          ),
        ],
      ),

      // ===== المتون العلمية =====
      GoRoute(
        path: AppRoutes.islamicTexts,
        name: 'islamicTexts',
        builder: (context, state) => const IslamicTextsScreen(),
      ),

      // ===== الإنجازات والأوسمة والمتفوقون =====
      GoRoute(
        path: AppRoutes.achievements,
        name: 'achievements',
        builder: (context, state) => const AchievementsScreen(),
      ),

      // ===== الحلقات =====
      GoRoute(
        path: AppRoutes.circles,
        name: 'circles',
        builder: (context, state) => const CirclesScreen(),
        routes: [
          GoRoute(
            path: 'add',
            name: 'addCircle',
            builder: (context, state) {
              final user = AppDataStore.instance.currentUser;
              if (user?.role == UserRole.teacher) {
                return const _UnauthorizedScreen(message: 'إنشاء الحلقات وتعيين المدرسين من اختصاص المدير العام فقط.');
              }
              return const AddCircleScreen();
            },
          ),
          GoRoute(
            path: ':circleId',
            name: 'circleDetail',
            builder: (context, state) {
              final circleId = state.pathParameters['circleId'] ?? '';
              return CircleDetailScreen(circleId: circleId);
            },
          ),
        ],
      ),

      // ===== الطلاب =====
      GoRoute(
        path: AppRoutes.students,
        name: 'students',
        builder: (context, state) => const StudentsScreen(),
        routes: [
          GoRoute(
            path: 'add',
            name: 'addStudent',
            builder: (context, state) {
              final circleId = state.extra as String? ?? state.uri.queryParameters['circleId'];
              return AddStudentScreen(initialCircleId: circleId);
            },
          ),
          GoRoute(
            path: ':studentId',
            name: 'studentDetail',
            builder: (context, state) {
              final studentId = state.pathParameters['studentId'] ?? '';
              return StudentDetailScreen(studentId: studentId);
            },
          ),
        ],
      ),

      // ===== الحضور والغياب =====
      GoRoute(
        path: AppRoutes.attendance,
        name: 'attendance',
        builder: (context, state) => const AttendanceScreen(),
      ),

      // ===== الحفظ والمراجعة =====
      GoRoute(
        path: AppRoutes.memorization,
        name: 'memorization',
        builder: (context, state) => const MemorizationScreen(),
      ),

      // ===== الاختبارات والدرجات =====
      GoRoute(
        path: AppRoutes.exams,
        name: 'exams',
        builder: (context, state) => const ExamsScreen(),
      ),

      // ===== الرسوم المالية =====
      GoRoute(
        path: AppRoutes.fees,
        name: 'fees',
        builder: (context, state) {
          final user = AppDataStore.instance.currentUser;
          if (user?.role == UserRole.teacher) {
            return const _UnauthorizedScreen(message: 'إدارة السجلات المالية والرسوم محصورة بالإدارة العامة فقط.');
          }
          return const FeesScreen();
        },
      ),

      // ===== التقارير الشهرية =====
      GoRoute(
        path: AppRoutes.reports,
        name: 'reports',
        builder: (context, state) => const ReportsScreen(),
      ),

      // ===== المستخدمون والصلاحيات =====
      GoRoute(
        path: AppRoutes.users,
        name: 'users',
        builder: (context, state) {
          final user = AppDataStore.instance.currentUser;
          if (user?.role == UserRole.teacher) {
            return const _UnauthorizedScreen(message: 'إدارة حسابات المستخدمين وتوزيع الصلاحيات من اختصاص المدير العام فقط.');
          }
          return const UsersScreen();
        },
      ),

      // ===== الإعلانات والأنشطة =====
      GoRoute(
        path: AppRoutes.notifications,
        name: 'notifications',
        builder: (context, state) => const AnnouncementsScreen(),
      ),

      // ===== الإعدادات =====
      GoRoute(
        path: AppRoutes.settings,
        name: 'settings',
        builder: (context, state) {
          final user = AppDataStore.instance.currentUser;
          if (user?.role == UserRole.teacher) {
            return const _UnauthorizedScreen(message: 'إعدادات النظام العامة وسجلات التدقيق محصورة بالإدارة العامة.');
          }
          return const SettingsScreen();
        },
        routes: [
          GoRoute(
            path: 'audit-logs',
            name: 'auditLogs',
            builder: (context, state) => const _PlaceholderScreen(title: 'سجل العمليات والتدقيق'),
          ),
          GoRoute(
            path: 'backup',
            name: 'backup',
            builder: (context, state) => const _PlaceholderScreen(title: 'النسخ الاحتياطي السحابي والمحلي'),
          ),
        ],
      ),

      // ===== البحث العام =====
      GoRoute(
        path: AppRoutes.search,
        name: 'search',
        builder: (context, state) => const _PlaceholderScreen(title: 'البحث الشامل في المنظومة'),
      ),
    ],

    errorBuilder: (context, state) => Scaffold(
      appBar: AppBar(title: const Text('خطأ')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Color(AppColors.error)),
            const SizedBox(height: 16),
            const Text('الصفحة غير موجودة', style: TextStyle(fontFamily: 'Cairo', fontSize: 16)),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go(AppRoutes.dashboard),
              child: const Text('الرجوع للرئيسية', style: TextStyle(fontFamily: 'Cairo')),
            ),
          ],
        ),
      ),
    ),
  );
});

class _PlaceholderScreen extends StatelessWidget {
  final String title;
  const _PlaceholderScreen({required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.construction, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.grey[600],
                fontFamily: 'Cairo',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _UnauthorizedScreen extends StatelessWidget {
  final String message;

  const _UnauthorizedScreen({
    this.message = 'عذراً، هذه الصفحة مخصصة لإدارة المسجد والمدير العام فقط.',
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('غير مصرح')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.lock_outline, size: 70, color: Color(AppColors.warning)),
              const SizedBox(height: 16),
              const Text(
                'صلاحية غير كافية',
                style: TextStyle(fontFamily: 'Cairo', fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                message,
                style: const TextStyle(fontFamily: 'Cairo', color: Colors.grey, fontSize: 14),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () => context.go(AppRoutes.dashboard),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(AppColors.primaryGreen),
                  foregroundColor: Colors.white,
                ),
                icon: const Icon(Icons.arrow_back),
                label: const Text('العودة للرئيسية', style: TextStyle(fontFamily: 'Cairo')),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
