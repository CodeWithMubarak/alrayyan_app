import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_enums.dart';
import '../../../../core/services/app_data_store.dart';
import '../../../../core/widgets/app_sidebar.dart';
import '../../../../core/widgets/app_bottom_nav.dart';
import '../../../../data/models/achievement_model.dart';
import '../../../../data/models/student_model.dart';

class AchievementsScreen extends ConsumerStatefulWidget {
  const AchievementsScreen({super.key});

  @override
  ConsumerState<AchievementsScreen> createState() => _AchievementsScreenState();
}

class _AchievementsScreenState extends ConsumerState<AchievementsScreen>
    with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;
  late TabController _tab;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 800;
    final store = AppDataStore.instance;
    final isAdmin = store.currentUser?.role == UserRole.admin ||
        store.currentUser?.role == UserRole.viceAdmin;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F3ED),
      appBar: isWide
          ? null
          : AppBar(
              backgroundColor: const Color(AppColors.primaryGreen),
              foregroundColor: Colors.white,
              title: const Text('الإنجازات والمتفوقون',
                  style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold)),
              bottom: TabBar(
                controller: _tab,
                indicatorColor: const Color(AppColors.goldAccent),
                labelStyle: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold),
                unselectedLabelStyle: const TextStyle(fontFamily: 'Cairo'),
                tabs: const [
                  Tab(text: '🏆 المتفوقون'),
                  Tab(text: '🏅 الأوسمة'),
                ],
              ),
            ),
      drawer: isWide ? null : const AppSidebar(),
      body: ListenableBuilder(
        listenable: AppDataStore.instance,
        builder: (context, _) {
          return isWide
              ? Row(children: [
                  const AppSidebar(isDrawer: false),
                  Expanded(child: _buildBody(store, isAdmin)),
                ])
              : _buildBody(store, isAdmin);
        },
      ),
      floatingActionButton: isAdmin
          ? FloatingActionButton.extended(
              onPressed: () => _showAwardDialog(context),
              backgroundColor: const Color(AppColors.goldAccent),
              foregroundColor: Colors.white,
              icon: const Icon(Icons.emoji_events),
              label: const Text('منح وسام',
                  style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold)),
            )
          : null,
      bottomNavigationBar: isWide
          ? null
          : AppBottomNav(
              selectedIndex: _selectedIndex,
              onIndexChanged: (i) => setState(() => _selectedIndex = i),
            ),
    );
  }

  Widget _buildBody(AppDataStore store, bool isAdmin) {
    return TabBarView(
      controller: _tab,
      children: [
        _buildLeaderboard(store),
        _buildAchievementsList(store, isAdmin),
      ],
    );
  }

  // ===== لوحة المتفوقين =====
  Widget _buildLeaderboard(AppDataStore store) {
    final students = store.getVisibleStudents();
    if (students.isEmpty) {
      return _buildEmptyStudents();
    }

    // ترتيب حسب نسبة الحضور + عدد الإنجازات
    final ranked = students.toList()
      ..sort((a, b) {
        final aScore = store.getStudentAttendanceRate(a.id) +
            store.getStudentAchievements(a.id).length * 10;
        final bScore = store.getStudentAttendanceRate(b.id) +
            store.getStudentAchievements(b.id).length * 10;
        return bScore.compareTo(aScore);
      });

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // بودية التفوق - أعلى 3
        if (ranked.length >= 3) _buildTopThreePodium(ranked, store),
        const SizedBox(height: 16),
        // بقية الطلاب
        ...ranked.asMap().entries.map(
          (e) => _buildStudentRankCard(e.key + 1, e.value, store),
        ),
      ],
    );
  }

  Widget _buildTopThreePodium(List<StudentModel> ranked, AppDataStore store) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF103D32), Color(0xFF1A5744)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(AppColors.primaryGreen).withAlpha(60),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text('🏆 المتفوقون',
              style: TextStyle(
                  fontFamily: 'Cairo',
                  color: Color(AppColors.goldAccent),
                  fontWeight: FontWeight.bold,
                  fontSize: 18)),
          const SizedBox(height: 20),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildPodiumItem(ranked[1], 2, 80, store),
              _buildPodiumItem(ranked[0], 1, 100, store),
              _buildPodiumItem(ranked[2], 3, 65, store),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPodiumItem(StudentModel s, int rank, double height, AppDataStore store) {
    final medals = ['🥇', '🥈', '🥉'];
    final colors = [
      const Color(0xFFC6A45C),
      const Color(0xFF9E9E9E),
      const Color(0xFFCD7F32),
    ];
    return Column(
      children: [
        CircleAvatar(
          radius: rank == 1 ? 32 : 26,
          backgroundColor: colors[rank - 1].withAlpha(40),
          child: Text(
            s.fullName.isNotEmpty ? s.fullName[0] : '؟',
            style: TextStyle(
              fontFamily: 'Cairo',
              fontWeight: FontWeight.bold,
              fontSize: rank == 1 ? 22 : 18,
              color: colors[rank - 1],
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(medals[rank - 1], style: const TextStyle(fontSize: 20)),
        const SizedBox(height: 4),
        Text(
          s.fullName.split(' ').first,
          style: const TextStyle(
            fontFamily: 'Cairo',
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
          textAlign: TextAlign.center,
        ),
        Text(
          '${store.getStudentAttendanceRate(s.id).toStringAsFixed(0)}%',
          style: TextStyle(
            fontFamily: 'Cairo',
            color: colors[rank - 1],
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  Widget _buildStudentRankCard(int rank, StudentModel s, AppDataStore store) {
    final rate = store.getStudentAttendanceRate(s.id);
    final achCount = store.getStudentAchievements(s.id).length;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(color: Colors.black.withAlpha(8), blurRadius: 6),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: rank <= 3
                  ? const Color(AppColors.goldAccent).withAlpha(30)
                  : Colors.grey.shade100,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '$rank',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontWeight: FontWeight.bold,
                  color: rank <= 3
                      ? const Color(AppColors.goldAccent)
                      : Colors.grey,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          CircleAvatar(
            radius: 20,
            backgroundColor: const Color(AppColors.primaryGreen).withAlpha(20),
            child: Text(
              s.fullName.isNotEmpty ? s.fullName[0] : '؟',
              style: const TextStyle(
                fontFamily: 'Cairo',
                color: Color(AppColors.primaryGreen),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(s.fullName,
                    style: const TextStyle(
                        fontFamily: 'Cairo',
                        fontWeight: FontWeight.bold,
                        fontSize: 14)),
                Text(s.circleName,
                    style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 11,
                        color: Colors.grey.shade500)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${rate.toStringAsFixed(0)}%',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: rate >= 80
                      ? const Color(AppColors.primaryGreen)
                      : rate >= 60
                          ? Colors.orange
                          : Colors.red,
                ),
              ),
              Row(
                children: List.generate(achCount.clamp(0, 5), (i) => const Text('⭐', style: TextStyle(fontSize: 10))),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ===== قائمة الأوسمة =====
  Widget _buildAchievementsList(AppDataStore store, bool isAdmin) {
    if (store.achievements.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                color: const Color(AppColors.goldAccent).withAlpha(20),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.emoji_events_outlined,
                  size: 45, color: Color(AppColors.goldAccent)),
            ),
            const SizedBox(height: 16),
            const Text('لا توجد أوسمة بعد',
                style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 18,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(
              'ابدأ بمنح أوسمة للطلاب المتميزين لتحفيزهم',
              style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 13,
                  color: Colors.grey.shade500),
            ),
          ],
        ),
      );
    }

    final sorted = List<AchievementModel>.from(store.achievements)
      ..sort((a, b) => b.awardedAt.compareTo(a.awardedAt));

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: sorted.length,
      itemBuilder: (ctx, i) => _buildAchievementCard(sorted[i]),
    );
  }

  Widget _buildAchievementCard(AchievementModel ach) {
    final color = Color(ach.type.colorValue);
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border(right: BorderSide(color: color, width: 4)),
        boxShadow: [
          BoxShadow(color: Colors.black.withAlpha(8), blurRadius: 6),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: color.withAlpha(20),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(ach.type.icon,
                  style: const TextStyle(fontSize: 24)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(ach.title,
                    style: const TextStyle(
                        fontFamily: 'Cairo',
                        fontWeight: FontWeight.bold,
                        fontSize: 14)),
                Text(ach.studentName,
                    style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 12,
                        color: Colors.grey.shade600)),
                Text(ach.description,
                    style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 12,
                        color: Colors.grey.shade500)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: color.withAlpha(20),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(ach.type.displayName,
                    style: TextStyle(
                        fontFamily: 'Cairo', fontSize: 10, color: color)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyStudents() {
    return const Center(
      child: Text('لا يوجد طلاب مسجلون بعد',
          style: TextStyle(fontFamily: 'Cairo', fontSize: 16)),
    );
  }

  void _showAwardDialog(BuildContext context) {
    final store = AppDataStore.instance;
    final students = store.getVisibleStudents();
    if (students.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('لا يوجد طلاب مسجلون بعد',
            style: TextStyle(fontFamily: 'Cairo')),
        backgroundColor: Colors.orange,
      ));
      return;
    }

    StudentModel? selected = students.first;
    AchievementType selectedType = AchievementType.excellence;
    final titleCtrl = TextEditingController();
    final descCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Row(
            children: [
              Text('🏅', style: TextStyle(fontSize: 22)),
              SizedBox(width: 8),
              Text('منح وسام',
                  style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold)),
            ],
          ),
          content: SizedBox(
            width: 380,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<StudentModel>(
                    value: selected,
                    decoration: InputDecoration(
                      labelText: 'الطالب',
                      labelStyle: const TextStyle(fontFamily: 'Cairo'),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                    items: students
                        .map((s) => DropdownMenuItem(
                              value: s,
                              child: Text(s.fullName,
                                  style: const TextStyle(fontFamily: 'Cairo')),
                            ))
                        .toList(),
                    onChanged: (v) => setS(() => selected = v),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<AchievementType>(
                    value: selectedType,
                    decoration: InputDecoration(
                      labelText: 'نوع الوسام',
                      labelStyle: const TextStyle(fontFamily: 'Cairo'),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                    items: AchievementType.values
                        .map((t) => DropdownMenuItem(
                              value: t,
                              child: Text('${t.icon} ${t.displayName}',
                                  style: const TextStyle(fontFamily: 'Cairo')),
                            ))
                        .toList(),
                    onChanged: (v) {
                      if (v != null) setS(() => selectedType = v);
                    },
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: titleCtrl,
                    decoration: InputDecoration(
                      labelText: 'عنوان الوسام *',
                      labelStyle: const TextStyle(fontFamily: 'Cairo'),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                    style: const TextStyle(fontFamily: 'Cairo'),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: descCtrl,
                    maxLines: 2,
                    decoration: InputDecoration(
                      labelText: 'سبب الوسام',
                      alignLabelWithHint: true,
                      labelStyle: const TextStyle(fontFamily: 'Cairo'),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                    style: const TextStyle(fontFamily: 'Cairo'),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('إلغاء',
                  style: TextStyle(fontFamily: 'Cairo', color: Colors.grey)),
            ),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(AppColors.goldAccent),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              icon: const Icon(Icons.emoji_events, size: 16),
              label: const Text('منح',
                  style: TextStyle(fontFamily: 'Cairo')),
              onPressed: () {
                if (selected == null || titleCtrl.text.trim().isEmpty) return;
                final user = store.currentUser!;
                store.addAchievement(AchievementModel(
                  id: 'ach_${DateTime.now().millisecondsSinceEpoch}',
                  studentId: selected!.id,
                  studentName: selected!.fullName,
                  type: selectedType,
                  title: titleCtrl.text.trim(),
                  description: descCtrl.text.trim(),
                  awardedAt: DateTime.now(),
                  awardedBy: user.id,
                  awardedByName: user.name,
                  circleId: selected!.circleId,
                ));
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text(
                      '🏅 تم منح ${selectedType.displayName} لـ${selected!.fullName}',
                      style: const TextStyle(fontFamily: 'Cairo')),
                  backgroundColor: const Color(AppColors.goldAccent),
                ));
              },
            ),
          ],
        ),
      ),
    );
  }
}
