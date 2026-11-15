import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/services/app_data_store.dart';
import '../../../../core/widgets/quran_daily_verse_card.dart';
import '../../../../core/widgets/app_sidebar.dart';
import '../../../../data/models/student_model.dart';
import '../../../../data/models/quran_progress_model.dart';

class StudentDashboardScreen extends ConsumerWidget {
  const StudentDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDesktop = MediaQuery.of(context).size.width > 800;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F3ED),
      appBar: isDesktop
          ? null
          : AppBar(
              backgroundColor: const Color(AppColors.primaryGreen),
              foregroundColor: Colors.white,
              title: const Text('بوابة الطالب',
                  style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold)),
              elevation: 0,
            ),
      drawer: isDesktop ? null : const AppSidebar(),
      body: ListenableBuilder(
        listenable: AppDataStore.instance,
        builder: (context, _) {
          return isDesktop
              ? const Row(
                  children: [
                    AppSidebar(isDrawer: false),
                    Expanded(child: _StudentDashboardContent()),
                  ],
                )
              : const _StudentDashboardContent();
        },
      ),
    );
  }
}

class _StudentDashboardContent extends StatelessWidget {
  const _StudentDashboardContent();

  @override
  Widget build(BuildContext context) {
    final store = AppDataStore.instance;
    // إذا كان المستخدم طالب نأخذ سجله، أو نأخذ أول طالب مسجل للعرض
    final student = store.students.isNotEmpty ? store.students.first : null;

    if (student == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.school_outlined, size: 70, color: Colors.grey),
            const SizedBox(height: 16),
            const Text('لم يتم تسجيل أي طالب حتى الآن',
                style: TextStyle(fontFamily: 'Cairo', fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('يقوم المدير بإضافة الطلاب وربطهم بالحلقات',
                style: TextStyle(fontFamily: 'Cairo', color: Colors.grey.shade600)),
          ],
        ),
      );
    }

    final attendanceRate = store.getStudentAttendanceRate(student.id);
    final achievements = store.getStudentAchievements(student.id);
    final memorization = store.getStudentMemorization(student.id);
    final quranProg = store.getQuranProgress(student.id);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // كرت الترحيب والملف الشخصي
          _buildWelcomeBanner(context, student, attendanceRate),
          const SizedBox(height: 16),

          // الحديث اليومي
          const QuranDailyVerseCard(),
          const SizedBox(height: 20),

          // بطاقات مؤشرات الأداء السريعة
          _buildQuickStats(student, attendanceRate, memorization.length, achievements.length),
          const SizedBox(height: 20),

          // خريطة الإنجاز القرآني (الهدف والموضع الحالي)
          _buildQuranProgressCard(context, quranProg, student),
          const SizedBox(height: 20),

          // الأوسمة والإنجازات
          _buildAchievementsSection(context, achievements),
          const SizedBox(height: 20),

          // آخر جلسات التسميع
          _buildRecentSessions(context, memorization),
        ],
      ),
    );
  }

  Widget _buildWelcomeBanner(BuildContext context, StudentModel student, double rate) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF103D32), Color(0xFF1B5E20)],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF103D32).withAlpha(50),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 32,
            backgroundColor: const Color(AppColors.goldAccent),
            child: Text(
              student.fullName.isNotEmpty ? student.fullName[0] : 'ط',
              style: const TextStyle(
                fontFamily: 'Cairo',
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'أهلاً بك يا ${student.fullName}',
                  style: const TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'حلقة: ${student.circleName} | المستوى: ${student.level}',
                  style: const TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 13,
                    color: Color(AppColors.goldAccent),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStats(StudentModel student, double rate, int hifzCount, int badgeCount) {
    return Row(
      children: [
        Expanded(
          child: _statItem(
            title: 'نسبة الحضور',
            value: '${rate.toStringAsFixed(0)}%',
            icon: Icons.check_circle_outline,
            color: const Color(0xFF2E7D32),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _statItem(
            title: 'جلسات التسميع',
            value: '$hifzCount',
            icon: Icons.menu_book_outlined,
            color: const Color(0xFF1976D2),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _statItem(
            title: 'الأوسمة',
            value: '$badgeCount',
            icon: Icons.emoji_events_outlined,
            color: const Color(AppColors.goldAccent),
          ),
        ),
      ],
    );
  }

  Widget _statItem({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withAlpha(6), blurRadius: 6),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: const TextStyle(
              fontFamily: 'Cairo',
              fontSize: 11,
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildQuranProgressCard(BuildContext context, QuranProgressModel prog, StudentModel student) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withAlpha(6), blurRadius: 8),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.auto_stories, color: Color(AppColors.primaryGreen)),
              SizedBox(width: 8),
              Text(
                'المنظومة القرآنية - آخر موضع والهدف',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(AppColors.primaryGreen),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F3ED),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('آخر موضع تم تسميعه:',
                        style: TextStyle(fontFamily: 'Cairo', fontSize: 11, color: Colors.grey)),
                    Text(
                      'سورة ${prog.lastSurahName} (الآية ${prog.lastAyahNumber})',
                      style: const TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Color(AppColors.primaryGreen),
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(AppColors.goldAccent).withAlpha(30),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'الهدف: ${prog.weeklyTargetPages} صفحات/أسبوع',
                    style: const TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Color(AppColors.primaryGreen),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('إجمالي الصفحات المحفوظة:',
                  style: TextStyle(fontFamily: 'Cairo', fontSize: 12)),
              Text(
                '${prog.totalMemorizedPages} من 604 صفحة',
                style: const TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Color(AppColors.primaryGreen),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: prog.overallProgress.clamp(0.0, 1.0),
              backgroundColor: Colors.grey.shade200,
              color: const Color(AppColors.goldAccent),
              minHeight: 10,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementsSection(BuildContext context, List achievements) {
    if (achievements.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Row(
          children: [
            Text('🏅', style: TextStyle(fontSize: 24)),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                'واصل الحفظ والمواظبة لتحصل على أوسمة التميز والتكريم!',
                style: TextStyle(fontFamily: 'Cairo', fontSize: 13, color: Colors.grey),
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'أوسمتي وإنجازاتي',
          style: TextStyle(
            fontFamily: 'Cairo',
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(AppColors.primaryGreen),
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 100,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: achievements.length,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (ctx, i) {
              final ach = achievements[i];
              return Container(
                width: 180,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(AppColors.goldAccent).withAlpha(50)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(ach.type.icon, style: const TextStyle(fontSize: 22)),
                    const SizedBox(height: 4),
                    Text(
                      ach.title,
                      style: const TextStyle(
                        fontFamily: 'Cairo',
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      ach.description,
                      style: const TextStyle(fontFamily: 'Cairo', fontSize: 10, color: Colors.grey),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildRecentSessions(BuildContext context, List memorization) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'سجل التسميع والمراجعة الأخير',
          style: TextStyle(
            fontFamily: 'Cairo',
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(AppColors.primaryGreen),
          ),
        ),
        const SizedBox(height: 10),
        if (memorization.isEmpty)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Center(
              child: Text(
                'لم يتم تسجيل جلسات تسميع بعد',
                style: TextStyle(fontFamily: 'Cairo', color: Colors.grey),
              ),
            ),
          )
        else
          ...memorization.take(5).map((m) {
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    m.isRevision ? Icons.history_edu : Icons.bookmark_added,
                    color: const Color(AppColors.primaryGreen),
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'سورة ${m.surah} (${m.fromAyah} - ${m.toAyah})',
                          style: const TextStyle(
                            fontFamily: 'Cairo',
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                        Text(
                          m.isRevision ? 'مراجعة' : 'حفظ جديد',
                          style: const TextStyle(fontFamily: 'Cairo', fontSize: 11, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(AppColors.primaryGreen).withAlpha(20),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      m.quality.displayName,
                      style: const TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Color(AppColors.primaryGreen),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
      ],
    );
  }
}
