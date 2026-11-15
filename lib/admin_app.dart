import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'core/theme/app_theme.dart';
import 'core/constants/app_routes.dart';
import 'core/constants/app_strings.dart';
import 'core/constants/app_enums.dart';
import 'core/services/app_data_store.dart';
import 'features/authentication/presentation/screens/admin_login_screen.dart';
import 'features/dashboard/presentation/screens/admin_dashboard_screen.dart';
import 'features/circles/presentation/screens/circles_screen.dart';
import 'features/circles/presentation/screens/add_circle_screen.dart';
import 'features/circles/presentation/screens/circle_detail_screen.dart';
import 'features/students/presentation/screens/students_screen.dart';
import 'features/students/presentation/screens/add_student_screen.dart';
import 'features/students/presentation/screens/student_detail_screen.dart';
import 'features/attendance/presentation/screens/attendance_screen.dart';
import 'features/memorization/presentation/screens/memorization_screen.dart';
import 'features/exams/presentation/screens/exams_screen.dart';
import 'features/fees/presentation/screens/fees_screen.dart';
import 'features/reports/presentation/screens/reports_screen.dart';
import 'features/users/presentation/screens/users_screen.dart';
import 'features/settings/presentation/screens/settings_screen.dart';
import 'features/islamic_texts/presentation/screens/islamic_texts_screen.dart';
import 'features/announcements/presentation/screens/announcements_screen.dart';
import 'features/achievements/presentation/screens/achievements_screen.dart';

final adminRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: AppRoutes.adminLogin,
    debugLogDiagnostics: false,
    routes: [
      GoRoute(
        path: AppRoutes.adminLogin,
        name: 'adminLogin',
        builder: (context, state) => const AdminLoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.dashboard,
        name: 'adminDashboard',
        builder: (context, state) => const AdminDashboardScreen(),
      ),
      GoRoute(
        path: AppRoutes.circles,
        name: 'circles',
        builder: (context, state) => const CirclesScreen(),
      ),
      GoRoute(
        path: AppRoutes.addCircle,
        name: 'addCircle',
        builder: (context, state) => const AddCircleScreen(),
      ),
      GoRoute(
        path: '${AppRoutes.circleDetail}/:id',
        name: 'circleDetail',
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          return CircleDetailScreen(circleId: id);
        },
      ),
      GoRoute(
        path: AppRoutes.students,
        name: 'students',
        builder: (context, state) => const StudentsScreen(),
      ),
      GoRoute(
        path: AppRoutes.addStudent,
        name: 'addStudent',
        builder: (context, state) {
          final circleId = state.uri.queryParameters['circleId'];
          return AddStudentScreen(initialCircleId: circleId);
        },
      ),
      GoRoute(
        path: '${AppRoutes.studentDetail}/:id',
        name: 'studentDetail',
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          return StudentDetailScreen(studentId: id);
        },
      ),
      GoRoute(
        path: AppRoutes.attendance,
        name: 'attendance',
        builder: (context, state) => const AttendanceScreen(),
      ),
      GoRoute(
        path: AppRoutes.memorization,
        name: 'memorization',
        builder: (context, state) => const MemorizationScreen(),
      ),
      GoRoute(
        path: AppRoutes.exams,
        name: 'exams',
        builder: (context, state) => const ExamsScreen(),
      ),
      GoRoute(
        path: AppRoutes.fees,
        name: 'fees',
        builder: (context, state) => const FeesScreen(),
      ),
      GoRoute(
        path: AppRoutes.reports,
        name: 'reports',
        builder: (context, state) => const ReportsScreen(),
      ),
      GoRoute(
        path: AppRoutes.users,
        name: 'users',
        builder: (context, state) => const UsersScreen(),
      ),
      GoRoute(
        path: AppRoutes.settings,
        name: 'settings',
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: AppRoutes.islamicTexts,
        name: 'islamicTexts',
        builder: (context, state) => const IslamicTextsScreen(),
      ),
      GoRoute(
        path: AppRoutes.notifications,
        name: 'notifications',
        builder: (context, state) => const AnnouncementsScreen(),
      ),
      GoRoute(
        path: AppRoutes.achievements,
        name: 'achievements',
        builder: (context, state) => const AchievementsScreen(),
      ),
    ],
  );
});

class AlRayyanAdminApp extends ConsumerWidget {
  const AlRayyanAdminApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(adminRouterProvider);

    return MaterialApp.router(
      title: 'إدارة حلقات مسجد الريان',
      debugShowCheckedModeBanner: false,
      locale: const Locale('ar', 'SA'),
      supportedLocales: const [
        Locale('ar', 'SA'),
        Locale('en', 'US'),
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: AppTheme.lightTheme,
      routerConfig: router,
      builder: (context, child) {
        return ResponsiveBreakpoints.builder(
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: child ?? const SizedBox.shrink(),
          ),
          breakpoints: const [
            Breakpoint(start: 0, end: 450, name: MOBILE),
            Breakpoint(start: 451, end: 800, name: TABLET),
            Breakpoint(start: 801, end: 1920, name: DESKTOP),
            Breakpoint(start: 1921, end: double.infinity, name: '4K'),
          ],
        );
      },
    );
  }
}
