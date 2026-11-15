import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:responsive_framework/responsive_framework.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/app_routes.dart';
import '../../../../core/constants/app_enums.dart';
import '../../../../core/services/app_data_store.dart';
import '../../../../core/widgets/stat_card.dart';
import '../../../../core/widgets/app_sidebar.dart';
import '../../../../core/widgets/app_bottom_nav.dart';
import '../../../../core/widgets/quran_daily_verse_card.dart';

/// لوحة تحكم المدير العام
class AdminDashboardScreen extends ConsumerStatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  ConsumerState<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends ConsumerState<AdminDashboardScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final isDesktop = ResponsiveBreakpoints.of(context).isDesktop ||
        ResponsiveBreakpoints.of(context).isTablet;

    return Scaffold(
      appBar: isDesktop
          ? null
          : AppBar(
              title: const Text(AppStrings.dashboard),
              actions: [
                IconButton(
                  icon: const Icon(Icons.notifications_outlined),
                  onPressed: () => context.push(AppRoutes.notifications),
                ),
                IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () => context.push(AppRoutes.search),
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
                    Expanded(child: _buildDashboardContent(context)),
                  ],
                )
              : _buildDashboardContent(context);
        },
      ),
      bottomNavigationBar: isDesktop
          ? null
          : AppBottomNav(
              selectedIndex: _selectedIndex,
              onIndexChanged: (i) => setState(() => _selectedIndex = i),
            ),
    );
  }

  Widget _buildDashboardContent(BuildContext context) {
    final store = AppDataStore.instance;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context),
          const SizedBox(height: 16),
          const QuranDailyVerseCard(),
          const SizedBox(height: 16),
          if (store.circles.isEmpty) ...[
            _buildEmptyStateBanner(context),
            const SizedBox(height: 16),
          ],
          _buildStatsGrid(context),
          const SizedBox(height: 24),
          _buildQuickActionButtons(context),
          const SizedBox(height: 24),
          _buildAttendanceSection(context),
          const SizedBox(height: 24),
          _buildTopAndAttentionStudents(context),
          const SizedBox(height: 24),
          _buildFinancialSection(context),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildEmptyStateBanner(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(AppColors.goldSoft).withAlpha(40),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(AppColors.goldDark).withAlpha(100)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: const BoxDecoration(
              color: Color(AppColors.goldDark),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.star, color: Colors.white, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'انطلاقة جديدة: لا توجد حلقات قرآنية بعد',
                  style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold, fontSize: 13, color: Color(AppColors.primaryGreenDark)),
                ),
                Text(
                  'بادر الآن بإنشاء أول حلقة قرآنية واكتب اسم مدرسها ليبدأ الطلاب بالتسجيل.',
                  style: TextStyle(fontFamily: 'Cairo', fontSize: 11, color: Colors.grey[700]),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton.icon(
            onPressed: () => context.push(AppRoutes.addCircle),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(AppColors.primaryGreen),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            icon: const Icon(Icons.add, size: 16),
            label: const Text('إنشاء حلقة', style: TextStyle(fontFamily: 'Cairo', fontSize: 12, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final now = DateTime.now();
    final days = ['الأحد', 'الاثنين', 'الثلاثاء', 'الأربعاء', 'الخميس', 'الجمعة', 'السبت'];
    final months = ['يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو',
      'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر'];

    final store = AppDataStore.instance;

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
                  'مرحباً بك: ${store.currentUser?.name ?? "المدير العام"}',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  store.currentUser?.email ?? 'hymdyhmbarksyd@gmail.com',
                  style: const TextStyle(fontFamily: 'Cairo', fontSize: 11, color: Colors.white70),
                  textDirection: TextDirection.ltr,
                ),
                const SizedBox(height: 6),
                Text(
                  AppStrings.institutionName,
                  style: const TextStyle(fontFamily: 'Cairo', fontSize: 12, color: Color(AppColors.goldSoft)),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(50),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${days[now.weekday % 7]}، ${now.day} ${months[now.month - 1]} ${now.year} • ${AppStrings.academicYear}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(50),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.mosque, color: Colors.white, size: 32),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid(BuildContext context) {
    final isWide = ResponsiveBreakpoints.of(context).isDesktop;
    final store = AppDataStore.instance;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'نظرة عامة على المنظومة',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 12),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: isWide ? 4 : 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: isWide ? 1.6 : 1.35,
          children: [
            StatCard(
              icon: Icons.people_outline,
              title: AppStrings.totalStudents,
              value: '${store.students.length}',
              color: const Color(AppColors.primaryGreen),
              onTap: () => context.push(AppRoutes.students),
            ),
            StatCard(
              icon: Icons.groups_outlined,
              title: AppStrings.totalCircles,
              value: '${store.circles.length}',
              color: const Color(AppColors.goldDark),
              onTap: () => context.push(AppRoutes.circles),
            ),
            StatCard(
              icon: Icons.person_outline,
              title: AppStrings.totalTeachers,
              value: '${store.users.where((u) => u.role == UserRole.teacher).length}',
              color: const Color(AppColors.info),
              onTap: () => context.push(AppRoutes.users),
            ),
            StatCard(
              icon: Icons.check_circle_outline,
              title: 'الطلاب النشطون',
              value: '${store.students.length}',
              color: const Color(AppColors.success),
              onTap: () => context.push(AppRoutes.students),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAttendanceSection(BuildContext context) {
    final isWide = ResponsiveBreakpoints.of(context).isDesktop;
    final store = AppDataStore.instance;

    final present = store.totalPresentToday;
    final absent = store.totalAbsentToday;
    final total = present + absent;
    final rate = total > 0 ? '${(present / total * 100).toInt()}%' : '95%';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'الحضور والغياب اليوم',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            TextButton.icon(
              icon: const Icon(Icons.arrow_back_ios, size: 14),
              label: const Text('كشف الحضور'),
              onPressed: () => context.push(AppRoutes.attendance),
            ),
          ],
        ),
        const SizedBox(height: 12),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: isWide ? 3 : 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: isWide ? 1.6 : 1.35,
          children: [
            StatCard(
              icon: Icons.check_circle_outline,
              title: AppStrings.presentToday,
              value: '$present',
              color: const Color(AppColors.present),
              onTap: () => context.push(AppRoutes.attendance),
            ),
            StatCard(
              icon: Icons.cancel_outlined,
              title: AppStrings.absentToday,
              value: '$absent',
              color: const Color(AppColors.absent),
              onTap: () => context.push(AppRoutes.attendance),
            ),
            StatCard(
              icon: Icons.percent,
              title: AppStrings.attendanceRate,
              value: rate,
              color: const Color(AppColors.info),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFinancialSection(BuildContext context) {
    final store = AppDataStore.instance;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'الرسوم المالية',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            TextButton.icon(
              icon: const Icon(Icons.arrow_back_ios, size: 14),
              label: const Text('إدارة الرسوم'),
              onPressed: () => context.push(AppRoutes.fees),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: StatCard(
                icon: Icons.payments_outlined,
                title: AppStrings.totalFeesDue,
                value: '${store.totalFeesDue.toInt()} ر.ي',
                color: const Color(AppColors.warning),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: StatCard(
                icon: Icons.check_circle_outline,
                title: AppStrings.totalFeesCollected,
                value: '${store.totalFeesCollected.toInt()} ر.ي',
                color: const Color(AppColors.success),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickActionButtons(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'العمليات السريعة للمدير العام',
          style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold, fontSize: 15),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => context.push(AppRoutes.addCircle),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(AppColors.primaryGreen),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                icon: const Icon(Icons.add_circle_outline, size: 18),
                label: const Text('إنشاء حلقة جديدة', style: TextStyle(fontFamily: 'Cairo', fontSize: 12, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => context.push(AppRoutes.addStudent),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(AppColors.goldDark),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                icon: const Icon(Icons.person_add, size: 18),
                label: const Text('تسجيل طالب جديد', style: TextStyle(fontFamily: 'Cairo', fontSize: 12, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => context.push(AppRoutes.users),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  side: const BorderSide(color: Color(AppColors.primaryGreen), width: 1.2),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                icon: const Icon(Icons.key, size: 16, color: Color(AppColors.primaryGreen)),
                label: const Text('كلمات مرور المدرسين', style: TextStyle(fontFamily: 'Cairo', fontSize: 11, fontWeight: FontWeight.bold, color: Color(AppColors.primaryGreen))),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => context.push(AppRoutes.circles),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  side: const BorderSide(color: Color(AppColors.goldDark), width: 1.2),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                icon: const Icon(Icons.qr_code, size: 16, color: Color(AppColors.goldDark)),
                label: const Text('باركود الحلقات', style: TextStyle(fontFamily: 'Cairo', fontSize: 11, fontWeight: FontWeight.bold, color: Color(AppColors.goldDark))),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => context.push(AppRoutes.islamicTexts),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  side: const BorderSide(color: Color(0xFF1976D2), width: 1.2),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                icon: const Icon(Icons.menu_book, size: 16, color: Color(0xFF1976D2)),
                label: const Text('المتون العلمية', style: TextStyle(fontFamily: 'Cairo', fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF1976D2))),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => context.push(AppRoutes.notifications),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  side: BorderSide(color: Colors.grey.shade400),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                icon: const Icon(Icons.campaign, size: 16, color: Colors.black87),
                label: const Text('الإعلانات والأنشطة', style: TextStyle(fontFamily: 'Cairo', fontSize: 11, fontWeight: FontWeight.bold, color: Colors.black87)),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => context.push(AppRoutes.achievements),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  side: BorderSide(color: Colors.grey.shade400),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                icon: const Icon(Icons.emoji_events, size: 16, color: Color(AppColors.goldDark)),
                label: const Text('لوحة المتفوقين', style: TextStyle(fontFamily: 'Cairo', fontSize: 11, fontWeight: FontWeight.bold, color: Color(AppColors.goldDark))),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTopAndAttentionStudents(BuildContext context) {
    final store = AppDataStore.instance;
    final topStudents = store.topStudentsByAttendance;
    final attentionStudents = store.studentsNeedingAttention;

    if (store.students.isEmpty) {
      return const SizedBox();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'متابعة مستوى الطلاب والتميز',
              style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold, fontSize: 15),
            ),
            TextButton(
              onPressed: () => context.push(AppRoutes.achievements),
              child: const Text('عرض التفوق والأوسمة', style: TextStyle(fontFamily: 'Cairo', fontSize: 12)),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // الطلاب المتميزون
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withAlpha(5), blurRadius: 6),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.military_tech, color: Color(AppColors.goldAccent), size: 20),
                        SizedBox(width: 6),
                        Text('المتفوقون مواظبة', style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold, fontSize: 13)),
                      ],
                    ),
                    const SizedBox(height: 10),
                    if (topStudents.isEmpty)
                      const Text('لا توجد بيانات حضور بعد', style: TextStyle(fontFamily: 'Cairo', fontSize: 11, color: Colors.grey))
                    else
                      ...topStudents.take(3).map((s) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 12,
                              backgroundColor: const Color(AppColors.goldAccent).withAlpha(30),
                              child: Text(s.fullName.isNotEmpty ? s.fullName[0] : 'ط', style: const TextStyle(fontSize: 10, fontFamily: 'Cairo', fontWeight: FontWeight.bold)),
                            ),
                            const SizedBox(width: 8),
                            Expanded(child: Text(s.fullName, style: const TextStyle(fontFamily: 'Cairo', fontSize: 11), overflow: TextOverflow.ellipsis)),
                            Text('${store.getStudentAttendanceRate(s.id).toInt()}%', style: const TextStyle(fontFamily: 'Cairo', fontSize: 11, color: Colors.green, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      )),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
            // الطلاب المحتاجون للمتابعة
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withAlpha(5), blurRadius: 6),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.priority_high, color: Colors.orange, size: 20),
                        SizedBox(width: 6),
                        Text('يحتاجون متابعة', style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold, fontSize: 13)),
                      ],
                    ),
                    const SizedBox(height: 10),
                    if (attentionStudents.isEmpty)
                      const Text('الجميع مواظبون بشكل ممتاز 👏', style: TextStyle(fontFamily: 'Cairo', fontSize: 11, color: Colors.green))
                    else
                      ...attentionStudents.take(3).map((s) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 12,
                              backgroundColor: Colors.orange.withAlpha(30),
                              child: Text(s.fullName.isNotEmpty ? s.fullName[0] : 'ط', style: const TextStyle(fontSize: 10, fontFamily: 'Cairo', fontWeight: FontWeight.bold)),
                            ),
                            const SizedBox(width: 8),
                            Expanded(child: Text(s.fullName, style: const TextStyle(fontFamily: 'Cairo', fontSize: 11), overflow: TextOverflow.ellipsis)),
                            Text('${store.getStudentAttendanceRate(s.id).toInt()}%', style: const TextStyle(fontFamily: 'Cairo', fontSize: 11, color: Colors.red, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      )),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
