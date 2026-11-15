import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_enums.dart';
import '../../../../core/services/app_data_store.dart';

class ExamsScreen extends ConsumerStatefulWidget {
  const ExamsScreen({super.key});

  @override
  ConsumerState<ExamsScreen> createState() => _ExamsScreenState();
}

class _ExamsScreenState extends ConsumerState<ExamsScreen> {
  @override
  Widget build(BuildContext context) {
    final user = AppDataStore.instance.currentUser;
    final isTeacher = user?.role == UserRole.teacher;
    final demoExams = [
      {
        'title': 'اختبار الجزء الثلاثين - النبأ إلى الناس',
        'circleName': 'حلقة الفجر',
        'date': '2026/11/15',
        'type': 'اختبار حفظ',
        'questions': 5,
        'fullMark': 100,
      },
      {
        'title': 'اختبار التجويد واللغة العربية',
        'circleName': 'حلقة المغرب',
        'date': '2026/11/20',
        'type': 'اختبار لغة عربية',
        'questions': 5,
        'fullMark': 50,
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('الاختبارات والدرجات'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: demoExams.length,
        itemBuilder: (context, index) {
          final exam = demoExams[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(AppColors.primaryGreenSoft).withAlpha(50),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.quiz_outlined, color: Color(AppColors.primaryGreen)),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              exam['title'].toString(),
                              style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                            Text(
                              '${exam['circleName']} • ${exam['date']}',
                              style: TextStyle(fontFamily: 'Cairo', fontSize: 11, color: Colors.grey[600]),
                            ),
                          ],
                        ),
                      ),
                      Chip(
                        label: Text(
                          exam['type'].toString(),
                          style: const TextStyle(fontFamily: 'Cairo', fontSize: 11),
                        ),
                        backgroundColor: const Color(AppColors.grey100),
                      ),
                    ],
                  ),
                  const Divider(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'عدد الأسئلة: ${exam['questions']} | الدرجة الكاملة: ${exam['fullMark']}',
                        style: const TextStyle(fontFamily: 'Cairo', fontSize: 12, color: Colors.black87),
                      ),
                      ElevatedButton.icon(
                        onPressed: () => _showEnterGradesDialog(context, exam['title'].toString()),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(AppColors.primaryGreen),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        ),
                        icon: const Icon(Icons.grade_outlined, size: 16),
                        label: const Text('رصد الدرجات', style: TextStyle(fontFamily: 'Cairo', fontSize: 12)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: isTeacher
          ? null
          : FloatingActionButton.extended(
              onPressed: _showCreateExamDialog,
              backgroundColor: const Color(AppColors.primaryGreen),
              icon: const Icon(Icons.add),
              label: const Text('إنشاء اختبار جديد'),
            ),
    );
  }

  void _showEnterGradesDialog(BuildContext context, String examTitle) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('رصد درجات: $examTitle', style: const TextStyle(fontFamily: 'Cairo', fontSize: 15, fontWeight: FontWeight.bold)),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView(
            shrinkWrap: true,
            children: [
              _buildStudentGradeInput('محمد أحمد الحضرمي'),
              const SizedBox(height: 10),
              _buildStudentGradeInput('عبدالله محمد الكندي'),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء', style: TextStyle(fontFamily: 'Cairo'))),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('تم حفظ الدرجات وحساب التقديرات تلقائياً', style: TextStyle(fontFamily: 'Cairo'))),
              );
            },
            child: const Text('حفظ واحتساب', style: TextStyle(fontFamily: 'Cairo')),
          ),
        ],
      ),
    );
  }

  Widget _buildStudentGradeInput(String name) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: const Color(AppColors.grey100),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(child: Text(name, style: const TextStyle(fontFamily: 'Cairo', fontSize: 13, fontWeight: FontWeight.w600))),
          SizedBox(
            width: 70,
            child: TextField(
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                hintText: 'الدرجة',
                isDense: true,
                contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showCreateExamDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
          left: 20, right: 20, top: 20,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('إنشاء اختبار جديد', style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 16),
              TextFormField(decoration: const InputDecoration(labelText: 'اسم الاختبار')),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'نوع الاختبار'),
                items: const [
                  DropdownMenuItem(value: 'memorization', child: Text('اختبار حفظ', style: TextStyle(fontFamily: 'Cairo'))),
                  DropdownMenuItem(value: 'revision', child: Text('اختبار مراجعة', style: TextStyle(fontFamily: 'Cairo'))),
                  DropdownMenuItem(value: 'arabic', child: Text('اختبار لغة عربية', style: TextStyle(fontFamily: 'Cairo'))),
                  DropdownMenuItem(value: 'islamic_studies', child: Text('اختبار علوم شرعية', style: TextStyle(fontFamily: 'Cairo'))),
                ],
                onChanged: (_) {},
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: TextFormField(decoration: const InputDecoration(labelText: 'الدرجة الكاملة'), keyboardType: TextInputType.number)),
                  const SizedBox(width: 12),
                  Expanded(child: TextFormField(decoration: const InputDecoration(labelText: 'عدد الأسئلة'), keyboardType: TextInputType.number)),
                ],
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 46,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('تم إنشاء الاختبار بنجاح', style: TextStyle(fontFamily: 'Cairo'))),
                    );
                  },
                  child: const Text('إنشاء', style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
