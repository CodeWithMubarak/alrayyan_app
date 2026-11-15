import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_enums.dart';
import '../../../../core/services/app_data_store.dart';
import '../../../../data/models/student_model.dart';

class StudentDetailScreen extends ConsumerWidget {
  final String studentId;

  const StudentDetailScreen({super.key, required this.studentId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final store = AppDataStore.instance;
    final student = store.students.firstWhere(
      (s) => s.id == studentId,
      orElse: () => store.students.first,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(student.fullName),
        actions: [
          IconButton(
            icon: const Icon(Icons.print_outlined),
            tooltip: 'طباعة ملف الطالب',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('جارٍ إعداد وتصدير ملف الطالب PDF...', style: TextStyle(fontFamily: 'Cairo'))),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // بطاقة رأس الطالب
            Card(
              elevation: 3,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 32,
                      backgroundColor: const Color(AppColors.primaryGreenSoft).withAlpha(60),
                      child: Text(
                        student.fullName[0],
                        style: const TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Color(AppColors.primaryGreenDark),
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
                            style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${student.studentNumber} • ${student.circleName}',
                            style: TextStyle(fontFamily: 'Cairo', fontSize: 12, color: Colors.grey[700]),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(AppColors.successLight),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              student.status.displayName,
                              style: const TextStyle(
                                fontFamily: 'Cairo',
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: Color(AppColors.success),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // بيانات ولي الأمر والتواصل
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.family_restroom, color: Color(AppColors.primaryGreen), size: 20),
                        SizedBox(width: 8),
                        Text('بيانات ولي الأمر والتواصل', style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold, fontSize: 14)),
                      ],
                    ),
                    const Divider(height: 20),
                    _buildInfoRow('اسم ولي الأمر', student.guardianName),
                    const SizedBox(height: 8),
                    _buildInfoRow('صلة القرابة', student.guardianRelation),
                    const SizedBox(height: 8),
                    _buildInfoRow('رقم الهاتف الأساسي', student.guardianPhone),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => _callPhone(context, student.guardianPhone),
                            style: ElevatedButton.styleFrom(backgroundColor: const Color(AppColors.primaryGreen)),
                            icon: const Icon(Icons.phone, size: 16),
                            label: const Text('اتصال هاتفي', style: TextStyle(fontFamily: 'Cairo', fontSize: 12)),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => _openWhatsApp(context, student.guardianPhone, student.fullName),
                            style: ElevatedButton.styleFrom(backgroundColor: const Color(AppColors.success)),
                            icon: const Icon(Icons.chat, size: 16),
                            label: const Text('محادثة واتساب', style: TextStyle(fontFamily: 'Cairo', fontSize: 12)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // بيانات الأمان وتسجيل الدخول
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.security, color: Color(AppColors.goldDark), size: 20),
                        SizedBox(width: 8),
                        Text('بيانات الدخول وكلمات المرور', style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold, fontSize: 14)),
                      ],
                    ),
                    const Divider(height: 20),
                    _buildInfoRow('رقم دخول الطالب', student.studentNumber),
                    const SizedBox(height: 8),
                    _buildInfoRow('كلمة مرور الطالب', student.password ?? '123456'),
                    const SizedBox(height: 8),
                    _buildInfoRow('رقم هاتف ولي الأمر للدخول', student.guardianPhone),
                    const SizedBox(height: 8),
                    _buildInfoRow('كلمة مرور ولي الأمر', student.guardianPassword ?? '123456'),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        OutlinedButton.icon(
                          onPressed: () => _showEditPasswordsDialog(context, student),
                          icon: const Icon(Icons.edit, size: 16),
                          label: const Text('تعديل كلمات المرور', style: TextStyle(fontFamily: 'Cairo', fontSize: 12)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // إحصائيات الطالب التعليمية
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.analytics_outlined, color: Color(AppColors.goldDark), size: 20),
                        SizedBox(width: 8),
                        Text('سجل الإنجاز والنشاط', style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold, fontSize: 14)),
                      ],
                    ),
                    const Divider(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStatBox('نسبة الحضور', '95%', const Color(AppColors.primaryGreen)),
                        _buildStatBox('المحفوظ المتقن', 'سورة النبأ - النازعات', const Color(AppColors.goldDark)),
                        _buildStatBox('حالة الرسوم', 'مسدد', const Color(AppColors.success)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontFamily: 'Cairo', fontSize: 12, color: Colors.black54)),
        Text(value, style: const TextStyle(fontFamily: 'Cairo', fontSize: 13, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildStatBox(String label, String value, Color color) {
    return Column(
      children: [
        Text(value, style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold, fontSize: 14, color: color)),
        Text(label, style: TextStyle(fontFamily: 'Cairo', fontSize: 11, color: Colors.grey[600])),
      ],
    );
  }

  void _callPhone(BuildContext context, String phone) async {
    final uri = Uri.parse('tel:$phone');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('الاتصال بالرقم: $phone', style: const TextStyle(fontFamily: 'Cairo'))),
      );
    }
  }

  void _openWhatsApp(BuildContext context, String phone, String studentName) async {
    final message = Uri.encodeComponent('السلام عليكم ورحمة الله، ولي أمر الطالب $studentName، نتواصل معكم من حلقات مسجد الريان لتعليم القرآن الكريم.');
    final uri = Uri.parse('https://wa.me/967$phone?text=$message');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('فتح محادثة واتساب مع: $phone', style: const TextStyle(fontFamily: 'Cairo'))),
      );
    }
  }

  void _showEditPasswordsDialog(BuildContext context, StudentModel student) {
    final studentPassController = TextEditingController(text: student.password ?? '123456');
    final guardianPassController = TextEditingController(text: student.guardianPassword ?? '123456');

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text('تعديل كلمات المرور: ${student.fullName}', style: const TextStyle(fontFamily: 'Cairo', fontSize: 16)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: studentPassController,
                decoration: const InputDecoration(
                  labelText: 'كلمة مرور الطالب',
                  prefixIcon: Icon(Icons.lock_outline),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: guardianPassController,
                decoration: const InputDecoration(
                  labelText: 'كلمة مرور ولي الأمر',
                  prefixIcon: Icon(Icons.lock_person),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('إلغاء', style: TextStyle(fontFamily: 'Cairo')),
            ),
            ElevatedButton(
              onPressed: () {
                final sPass = studentPassController.text.trim();
                final gPass = guardianPassController.text.trim();
                AppDataStore.instance.updateStudentPassword(student.id, sPass.isNotEmpty ? sPass : '123456');
                AppDataStore.instance.updateGuardianPassword(student.id, gPass.isNotEmpty ? gPass : '123456');
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('تم تحديث كلمات المرور بنجاح وحفظها', style: TextStyle(fontFamily: 'Cairo')),
                    backgroundColor: Color(AppColors.success),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: const Color(AppColors.primaryGreen)),
              child: const Text('حفظ التعديل', style: TextStyle(fontFamily: 'Cairo', color: Colors.white)),
            ),
          ],
        );
      },
    );
  }
}
