import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/services/app_data_store.dart';
import '../../../../core/widgets/app_sidebar.dart';
import '../../../../data/models/student_model.dart';

class ParentDashboardScreen extends ConsumerStatefulWidget {
  const ParentDashboardScreen({super.key});

  @override
  ConsumerState<ParentDashboardScreen> createState() => _ParentDashboardScreenState();
}

class _ParentDashboardScreenState extends ConsumerState<ParentDashboardScreen> {
  int _selectedChildIndex = 0;

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 800;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F3ED),
      appBar: isDesktop
          ? null
          : AppBar(
              backgroundColor: const Color(AppColors.primaryGreen),
              foregroundColor: Colors.white,
              title: const Text('بوابة ولي الأمر',
                  style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold)),
              elevation: 0,
            ),
      drawer: isDesktop ? null : const AppSidebar(),
      body: ListenableBuilder(
        listenable: AppDataStore.instance,
        builder: (context, _) {
          return isDesktop
              ? Row(
                  children: [
                    const AppSidebar(isDrawer: false),
                    Expanded(child: _buildBody(context)),
                  ],
                )
              : _buildBody(context);
        },
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    final store = AppDataStore.instance;
    final allStudents = store.getVisibleStudents();

    if (allStudents.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.family_restroom, size: 70, color: Colors.grey),
            const SizedBox(height: 16),
            const Text('لم يتم العثور على أبناء مرتبطين بحسابك',
                style: TextStyle(fontFamily: 'Cairo', fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('يرجى من إدارة المسجد ربط رقم هاتفك المسجل بملف الابن',
                style: TextStyle(fontFamily: 'Cairo', color: Colors.grey.shade600)),
          ],
        ),
      );
    }

    if (_selectedChildIndex >= allStudents.length) {
      _selectedChildIndex = 0;
    }
    final activeStudent = allStudents[_selectedChildIndex];

    final attendanceRate = store.getStudentAttendanceRate(activeStudent.id);
    final attendanceRecords = store.getStudentAttendance(activeStudent.id);
    final memorizationRecords = store.getStudentMemorization(activeStudent.id);
    final achievements = store.getStudentAchievements(activeStudent.id);
    final quranProg = store.getQuranProgress(activeStudent.id);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // شريط اختيار الابن (إذا كان لولي الأمر أكثر من ابن)
          if (allStudents.length > 1) ...[
            const Text(
              'اختر الابن للمتابعة:',
              style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold, fontSize: 14),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 48,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: allStudents.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (ctx, i) {
                  final s = allStudents[i];
                  final isSelected = i == _selectedChildIndex;
                  return ChoiceChip(
                    label: Text(s.fullName,
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          color: isSelected ? Colors.white : Colors.black87,
                        )),
                    selected: isSelected,
                    selectedColor: const Color(AppColors.primaryGreen),
                    backgroundColor: Colors.white,
                    onSelected: (val) {
                      if (val) setState(() => _selectedChildIndex = i);
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
          ],

          // كرت بطاقة الابن
          _buildChildCard(activeStudent, attendanceRate),
          const SizedBox(height: 16),

          // لوحة التنبيهات السريعة
          _buildAlertsSection(attendanceRecords),
          const SizedBox(height: 16),

          // ملخص الحفظ والتقدم القرآني
          _buildQuranSummary(quranProg, memorizationRecords.length),
          const SizedBox(height: 16),

          // الأوسمة والتميز
          if (achievements.isNotEmpty) ...[
            _buildAchievementsBadge(achievements),
            const SizedBox(height: 16),
          ],

          // تقارير وتواصل مع المعلم
          _buildTeacherContactCard(activeStudent),
        ],
      ),
    );
  }

  Widget _buildChildCard(StudentModel student, double rate) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF103D32), Color(0xFF1A5744)],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(AppColors.primaryGreen).withAlpha(50),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: const Color(AppColors.goldAccent),
            child: Text(
              student.fullName.isNotEmpty ? student.fullName[0] : 'ط',
              style: const TextStyle(
                fontFamily: 'Cairo',
                fontSize: 24,
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
                  student.fullName,
                  style: const TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  'الحلقة: ${student.circleName}',
                  style: const TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 13,
                    color: Color(AppColors.goldAccent),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'نسبة الالتزام والحضور: ${rate.toStringAsFixed(0)}%',
                  style: const TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 12,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlertsSection(List attendance) {
    final recentAbsence = attendance.where((a) => a.status.toString().contains('absent')).toList();
    if (recentAbsence.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.green.shade200),
        ),
        child: const Row(
          children: [
            Icon(Icons.verified, color: Colors.green),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                'حالة الابن ممتازة: لا يوجد غياب مسجل مؤخراً',
                style: TextStyle(fontFamily: 'Cairo', fontSize: 13, fontWeight: FontWeight.bold, color: Colors.green),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF3E0),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.orange.shade300),
      ),
      child: Row(
        children: [
          const Icon(Icons.warning_amber_rounded, color: Colors.orange),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'تنبيه: سُجل للطالب ${recentAbsence.length} مرات غياب. يرجى متابعة المعلم.',
              style: const TextStyle(fontFamily: 'Cairo', fontSize: 13, color: Colors.deepOrange),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuranSummary(dynamic prog, int totalSessions) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.menu_book, color: Color(AppColors.primaryGreen)),
              SizedBox(width: 8),
              Text(
                'متابعة الحفظ والتسميع',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Color(AppColors.primaryGreen),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'آخر موضع: سورة ${prog.lastSurahName} (آية ${prog.lastAyahNumber})',
            style: const TextStyle(fontFamily: 'Cairo', fontSize: 14, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          Text(
            'إجمالي جلسات التسميع المسجلة: $totalSessions جلسة',
            style: const TextStyle(fontFamily: 'Cairo', fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementsBadge(List achievements) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Text('🏆', style: TextStyle(fontSize: 20)),
              SizedBox(width: 8),
              Text(
                'أوسمة التميز التي نالها الطالب',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Color(AppColors.primaryGreen),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: achievements.map((ach) {
              return Chip(
                avatar: Text(ach.type.icon),
                label: Text(ach.title, style: const TextStyle(fontFamily: 'Cairo', fontSize: 11)),
                backgroundColor: const Color(AppColors.goldAccent).withAlpha(20),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildTeacherContactCard(StudentModel student) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.support_agent, color: Color(AppColors.primaryGreen)),
              SizedBox(width: 8),
              Text(
                'ملاحظات الإدارة والمعلم',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Color(AppColors.primaryGreen),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            student.educationalNotes ?? 'لا توجد ملاحظات خاصة مسجلة حالياً من المعلم.',
            style: const TextStyle(fontFamily: 'Cairo', fontSize: 13, color: Colors.black87),
          ),
        ],
      ),
    );
  }
}
