import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_enums.dart';
import '../../../../core/services/app_data_store.dart';
import '../../../../data/models/memorization_model.dart';
import '../../../../data/models/quran_progress_model.dart';

class MemorizationScreen extends ConsumerStatefulWidget {
  const MemorizationScreen({super.key});

  @override
  ConsumerState<MemorizationScreen> createState() => _MemorizationScreenState();
}

class _MemorizationScreenState extends ConsumerState<MemorizationScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String? _selectedStudentFilter;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F3ED),
      appBar: AppBar(
        backgroundColor: const Color(AppColors.primaryGreen),
        foregroundColor: Colors.white,
        title: const Text('منظومة القرآن الكريم والحفظ',
            style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold)),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: const Color(AppColors.goldAccent),
          labelStyle:
              const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold),
          unselectedLabelStyle: const TextStyle(fontFamily: 'Cairo'),
          tabs: const [
            Tab(text: 'الحفظ الجديد', icon: Icon(Icons.bookmark_add_outlined)),
            Tab(text: 'سجل المراجعة', icon: Icon(Icons.history_edu_outlined)),
            Tab(text: 'خريطة الأجزاء (30)', icon: Icon(Icons.grid_view_rounded)),
          ],
        ),
      ),
      body: ListenableBuilder(
        listenable: AppDataStore.instance,
        builder: (context, _) {
          return TabBarView(
            controller: _tabController,
            children: [
              _buildMemorizationList(isRevision: false),
              _buildMemorizationList(isRevision: true),
              _buildQuranMapTab(),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddSessionDialog,
        backgroundColor: const Color(AppColors.primaryGreen),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('تسجيل جلسة قرآنية',
            style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildMemorizationList({required bool isRevision}) {
    final store = AppDataStore.instance;
    final myStudentIds = store.getVisibleStudents().map((s) => s.id).toSet();
    final records = store.memorizationRecords
        .where((m) =>
            m.isRevision == isRevision && myStudentIds.contains(m.studentId))
        .toList();

    if (records.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: const Color(AppColors.primaryGreen).withAlpha(15),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isRevision ? Icons.history_edu : Icons.menu_book,
                size: 40,
                color: const Color(AppColors.primaryGreen),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              isRevision
                  ? 'لا توجد جلسات مراجعة مسجلة حتى الآن'
                  : 'لا توجد جلسات حفظ جديد مسجلة حتى الآن',
              style: const TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 16,
                  fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'اضغط على "تسجيل جلسة قرآنية" للبدء بالتدوين السريع',
              style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 12,
                  color: Colors.grey.shade600),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: records.length,
      itemBuilder: (context, index) {
        final item = records[index];
        final qColor = _getQualityColor(item.quality);
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(color: Colors.black.withAlpha(6), blurRadius: 8),
            ],
            border: Border(right: BorderSide(color: qColor, width: 4)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor:
                        const Color(AppColors.primaryGreen).withAlpha(20),
                    child: Text(
                      item.studentName.isNotEmpty ? item.studentName[0] : 'ط',
                      style: const TextStyle(
                        fontFamily: 'Cairo',
                        fontWeight: FontWeight.bold,
                        color: Color(AppColors.primaryGreen),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.studentName,
                          style: const TextStyle(
                            fontFamily: 'Cairo',
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                        Text(
                          '${item.date.year}/${item.date.month}/${item.date.day} • المعلم: ${item.teacherName}',
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 11,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: qColor.withAlpha(20),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      item.quality.displayName,
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: qColor,
                      ),
                    ),
                  ),
                ],
              ),
              const Divider(height: 20),
              Row(
                children: [
                  const Icon(Icons.auto_stories,
                      size: 16, color: Color(AppColors.goldAccent)),
                  const SizedBox(width: 8),
                  Text(
                    'سورة ${item.surah} (من آية ${item.fromAyah} إلى ${item.toAyah})',
                    style: const TextStyle(
                      fontFamily: 'Cairo',
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              if (item.notes != null && item.notes!.isNotEmpty) ...[
                const SizedBox(height: 6),
                Text(
                  'الملاحظات: ${item.notes}',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 12,
                    color: Colors.grey.shade700,
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  // ===== تبويب خريطة الأجزاء الثلاثين =====
  Widget _buildQuranMapTab() {
    final store = AppDataStore.instance;
    final students = store.getVisibleStudents();

    if (students.isEmpty) {
      return const Center(
        child: Text('لا يوجد طلاب مسجلون لعرض الخريطة القرآنية',
            style: TextStyle(fontFamily: 'Cairo', fontSize: 15)),
      );
    }

    _selectedStudentFilter ??= students.first.id;
    final selectedStudent = students.firstWhere(
      (s) => s.id == _selectedStudentFilter,
      orElse: () => students.first,
    );

    final prog = store.getQuranProgress(selectedStudent.id);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // شريط اختيار الطالب
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(color: Colors.black.withAlpha(6), blurRadius: 6),
              ],
            ),
            child: Row(
              children: [
                const Icon(Icons.person_search,
                    color: Color(AppColors.primaryGreen)),
                const SizedBox(width: 10),
                const Text('اختر الطالب:',
                    style: TextStyle(
                        fontFamily: 'Cairo', fontWeight: FontWeight.bold)),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButton<String>(
                    value: _selectedStudentFilter,
                    isExpanded: true,
                    underline: const SizedBox(),
                    items: students.map((s) {
                      return DropdownMenuItem(
                        value: s.id,
                        child: Text(s.fullName,
                            style: const TextStyle(fontFamily: 'Cairo')),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setState(() => _selectedStudentFilter = val);
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // كرت ملخص الإنجاز القرآني للطالب
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF103D32), Color(0xFF1B5E20)],
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'خطة وسجل: ${selectedStudent.fullName}',
                      style: const TextStyle(
                        fontFamily: 'Cairo',
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(AppColors.goldAccent),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '${(prog.overallProgress * 100).toStringAsFixed(1)}% مكتمل',
                        style: const TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  'آخر موضع وصل إليه: سورة ${prog.lastSurahName} (الآية ${prog.lastAyahNumber})',
                  style: const TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 13,
                    color: Color(AppColors.goldAccent),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'الصفحات المحفوظة: ${prog.totalMemorizedPages} من أصل 604 صفحة مصحف المدينة',
                  style: const TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 12,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: prog.overallProgress.clamp(0.0, 1.0),
                    backgroundColor: Colors.white24,
                    color: const Color(AppColors.goldAccent),
                    minHeight: 8,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // شبكة الأجزاء الثلاثين (30 Juz Grid)
          const Text(
            'الأجزاء القرآنية (1 - 30)',
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(AppColors.primaryGreen),
            ),
          ),
          const SizedBox(height: 10),

          LayoutBuilder(
            builder: (context, constraints) {
              final crossAxisCount = constraints.maxWidth > 700 ? 6 : (constraints.maxWidth > 420 ? 5 : 4);
              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  childAspectRatio: 1.3,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemCount: 30,
                itemBuilder: (ctx, i) {
                  final juzNumber = i + 1;
                  // اكتمال الأجزاء إذا كان الطالب حفظ صفحات تغطي هذا الجزء
                  final isDone = (prog.totalMemorizedPages >= (juzNumber * 20));
                  final isCurrent = !isDone &&
                      (prog.totalMemorizedPages >= ((juzNumber - 1) * 20));

                  return Container(
                    padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
                    decoration: BoxDecoration(
                      color: isDone
                          ? const Color(AppColors.primaryGreen)
                          : isCurrent
                              ? const Color(AppColors.goldAccent)
                              : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isDone
                            ? const Color(AppColors.primaryGreen)
                            : isCurrent
                                ? const Color(AppColors.goldAccent)
                                : Colors.grey.shade300,
                      ),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withAlpha(5), blurRadius: 4),
                      ],
                    ),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'جزء $juzNumber',
                            style: TextStyle(
                              fontFamily: 'Cairo',
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                              color: isDone || isCurrent ? Colors.white : Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Icon(
                            isDone
                                ? Icons.check_circle
                                : isCurrent
                                    ? Icons.hourglass_top
                                    : Icons.circle_outlined,
                            size: 14,
                            color: isDone || isCurrent ? Colors.white : Colors.grey,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Color _getQualityColor(MemorizationQuality q) {
    switch (q) {
      case MemorizationQuality.excellent:
        return const Color(0xFF2E7D32);
      case MemorizationQuality.veryGood:
        return const Color(0xFF1976D2);
      case MemorizationQuality.good:
        return const Color(AppColors.goldAccent);
      case MemorizationQuality.needsImprovement:
        return const Color(0xFFD32F2F);
    }
  }

  void _showAddSessionDialog() {
    final students = AppDataStore.instance.getVisibleStudents();
    if (students.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('يرجى إضافة طلاب للحلقات أولاً',
              style: TextStyle(fontFamily: 'Cairo')),
        ),
      );
      return;
    }

    String selectedStudentId = students.first.id;
    String selectedSurah = SurahInfo.allSurahs.first.name;
    final fromAyahCtrl = TextEditingController(text: '1');
    final toAyahCtrl = TextEditingController(text: '10');
    final notesCtrl = TextEditingController();
    MemorizationQuality quality = MemorizationQuality.excellent;
    bool isRevision = _tabController.index == 1;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (context, setSheetState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
            left: 20,
            right: 20,
            top: 20,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'تسجيل جلسة قرآنية ذكية',
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontWeight: FontWeight.bold,
                        fontSize: 17,
                        color: Color(AppColors.primaryGreen),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: selectedStudentId,
                  decoration: InputDecoration(
                    labelText: 'الطالب *',
                    labelStyle: const TextStyle(fontFamily: 'Cairo'),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  items: students.map((s) {
                    return DropdownMenuItem(
                      value: s.id,
                      child: Text('${s.fullName} (${s.circleName})',
                          style: const TextStyle(fontFamily: 'Cairo')),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) {
                      setSheetState(() => selectedStudentId = val);
                    }
                  },
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: selectedSurah,
                  decoration: InputDecoration(
                    labelText: 'السورة *',
                    labelStyle: const TextStyle(fontFamily: 'Cairo'),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  items: SurahInfo.allSurahs.map((surah) {
                    return DropdownMenuItem(
                      value: surah.name,
                      child: Text(
                          '${surah.number}. سورة ${surah.name} (${surah.ayahCount} آية)',
                          style: const TextStyle(fontFamily: 'Cairo')),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) {
                      setSheetState(() => selectedSurah = val);
                    }
                  },
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: fromAyahCtrl,
                        decoration: InputDecoration(
                          labelText: 'من آية',
                          labelStyle: const TextStyle(fontFamily: 'Cairo'),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: toAyahCtrl,
                        decoration: InputDecoration(
                          labelText: 'إلى آية',
                          labelStyle: const TextStyle(fontFamily: 'Cairo'),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<MemorizationQuality>(
                  initialValue: quality,
                  decoration: InputDecoration(
                    labelText: 'مستوى الإتقان والتسميع',
                    labelStyle: const TextStyle(fontFamily: 'Cairo'),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  items: MemorizationQuality.values.map((q) {
                    return DropdownMenuItem(
                      value: q,
                      child: Text(q.displayName,
                          style: const TextStyle(fontFamily: 'Cairo')),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) setSheetState(() => quality = val);
                  },
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    ChoiceChip(
                      label: const Text('حفظ جديد',
                          style: TextStyle(fontFamily: 'Cairo')),
                      selected: !isRevision,
                      selectedColor: const Color(AppColors.primaryGreen),
                      labelStyle: TextStyle(
                          color: !isRevision ? Colors.white : Colors.black87),
                      onSelected: (val) =>
                          setSheetState(() => isRevision = !val),
                    ),
                    const SizedBox(width: 8),
                    ChoiceChip(
                      label: const Text('مراجعة',
                          style: TextStyle(fontFamily: 'Cairo')),
                      selected: isRevision,
                      selectedColor: const Color(AppColors.goldAccent),
                      labelStyle: TextStyle(
                          color: isRevision ? Colors.white : Colors.black87),
                      onSelected: (val) =>
                          setSheetState(() => isRevision = val),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: notesCtrl,
                  decoration: InputDecoration(
                    labelText: 'ملاحظات التجويد والأخطاء',
                    alignLabelWithHint: true,
                    labelStyle: const TextStyle(fontFamily: 'Cairo'),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () {
                      final store = AppDataStore.instance;
                      final student = store.students
                          .firstWhere((s) => s.id == selectedStudentId);

                      final session = MemorizationModel(
                        id: 'mem_${DateTime.now().millisecondsSinceEpoch}',
                        studentId: student.id,
                        studentName: student.fullName,
                        circleId: student.circleId,
                        date: DateTime.now(),
                        surah: selectedSurah,
                        fromAyah: int.tryParse(fromAyahCtrl.text) ?? 1,
                        toAyah: int.tryParse(toAyahCtrl.text) ?? 10,
                        quality: quality,
                        notes: notesCtrl.text.trim(),
                        teacherId: store.currentUser?.id ?? 'tch_01',
                        teacherName: store.currentUser?.name ?? 'المدرس',
                        isRevision: isRevision,
                        createdAt: DateTime.now(),
                      );

                      store.addMemorizationSession(session);

                      // تحديث موضع تقدم القرآن للطالب
                      final currentProg = store.getQuranProgress(student.id);
                      final surahObj = SurahInfo.allSurahs.firstWhere(
                        (s) => s.name == selectedSurah,
                        orElse: () => SurahInfo.allSurahs.first,
                      );
                      store.updateQuranProgress(currentProg.copyWith(
                        lastSurahNumber: surahObj.number,
                        lastSurahName: surahObj.name,
                        lastAyahNumber: int.tryParse(toAyahCtrl.text) ?? 10,
                        totalMemorizedPages:
                            (currentProg.totalMemorizedPages + 1).clamp(0, 604),
                        updatedAt: DateTime.now(),
                      ));

                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('✅ تم حفظ جلسة التسميع وتحديث السجل القرآني بنجاح',
                              style: TextStyle(fontFamily: 'Cairo')),
                          backgroundColor: Color(AppColors.primaryGreen),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(AppColors.primaryGreen),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('حفظ واعتماد الجلسة',
                        style: TextStyle(
                            fontFamily: 'Cairo',
                            fontWeight: FontWeight.bold,
                            fontSize: 15)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
