import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_enums.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/services/app_data_store.dart';
import '../../../../core/widgets/app_sidebar.dart';
import '../../../../core/widgets/app_bottom_nav.dart';
import '../../../../data/models/islamic_text_model.dart';
import '../../../../data/models/student_model.dart';

class IslamicTextsScreen extends ConsumerStatefulWidget {
  const IslamicTextsScreen({super.key});

  @override
  ConsumerState<IslamicTextsScreen> createState() => _IslamicTextsScreenState();
}

class _IslamicTextsScreenState extends ConsumerState<IslamicTextsScreen>
    with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;
  late TabController _tab;
  IslamicTextModel? _selectedText;

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
    return Scaffold(
      backgroundColor: const Color(0xFFF5F3ED),
      appBar: isWide
          ? null
          : AppBar(
              backgroundColor: const Color(AppColors.primaryGreen),
              foregroundColor: Colors.white,
              title: const Text('المتون العلمية',
                  style: TextStyle(
                      fontFamily: 'Cairo', fontWeight: FontWeight.bold)),
              actions: [
                if (AppDataStore.instance.currentUser?.role == UserRole.admin ||
                    AppDataStore.instance.currentUser?.role == UserRole.viceAdmin)
                  IconButton(
                    icon: const Icon(Icons.add_circle_outline),
                    tooltip: 'إضافة متن جديد',
                    onPressed: () => _showAddNewTextDialog(context),
                  ),
              ],
              bottom: TabBar(
                controller: _tab,
                indicatorColor: const Color(AppColors.goldAccent),
                labelStyle: const TextStyle(
                    fontFamily: 'Cairo', fontWeight: FontWeight.bold),
                unselectedLabelStyle: const TextStyle(fontFamily: 'Cairo'),
                tabs: const [
                  Tab(text: '📚 المتون'),
                  Tab(text: '📊 تقدم الطلاب'),
                ],
              ),
            ),
      drawer: isWide ? null : const AppSidebar(),
      body: ListenableBuilder(
        listenable: AppDataStore.instance,
        builder: (context, _) {
          final store = AppDataStore.instance;
          return isWide
              ? Row(children: [
                  const AppSidebar(isDrawer: false),
                  Expanded(child: _buildBody(store)),
                ])
              : _buildBody(store);
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddProgressDialog(context),
        backgroundColor: const Color(AppColors.primaryGreen),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.edit_note),
        label: const Text('تسجيل جلسة',
            style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold)),
      ),
      bottomNavigationBar: isWide
          ? null
          : AppBottomNav(
              selectedIndex: _selectedIndex,
              onIndexChanged: (i) => setState(() => _selectedIndex = i),
            ),
    );
  }

  Widget _buildBody(AppDataStore store) {
    return TabBarView(
      controller: _tab,
      children: [
        _buildTextsList(store),
        _buildProgressView(store),
      ],
    );
  }

  // ===== قائمة المتون =====
  Widget _buildTextsList(AppDataStore store) {
    final isAdmin = store.currentUser?.role == UserRole.admin ||
        store.currentUser?.role == UserRole.viceAdmin;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (isAdmin)
          Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF103D32), Color(0xFF1B5E20)],
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: const Color(AppColors.primaryGreen).withAlpha(40),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(AppColors.goldAccent).withAlpha(40),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.library_add, color: Color(AppColors.goldAccent), size: 24),
                ),
                const SizedBox(width: 14),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'إدارة المتون الشرعية',
                        style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold, fontSize: 14, color: Colors.white),
                      ),
                      Text(
                        'بصفتك مديراً يمكنك اعتماد وإضافة أي متن علمي جديد للمسجد',
                        style: TextStyle(fontFamily: 'Cairo', fontSize: 11, color: Colors.white70),
                      ),
                    ],
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () => _showAddNewTextDialog(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(AppColors.goldAccent),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text('إضافة متن', style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold, fontSize: 12)),
                ),
              ],
            ),
          ),
        ...store.islamicTexts.map((text) => _buildTextCard(text, store)),
      ],
    );
  }

  Widget _buildTextCard(IslamicTextModel text, AppDataStore store) {
    final levelColor = _levelColor(text.level);
    final studentsWithProgress = store.islamicTextProgress
        .where((p) => p.textId == text.id && p.memorizedLines > 0)
        .length;
    final completedStudents = store.islamicTextProgress
        .where((p) => p.textId == text.id && p.isCompleted)
        .length;

    return GestureDetector(
      onTap: () {
        setState(() => _selectedText = text);
        _tab.animateTo(1);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(color: Colors.black.withAlpha(8), blurRadius: 8),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 55,
              height: 55,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [levelColor.withAlpha(60), levelColor.withAlpha(30)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Center(
                child: Text('📖', style: TextStyle(fontSize: 26)),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(text.name,
                            style: const TextStyle(
                                fontFamily: 'Cairo',
                                fontWeight: FontWeight.bold,
                                fontSize: 15)),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: levelColor.withAlpha(20),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(text.level,
                            style: TextStyle(
                                fontFamily: 'Cairo',
                                fontSize: 10,
                                color: levelColor,
                                fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(text.description,
                      style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 12,
                          color: Colors.grey.shade500)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _buildMiniStat(
                          '${text.totalLines} بيت', Icons.format_list_numbered),
                      const SizedBox(width: 12),
                      _buildMiniStat('$studentsWithProgress يدرس',
                          Icons.people_outline),
                      const SizedBox(width: 12),
                      _buildMiniStat('$completedStudents أتقن', Icons.check_circle_outline),
                    ],
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios,
                size: 14, color: Color(AppColors.primaryGreen)),
          ],
        ),
      ),
    );
  }

  Widget _buildMiniStat(String label, IconData icon) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: const Color(AppColors.primaryGreen)),
        const SizedBox(width: 3),
        Text(label,
            style: const TextStyle(
                fontFamily: 'Cairo', fontSize: 11, color: Color(0xFF555555))),
      ],
    );
  }

  // ===== تقدم الطلاب =====
  Widget _buildProgressView(AppDataStore store) {
    final texts = store.islamicTexts;
    final students = store.getVisibleStudents();

    if (students.isEmpty) {
      return const Center(
        child: Text('لا يوجد طلاب مسجلون بعد',
            style: TextStyle(fontFamily: 'Cairo', fontSize: 16)),
      );
    }

    return Column(
      children: [
        // فلتر المتون
        Container(
          height: 50,
          color: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              GestureDetector(
                onTap: () => setState(() => _selectedText = null),
                child: _filterChip('الكل', _selectedText == null),
              ),
              const SizedBox(width: 8),
              ...texts.map((t) => Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedText = t),
                      child: _filterChip(t.name, _selectedText?.id == t.id),
                    ),
                  )),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: students.length,
            itemBuilder: (ctx, i) {
              final student = students[i];
              final progressList = _selectedText != null
                  ? store.islamicTextProgress
                      .where((p) =>
                          p.studentId == student.id &&
                          p.textId == _selectedText!.id)
                      .toList()
                  : store.islamicTextProgress
                      .where((p) => p.studentId == student.id)
                      .toList();
              return _buildStudentProgressCard(student, progressList, store);
            },
          ),
        ),
      ],
    );
  }

  Widget _filterChip(String label, bool selected) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      decoration: BoxDecoration(
        color: selected ? const Color(AppColors.primaryGreen) : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(label,
          style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: selected ? Colors.white : Colors.grey.shade700)),
    );
  }

  Widget _buildStudentProgressCard(StudentModel student,
      List<IslamicTextProgressModel> progressList, AppDataStore store) {
    final totalTexts = store.islamicTexts.length;
    final completedTexts = progressList.where((p) => p.isCompleted).length;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(color: Colors.black.withAlpha(8), blurRadius: 6),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: const Color(AppColors.primaryGreen).withAlpha(20),
                child: Text(
                  student.fullName.isNotEmpty ? student.fullName[0] : '؟',
                  style: const TextStyle(
                      fontFamily: 'Cairo',
                      color: Color(AppColors.primaryGreen),
                      fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(student.fullName,
                        style: const TextStyle(
                            fontFamily: 'Cairo',
                            fontWeight: FontWeight.bold,
                            fontSize: 14)),
                    Text(student.circleName,
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
                  Text('$completedTexts/$totalTexts',
                      style: const TextStyle(
                          fontFamily: 'Cairo',
                          fontWeight: FontWeight.bold,
                          color: Color(AppColors.primaryGreen))),
                  const Text('متن مكتمل',
                      style: TextStyle(fontFamily: 'Cairo', fontSize: 10)),
                ],
              ),
            ],
          ),
          if (progressList.isNotEmpty) ...[
            const SizedBox(height: 10),
            const Divider(height: 1),
            const SizedBox(height: 8),
            ...progressList.map((p) => _buildProgressBar(p)),
          ] else ...[
            const SizedBox(height: 8),
            Text(
              'لم يبدأ أي متن بعد',
              style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 12,
                  color: Colors.grey.shade400),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildProgressBar(IslamicTextProgressModel p) {
    final pct = p.progressPercent / 100;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(p.textName,
                style: const TextStyle(fontFamily: 'Cairo', fontSize: 12)),
          ),
          Expanded(
            flex: 5,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: pct,
                backgroundColor: Colors.grey.shade100,
                color: p.isCompleted
                    ? const Color(AppColors.goldAccent)
                    : const Color(AppColors.primaryGreen),
                minHeight: 8,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '${p.progressPercent.toStringAsFixed(0)}%',
            style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: p.isCompleted
                    ? const Color(AppColors.goldAccent)
                    : const Color(AppColors.primaryGreen)),
          ),
        ],
      ),
    );
  }

  Color _levelColor(String level) {
    switch (level) {
      case 'مبتدئ':
        return const Color(0xFF388E3C);
      case 'متوسط':
        return const Color(0xFF1976D2);
      case 'متقدم':
        return const Color(AppColors.goldAccent);
      default:
        return Colors.grey;
    }
  }

  void _showAddProgressDialog(BuildContext context) {
    final store = AppDataStore.instance;
    final students = store.getVisibleStudents();
    final texts = store.islamicTexts;
    if (students.isEmpty || texts.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('يرجى إضافة طلاب أولاً',
            style: TextStyle(fontFamily: 'Cairo')),
      ));
      return;
    }

    StudentModel? selectedStudent = students.first;
    IslamicTextModel? selectedText = texts.first;
    final linesCtrl = TextEditingController();
    final notesCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) => AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Row(
            children: [
              Text('📖', style: TextStyle(fontSize: 22)),
              SizedBox(width: 8),
              Text('تسجيل جلسة متن',
                  style: TextStyle(
                      fontFamily: 'Cairo', fontWeight: FontWeight.bold)),
            ],
          ),
          content: SizedBox(
            width: 380,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<StudentModel>(
                    value: selectedStudent,
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
                                  style:
                                      const TextStyle(fontFamily: 'Cairo')),
                            ))
                        .toList(),
                    onChanged: (v) => setS(() => selectedStudent = v),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<IslamicTextModel>(
                    value: selectedText,
                    decoration: InputDecoration(
                      labelText: 'المتن',
                      labelStyle: const TextStyle(fontFamily: 'Cairo'),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                    items: texts
                        .map((t) => DropdownMenuItem(
                              value: t,
                              child: Text(t.name,
                                  style:
                                      const TextStyle(fontFamily: 'Cairo')),
                            ))
                        .toList(),
                    onChanged: (v) => setS(() => selectedText = v),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: linesCtrl,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText:
                          'عدد الأبيات المحفوظة (من ${selectedText?.totalLines ?? 0})',
                      labelStyle: const TextStyle(fontFamily: 'Cairo'),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                    style: const TextStyle(fontFamily: 'Cairo'),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: notesCtrl,
                    decoration: InputDecoration(
                      labelText: 'ملاحظات',
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
                backgroundColor: const Color(AppColors.primaryGreen),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              icon: const Icon(Icons.save, size: 16),
              label: const Text('حفظ',
                  style: TextStyle(fontFamily: 'Cairo')),
              onPressed: () {
                if (selectedStudent == null || selectedText == null) return;
                final lines = int.tryParse(linesCtrl.text) ?? 0;
                store.updateIslamicTextProgress(IslamicTextProgressModel(
                  id: 'itp_${DateTime.now().millisecondsSinceEpoch}',
                  studentId: selectedStudent!.id,
                  studentName: selectedStudent!.fullName,
                  textId: selectedText!.id,
                  textName: selectedText!.name,
                  memorizedLines: lines.clamp(0, selectedText!.totalLines),
                  totalLines: selectedText!.totalLines,
                  notes: notesCtrl.text,
                  lastSession: DateTime.now(),
                  createdAt: DateTime.now(),
                ));
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text('✅ تم تسجيل الجلسة بنجاح',
                      style: TextStyle(fontFamily: 'Cairo')),
                  backgroundColor: Color(AppColors.primaryGreen),
                ));
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showAddNewTextDialog(BuildContext context) {
    final nameCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    final linesCtrl = TextEditingController();
    String selectedLevel = 'مبتدئ';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Row(
            children: [
              Icon(Icons.library_add, color: Color(AppColors.primaryGreen)),
              SizedBox(width: 8),
              Text(
                'إضافة متن علمي جديد',
                style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(
                    labelText: 'اسم المتن * (مثال: البيقونية، نونية القحطاني)',
                    prefixIcon: Icon(Icons.book_outlined),
                  ),
                  style: const TextStyle(fontFamily: 'Cairo'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: descCtrl,
                  decoration: const InputDecoration(
                    labelText: 'وصف المتن أو تخصصه (مثال: في علم مصطلح الحديث)',
                    prefixIcon: Icon(Icons.info_outline),
                  ),
                  style: const TextStyle(fontFamily: 'Cairo'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: linesCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'عدد الأبيات أو السطور * (مثال: 34)',
                    prefixIcon: Icon(Icons.format_list_numbered),
                  ),
                  style: const TextStyle(fontFamily: 'Cairo'),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: selectedLevel,
                  decoration: const InputDecoration(
                    labelText: 'المستوى التعليمي للمتن',
                    prefixIcon: Icon(Icons.star_outline),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'مبتدئ', child: Text('مبتدئ', style: TextStyle(fontFamily: 'Cairo'))),
                    DropdownMenuItem(value: 'متوسط', child: Text('متوسط', style: TextStyle(fontFamily: 'Cairo'))),
                    DropdownMenuItem(value: 'متقدم', child: Text('متقدم', style: TextStyle(fontFamily: 'Cairo'))),
                  ],
                  onChanged: (val) {
                    if (val != null) {
                      setDialogState(() => selectedLevel = val);
                    }
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('إلغاء', style: TextStyle(fontFamily: 'Cairo', color: Colors.grey)),
            ),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(AppColors.primaryGreen),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              icon: const Icon(Icons.add, size: 16),
              label: const Text('إضافة المتن للمنظومة', style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold)),
              onPressed: () {
                final name = nameCtrl.text.trim();
                final lines = int.tryParse(linesCtrl.text.trim()) ?? 0;
                if (name.isEmpty || lines <= 0) {
                  ScaffoldMessenger.of(ctx).showSnackBar(
                    const SnackBar(
                      content: Text('يرجى إدخال اسم المتن وعدد الأبيات بشكل صحيح', style: TextStyle(fontFamily: 'Cairo')),
                      backgroundColor: Color(AppColors.error),
                    ),
                  );
                  return;
                }

                final newText = IslamicTextModel(
                  id: 'txt_${DateTime.now().millisecondsSinceEpoch}',
                  name: name,
                  description: descCtrl.text.trim().isNotEmpty ? descCtrl.text.trim() : 'متن معتمد في حلقات المسجد',
                  totalLines: lines,
                  level: selectedLevel,
                  createdAt: DateTime.now(),
                );

                AppDataStore.instance.addIslamicText(newText);
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('✅ تم إضافة متن "$name" بنجاح للمنظومة', style: const TextStyle(fontFamily: 'Cairo')),
                    backgroundColor: const Color(AppColors.primaryGreen),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
