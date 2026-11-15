import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:responsive_framework/responsive_framework.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_routes.dart';
import '../../../../core/constants/app_enums.dart';
import '../../../../core/services/app_data_store.dart';
import '../../../../core/widgets/stat_card.dart';
import '../../../../core/widgets/app_sidebar.dart';
import '../../../../core/widgets/app_bottom_nav.dart';
import '../../../../core/widgets/quran_daily_verse_card.dart';

/// لوحة تحكم المدرس
class TeacherDashboardScreen extends ConsumerStatefulWidget {
  const TeacherDashboardScreen({super.key});

  @override
  ConsumerState<TeacherDashboardScreen> createState() => _TeacherDashboardScreenState();
}

class _TeacherDashboardScreenState extends ConsumerState<TeacherDashboardScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final isDesktop = ResponsiveBreakpoints.of(context).isDesktop ||
        ResponsiveBreakpoints.of(context).isTablet;

    return Scaffold(
      appBar: isDesktop
          ? null
          : AppBar(
              title: const Text('لوحة المدرس والحلقات'),
              actions: [
                IconButton(
                  icon: const Icon(Icons.notifications_outlined),
                  onPressed: () => context.push(AppRoutes.notifications),
                ),
              ],
            ),
      drawer: isDesktop ? null : const AppSidebar(),
      body: ListenableBuilder(
        listenable: AppDataStore.instance,
        builder: (context, _) {
          return isDesktop
              ? Row(
                  children: [
                    const AppSidebar(isDrawer: false),
                    Expanded(child: _buildContent(context)),
                  ],
                )
              : _buildContent(context);
        },
      ),
      bottomNavigationBar: isDesktop
          ? null
          : AppBottomNav(
              selectedIndex: _selectedIndex,
              onIndexChanged: (i) => setState(() => _selectedIndex = i),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(AppRoutes.attendance),
        icon: const Icon(Icons.edit_note),
        label: const Text('تسجيل الحضور اليومي'),
        backgroundColor: const Color(AppColors.primaryGreen),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTeacherHeader(context),
          const SizedBox(height: 16),
          const QuranDailyVerseCard(),
          const SizedBox(height: 16),
          _buildTodayStats(context),
          const SizedBox(height: 20),
          _buildMyCircles(context),
          const SizedBox(height: 20),
          _buildRecentMemorization(context),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildTeacherHeader(BuildContext context) {
    final store = AppDataStore.instance;
    final teacherName = store.currentUser?.name ?? 'المدرس المعتمد';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(AppColors.primaryGreenDark), Color(AppColors.primaryGreen)],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(AppColors.primaryGreen).withAlpha(60),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'أهلاً وسهلاً، أستاذنا الفاضل',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  teacherName,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _buildQuickAction(
                      context,
                      icon: Icons.edit_note,
                      label: 'تسجيل الحضور',
                      onTap: () => context.push(AppRoutes.attendance),
                    ),
                    const SizedBox(width: 8),
                    _buildQuickAction(
                      context,
                      icon: Icons.menu_book,
                      label: 'تسجيل الحفظ',
                      onTap: () => context.push(AppRoutes.memorization),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(50),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.school, color: Colors.white, size: 28),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAction(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white.withAlpha(50),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 14),
            const SizedBox(width: 4),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontFamily: 'Cairo',
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMyCircles(BuildContext context) {
    final store = AppDataStore.instance;
    final circles = store.getVisibleCircles();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'حلقاتي المسندة إلي (${circles.length})',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            TextButton(
              onPressed: () => context.push(AppRoutes.circles),
              child: const Text('عرض الكل'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (circles.isEmpty)
          const Card(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'لم يتم إسناد أي حلقة لك حتى الآن، يرجى مراجعة إدارة المسجد',
                style: TextStyle(fontFamily: 'Cairo', color: Colors.grey),
              ),
            ),
          )
        else
          ...circles.map((c) {
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Color(AppColors.primaryGreen),
                  child: Icon(Icons.groups, color: Colors.white, size: 20),
                ),
                title: Text(c.name, style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold, fontSize: 13)),
                subtitle: Text('كود الحلقة: ${c.circleCode} • ${c.studentCount} طالب • ${c.level}', style: const TextStyle(fontFamily: 'Cairo', fontSize: 11)),
                trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                onTap: () => context.push('/circles/${c.id}'),
              ),
            );
          }),
      ],
    );
  }

  Widget _buildTodayStats(BuildContext context) {
    final store = AppDataStore.instance;
    final myStudentIds = store.getVisibleStudents().map((s) => s.id).toSet();
    final myAttendance = store.attendanceRecords.where((a) => myStudentIds.contains(a.studentId)).toList();
    final present = myAttendance.where((a) => a.status == AttendanceStatus.present).length;
    final absent = myAttendance.where((a) => a.status == AttendanceStatus.absent).length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'إحصائيات اليوم لحلقاتي',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: StatCard(
                icon: Icons.check_circle_outline,
                title: 'حاضرون اليوم',
                value: '$present',
                color: const Color(AppColors.present),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: StatCard(
                icon: Icons.cancel_outlined,
                title: 'غائبون اليوم',
                value: '$absent',
                color: const Color(AppColors.absent),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRecentMemorization(BuildContext context) {
    final store = AppDataStore.instance;
    final myStudentIds = store.getVisibleStudents().map((s) => s.id).toSet();
    final records = store.memorizationRecords.where((r) => myStudentIds.contains(r.studentId)).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'آخر جلسات الحفظ والتسميع',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            TextButton(
              onPressed: () => context.push(AppRoutes.memorization),
              child: const Text('عرض الكل'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (records.isEmpty)
          const Card(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Center(
                child: Text('لا توجد جلسات مسجلة اليوم', style: TextStyle(fontFamily: 'Cairo', color: Colors.grey)),
              ),
            ),
          )
        else
          ...records.take(3).map((r) {
            return Card(
              margin: const EdgeInsets.only(bottom: 6),
              child: ListTile(
                leading: const Icon(Icons.menu_book, color: Color(AppColors.goldDark)),
                title: Text(r.studentName, style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold, fontSize: 13)),
                subtitle: Text('${r.surah} (من ${r.fromAyah} إلى ${r.toAyah}) • ${r.quality.displayName}', style: const TextStyle(fontFamily: 'Cairo', fontSize: 11)),
              ),
            );
          }),
      ],
    );
  }
}
