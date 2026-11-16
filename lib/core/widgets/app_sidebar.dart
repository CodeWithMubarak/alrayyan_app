import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../constants/app_colors.dart';
import '../constants/app_routes.dart';
import '../constants/app_enums.dart';
import '../services/app_data_store.dart';

/// الشريط الجانبي - يُستخدم كـ Drawer على الهاتف وكـ NavigationRail على الكمبيوتر
class AppSidebar extends ConsumerWidget {
  final bool isDrawer;

  const AppSidebar({super.key, this.isDrawer = true});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (isDrawer) {
      return Drawer(
        child: _buildContent(context, ref),
      );
    }
    return SizedBox(
      width: 240,
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 4,
              offset: Offset(2, 0),
            ),
          ],
        ),
        child: _buildContent(context, ref),
      ),
    );
  }

  Widget _buildContent(BuildContext context, WidgetRef ref) {
    final currentLocation = GoRouterState.of(context).matchedLocation;
    final user = AppDataStore.instance.currentUser;
    final isTeacher = user?.role == UserRole.teacher;
    final isParent = user?.role == UserRole.parent;
    final isStudent = user?.role == UserRole.student;
    final isMedia = user?.role == UserRole.media;

    return Column(
      children: [
        // ===== رأس الشريط الجانبي =====
        _buildHeader(context),

        // ===== قائمة التنقل حسب الدور بدقة تامة =====
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(vertical: 8),
            children: [
              if (isStudent) ...[
                _buildNavItem(
                  context,
                  icon: Icons.dashboard_outlined,
                  selectedIcon: Icons.dashboard,
                  label: 'بوابة الطالب',
                  route: AppRoutes.dashboard,
                  isSelected: currentLocation == AppRoutes.dashboard || currentLocation == AppRoutes.studentDashboard,
                ),
                _buildNavItem(
                  context,
                  icon: Icons.menu_book_outlined,
                  selectedIcon: Icons.menu_book,
                  label: 'سجل الحفظ والمصحف',
                  route: AppRoutes.memorization,
                  isSelected: currentLocation.startsWith(AppRoutes.memorization),
                ),
                _buildNavItem(
                  context,
                  icon: Icons.menu_book_sharp,
                  selectedIcon: Icons.menu_book,
                  label: 'المتون العلمية',
                  route: AppRoutes.islamicTexts,
                  isSelected: currentLocation.startsWith(AppRoutes.islamicTexts),
                ),
                _buildNavItem(
                  context,
                  icon: Icons.emoji_events_outlined,
                  selectedIcon: Icons.emoji_events,
                  label: 'أوسمتي والمتفوقون',
                  route: AppRoutes.achievements,
                  isSelected: currentLocation.startsWith(AppRoutes.achievements),
                ),
                _buildNavItem(
                  context,
                  icon: Icons.campaign_outlined,
                  selectedIcon: Icons.campaign,
                  label: 'الإعلانات والأنشطة',
                  route: AppRoutes.notifications,
                  isSelected: currentLocation.startsWith(AppRoutes.notifications),
                ),
              ] else if (isParent) ...[
                _buildNavItem(
                  context,
                  icon: Icons.family_restroom_outlined,
                  selectedIcon: Icons.family_restroom,
                  label: 'بوابة ولي الأمر',
                  route: AppRoutes.dashboard,
                  isSelected: currentLocation == AppRoutes.dashboard || currentLocation == AppRoutes.parentDashboard,
                ),
                _buildNavItem(
                  context,
                  icon: Icons.people_outline,
                  selectedIcon: Icons.people,
                  label: 'متابعة الأبناء',
                  route: AppRoutes.students,
                  isSelected: currentLocation.startsWith(AppRoutes.students),
                ),
                _buildNavItem(
                  context,
                  icon: Icons.menu_book_outlined,
                  selectedIcon: Icons.menu_book,
                  label: 'متابعة الحفظ',
                  route: AppRoutes.memorization,
                  isSelected: currentLocation.startsWith(AppRoutes.memorization),
                ),
                _buildNavItem(
                  context,
                  icon: Icons.menu_book_sharp,
                  selectedIcon: Icons.menu_book,
                  label: 'المتون العلمية',
                  route: AppRoutes.islamicTexts,
                  isSelected: currentLocation.startsWith(AppRoutes.islamicTexts),
                ),
                _buildNavItem(
                  context,
                  icon: Icons.emoji_events_outlined,
                  selectedIcon: Icons.emoji_events,
                  label: 'المتفوقون والأوسمة',
                  route: AppRoutes.achievements,
                  isSelected: currentLocation.startsWith(AppRoutes.achievements),
                ),
                _buildNavItem(
                  context,
                  icon: Icons.campaign_outlined,
                  selectedIcon: Icons.campaign,
                  label: 'الإعلانات والأنشطة',
                  route: AppRoutes.notifications,
                  isSelected: currentLocation.startsWith(AppRoutes.notifications),
                ),
              ] else if (isTeacher) ...[
                _buildNavItem(
                  context,
                  icon: Icons.dashboard_outlined,
                  selectedIcon: Icons.dashboard,
                  label: 'لوحة المدرس',
                  route: AppRoutes.teacherDashboard,
                  isSelected: currentLocation == AppRoutes.teacherDashboard || currentLocation == AppRoutes.dashboard,
                ),
                _buildNavItem(
                  context,
                  icon: Icons.groups_outlined,
                  selectedIcon: Icons.groups,
                  label: 'حلقاتي',
                  route: AppRoutes.circles,
                  isSelected: currentLocation.startsWith(AppRoutes.circles),
                ),
                _buildNavItem(
                  context,
                  icon: Icons.people_outline,
                  selectedIcon: Icons.people,
                  label: 'طلابي',
                  route: AppRoutes.students,
                  isSelected: currentLocation.startsWith(AppRoutes.students),
                ),
                _buildNavItem(
                  context,
                  icon: Icons.edit_note_outlined,
                  selectedIcon: Icons.edit_note,
                  label: 'الحضور والغياب',
                  route: AppRoutes.attendance,
                  isSelected: currentLocation.startsWith(AppRoutes.attendance),
                ),
                _buildNavItem(
                  context,
                  icon: Icons.menu_book_outlined,
                  selectedIcon: Icons.menu_book,
                  label: 'الحفظ والمراجعة',
                  route: AppRoutes.memorization,
                  isSelected: currentLocation.startsWith(AppRoutes.memorization),
                ),
                _buildNavItem(
                  context,
                  icon: Icons.quiz_outlined,
                  selectedIcon: Icons.quiz,
                  label: 'الاختبارات والدرجات',
                  route: AppRoutes.exams,
                  isSelected: currentLocation.startsWith(AppRoutes.exams),
                ),
                _buildNavItem(
                  context,
                  icon: Icons.menu_book_sharp,
                  selectedIcon: Icons.menu_book,
                  label: 'المتون العلمية',
                  route: AppRoutes.islamicTexts,
                  isSelected: currentLocation.startsWith(AppRoutes.islamicTexts),
                ),
                _buildNavItem(
                  context,
                  icon: Icons.emoji_events_outlined,
                  selectedIcon: Icons.emoji_events,
                  label: 'الإنجازات والمتفوقون',
                  route: AppRoutes.achievements,
                  isSelected: currentLocation.startsWith(AppRoutes.achievements),
                ),
                _buildNavItem(
                  context,
                  icon: Icons.campaign_outlined,
                  selectedIcon: Icons.campaign,
                  label: 'الإعلانات والأنشطة',
                  route: AppRoutes.notifications,
                  isSelected: currentLocation.startsWith(AppRoutes.notifications),
                ),
              ] else if (isMedia) ...[
                // بوابة المسؤول الإعلامي المستقلة تماماً
                _buildNavItem(
                  context,
                  icon: Icons.campaign_outlined,
                  selectedIcon: Icons.campaign,
                  label: 'بوابة الإعلام والنشر',
                  route: AppRoutes.mediaDashboard,
                  isSelected: currentLocation == AppRoutes.mediaDashboard || currentLocation == AppRoutes.dashboard,
                ),
                _buildNavItem(
                  context,
                  icon: Icons.announcement_outlined,
                  selectedIcon: Icons.announcement,
                  label: 'مركز الإعلانات والتعاميم',
                  route: AppRoutes.notifications,
                  isSelected: currentLocation.startsWith(AppRoutes.notifications),
                ),
                _buildNavItem(
                  context,
                  icon: Icons.emoji_events_outlined,
                  selectedIcon: Icons.emoji_events,
                  label: 'لوحة الشرف والأوسمة',
                  route: AppRoutes.achievements,
                  isSelected: currentLocation.startsWith(AppRoutes.achievements),
                ),
                _buildNavItem(
                  context,
                  icon: Icons.menu_book_sharp,
                  selectedIcon: Icons.menu_book,
                  label: 'المتون العلمية',
                  route: AppRoutes.islamicTexts,
                  isSelected: currentLocation.startsWith(AppRoutes.islamicTexts),
                ),
              ] else ...[
                // المدير العام فقط يرى كافة الصلاحيات والأقسام الإدارية والمالية
                _buildNavItem(
                  context,
                  icon: Icons.dashboard_outlined,
                  selectedIcon: Icons.dashboard,
                  label: 'لوحة التحكم',
                  route: AppRoutes.dashboard,
                  isSelected: currentLocation == AppRoutes.dashboard || currentLocation == AppRoutes.adminDashboard,
                ),
                _buildNavItem(
                  context,
                  icon: Icons.groups_outlined,
                  selectedIcon: Icons.groups,
                  label: 'الحلقات',
                  route: AppRoutes.circles,
                  isSelected: currentLocation.startsWith(AppRoutes.circles),
                ),
                _buildNavItem(
                  context,
                  icon: Icons.people_outline,
                  selectedIcon: Icons.people,
                  label: 'الطلاب',
                  route: AppRoutes.students,
                  isSelected: currentLocation.startsWith(AppRoutes.students),
                ),
                _buildNavItem(
                  context,
                  icon: Icons.edit_note_outlined,
                  selectedIcon: Icons.edit_note,
                  label: 'الحضور والغياب',
                  route: AppRoutes.attendance,
                  isSelected: currentLocation.startsWith(AppRoutes.attendance),
                ),
                _buildNavItem(
                  context,
                  icon: Icons.menu_book_outlined,
                  selectedIcon: Icons.menu_book,
                  label: 'الحفظ والمراجعة',
                  route: AppRoutes.memorization,
                  isSelected: currentLocation.startsWith(AppRoutes.memorization),
                ),
                _buildNavItem(
                  context,
                  icon: Icons.quiz_outlined,
                  selectedIcon: Icons.quiz,
                  label: 'الاختبارات والدرجات',
                  route: AppRoutes.exams,
                  isSelected: currentLocation.startsWith(AppRoutes.exams),
                ),
                _buildNavItem(
                  context,
                  icon: Icons.menu_book_sharp,
                  selectedIcon: Icons.menu_book,
                  label: 'المتون العلمية',
                  route: AppRoutes.islamicTexts,
                  isSelected: currentLocation.startsWith(AppRoutes.islamicTexts),
                ),
                _buildNavItem(
                  context,
                  icon: Icons.emoji_events_outlined,
                  selectedIcon: Icons.emoji_events,
                  label: 'الإنجازات والمتفوقون',
                  route: AppRoutes.achievements,
                  isSelected: currentLocation.startsWith(AppRoutes.achievements),
                ),
                _buildNavItem(
                  context,
                  icon: Icons.campaign_outlined,
                  selectedIcon: Icons.campaign,
                  label: 'الإعلانات والأنشطة',
                  route: AppRoutes.notifications,
                  isSelected: currentLocation.startsWith(AppRoutes.notifications),
                ),
                _buildNavItem(
                  context,
                  icon: Icons.payments_outlined,
                  selectedIcon: Icons.payments,
                  label: 'الرسوم المالية',
                  route: AppRoutes.fees,
                  isSelected: currentLocation.startsWith(AppRoutes.fees),
                ),
                _buildNavItem(
                  context,
                  icon: Icons.assignment_outlined,
                  selectedIcon: Icons.assignment,
                  label: 'التقارير',
                  route: AppRoutes.reports,
                  isSelected: currentLocation.startsWith(AppRoutes.reports),
                ),
                const Divider(indent: 16, endIndent: 16),
                _buildNavItem(
                  context,
                  icon: Icons.shield_outlined,
                  selectedIcon: Icons.shield,
                  label: 'المدرسون وقواعد الأمان',
                  route: AppRoutes.users,
                  isSelected: currentLocation.startsWith(AppRoutes.users),
                ),
                _buildNavItem(
                  context,
                  icon: Icons.settings_outlined,
                  selectedIcon: Icons.settings,
                  label: 'الإعدادات',
                  route: AppRoutes.settings,
                  isSelected: currentLocation.startsWith(AppRoutes.settings),
                ),
              ],
            ],
          ),
        ),

        // ===== أسفل الشريط - معلومات المستخدم =====
        _buildFooter(context),
      ],
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(AppColors.primaryGreenDark), Color(AppColors.primaryGreen)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // شعار المؤسسة
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.asset(
                  'assets/images/logo.jpg',
                  width: 70,
                  height: 70,
                  errorBuilder: (_, __, ___) => Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(51),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.mosque, color: Colors.white, size: 40),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'حلقات مسجد الريان',
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: 'Cairo',
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 2),
              Text(
                'تريم - دمون',
                style: TextStyle(
                  color: Colors.white.withAlpha(204),
                  fontFamily: 'Cairo',
                  fontSize: 11,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(AppColors.gold).withAlpha(77),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text(
                  '2026 – 2027',
                  style: TextStyle(
                    color: Color(AppColors.goldSoft),
                    fontFamily: 'Cairo',
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context, {
    required IconData icon,
    required IconData selectedIcon,
    required String label,
    required String route,
    required bool isSelected,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: isSelected ? const Color(AppColors.primaryGreenSoft).withAlpha(51) : null,
        borderRadius: BorderRadius.circular(10),
      ),
      child: ListTile(
        leading: Icon(
          isSelected ? selectedIcon : icon,
          color: isSelected ? const Color(AppColors.primaryGreenDark) : Colors.grey[600],
          size: 22,
        ),
        title: Text(
          label,
          style: TextStyle(
            fontFamily: 'Cairo',
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
            color: isSelected ? const Color(AppColors.primaryGreenDark) : Colors.grey[800],
          ),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        onTap: () {
          if (Scaffold.of(context).isDrawerOpen) {
            Navigator.pop(context);
          }
          context.go(route);
        },
        dense: true,
        visualDensity: const VisualDensity(vertical: -1),
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    final user = AppDataStore.instance.currentUser;
    final name = user?.name ?? 'المدير العام';
    final roleName = user?.role.displayName ?? 'مدير عام';
    final initial = name.isNotEmpty ? name[0] : 'م';

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: Color(AppColors.grey200))),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: const Color(AppColors.primaryGreenSoft).withAlpha(80),
              child: Text(
                initial,
                style: const TextStyle(
                  color: Color(AppColors.primaryGreenDark),
                  fontFamily: 'Cairo',
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    roleName,
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 11,
                      color: Colors.grey[600],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.logout, size: 18, color: Color(AppColors.error)),
              onPressed: () {
                AppDataStore.instance.currentUser = null;
                context.go(AppRoutes.login);
              },
              tooltip: 'تسجيل الخروج',
            ),
          ],
        ),
      ),
    );
  }
}
