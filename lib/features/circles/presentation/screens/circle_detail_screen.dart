import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_routes.dart';
import '../../../../core/services/app_data_store.dart';
import '../../../../data/models/circle_model.dart';
import '../widgets/circle_barcode_dialog.dart';

class CircleDetailScreen extends ConsumerWidget {
  final String circleId;

  const CircleDetailScreen({super.key, required this.circleId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(appDataStoreProvider);
    final store = AppDataStore.instance;
    final circle = store.circles.firstWhere(
      (c) => c.id == circleId,
      orElse: () => store.circles.first,
    );

    final circleStudents = store.getStudentsByCircle(circle.id);

    return Scaffold(
      appBar: AppBar(
        title: Text(circle.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.qr_code_2),
            tooltip: 'إنشاء وعرض باركود الحلقة',
            onPressed: () => CircleBarcodeDialog.show(context, circle),
          ),
          IconButton(
            icon: const Icon(Icons.share_outlined),
            tooltip: 'مشاركة بيانات الدخول مع المدرس',
            onPressed: () {
              final text = '''
حلقات مسجد الريان
السلام عليكم ورحمة الله، أستاذنا الفاضل: ${circle.teacherName}
بيانات اعتماد حلقتكم (${circle.name}):
- كود الحلقة: ${circle.circleCode}
- كلمة مرور الدخول: ${circle.accessPassword}
- أيام الحضور: ${circle.studyDays.join(' - ')}
''';
              Clipboard.setData(ClipboardData(text: text));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('تم نسخ بيانات الدخول للحافظة بنجاح', style: TextStyle(fontFamily: 'Cairo'))),
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
            // بطاقة بيانات الأمان للحلقة
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(AppColors.primaryGreen).withAlpha(15),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(AppColors.primaryGreenSoft)),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      const Icon(Icons.vpn_key, color: Color(AppColors.primaryGreenDark)),
                      const SizedBox(width: 8),
                      const Text(
                        'بيانات دخول المدرس للحلقة',
                        style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.copy, size: 20, color: Color(AppColors.primaryGreen)),
                        onPressed: () {
                          Clipboard.setData(ClipboardData(text: 'كود: ${circle.circleCode}\nكلمة المرور: ${circle.accessPassword}'));
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('تم نسخ الكود وكلمة المرور', style: TextStyle(fontFamily: 'Cairo'))),
                          );
                        },
                      ),
                    ],
                  ),
                  const Divider(height: 16),
                  _buildDetailRow('كود الحلقة الفريد', circle.circleCode, isBold: true),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('كلمة مرور الحلقة والمدرس', style: TextStyle(fontFamily: 'Cairo', fontSize: 12, color: Colors.black54)),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            circle.accessPassword,
                            style: const TextStyle(
                              fontFamily: 'Courier',
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Color(AppColors.primaryGreenDark),
                              letterSpacing: 1.2,
                            ),
                          ),
                          const SizedBox(width: 4),
                          IconButton(
                            icon: const Icon(Icons.edit, size: 16, color: Color(AppColors.goldDark)),
                            tooltip: 'تعديل كلمة المرور وفق قواعد الأمان',
                            onPressed: () => _showEditCirclePasswordDialog(context, circle),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  _buildDetailRow('المدرس المعين', circle.teacherName),
                  const SizedBox(height: 6),
                  _buildDetailRow('المستوى الدراسي', circle.level),
                  const SizedBox(height: 6),
                  _buildDetailRow('أيام وانعقاد الحلقة', circle.studyDays.join(' - ')),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // أزرار العمليات السريعة
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => context.push(AppRoutes.attendance),
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(AppColors.primaryGreen), foregroundColor: Colors.white),
                    icon: const Icon(Icons.edit_note, size: 18),
                    label: const Text('كشف الحضور', style: TextStyle(fontFamily: 'Cairo', fontSize: 13)),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => context.push('${AppRoutes.addStudent}?circleId=${circle.id}', extra: circle.id),
                    icon: const Icon(Icons.person_add, size: 18),
                    label: const Text('إضافة طالب', style: TextStyle(fontFamily: 'Cairo', fontSize: 13)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => CircleBarcodeDialog.show(context, circle),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(AppColors.goldAccent),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                icon: const Icon(Icons.qr_code_2, size: 22),
                label: const Text(
                  'إنشاء وعرض باركود الحلقة (QR Code)',
                  style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold, fontSize: 14),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // قائمة طلاب الحلقة
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'طلاب الحلقة (${circleStudents.length})',
                  style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold, fontSize: 15),
                ),
              ],
            ),
            const SizedBox(height: 10),

            if (circleStudents.isEmpty)
              Container(
                padding: const EdgeInsets.all(24),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: const Color(AppColors.grey100),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text('لا يوجد طلاب مسجلون في هذه الحلقة حتى الآن', style: TextStyle(fontFamily: 'Cairo', color: Colors.grey)),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: circleStudents.length,
                itemBuilder: (context, index) {
                  final std = circleStudents[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: const Color(AppColors.primaryGreenSoft).withAlpha(60),
                        child: Text(std.fullName[0], style: const TextStyle(fontFamily: 'Cairo', color: Color(AppColors.primaryGreenDark))),
                      ),
                      title: Text(std.fullName, style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold, fontSize: 13)),
                      subtitle: Text('${std.studentNumber} • ولي الأمر: ${std.guardianName}', style: const TextStyle(fontFamily: 'Cairo', fontSize: 11)),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                      onTap: () => context.push('/students/${std.id}'),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isBold = false, Color? color}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontFamily: 'Cairo', fontSize: 12, color: Colors.black54)),
        Text(
          value,
          style: TextStyle(
            fontFamily: 'Cairo',
            fontSize: 13,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
            color: color ?? Colors.black87,
          ),
        ),
      ],
    );
  }

  void _showEditCirclePasswordDialog(BuildContext context, CircleModel circle) {
    final controller = TextEditingController(text: circle.accessPassword);
    bool obscure = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (dialogCtx, setModalState) {
            final pass = controller.text;
            final hasMin = pass.length >= 6;
            final hasLetter = RegExp(r'[a-zA-Z\u0621-\u064A]').hasMatch(pass);
            final hasDigit = RegExp(r'[0-9]').hasMatch(pass);

            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(dialogCtx).viewInsets.bottom + 20,
                left: 20,
                right: 20,
                top: 20,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        const Icon(Icons.security, color: Color(AppColors.primaryGreen)),
                        const SizedBox(width: 8),
                        Text(
                          'تعديل كلمة مرور حلقة: ${circle.name}',
                          style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        const Text('كلمة المرور الجديدة:', style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold, fontSize: 12)),
                        const Spacer(),
                        TextButton.icon(
                          onPressed: () {
                            final random = Random();
                            const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
                            final gen = 'RYN-${List.generate(5, (_) => chars[random.nextInt(chars.length)]).join()}';
                            controller.text = gen;
                            setModalState(() {});
                          },
                          icon: const Icon(Icons.auto_awesome, size: 14, color: Color(AppColors.goldDark)),
                          label: const Text('توليد تلقائي', style: TextStyle(fontFamily: 'Cairo', fontSize: 11, color: Color(AppColors.goldDark))),
                        ),
                      ],
                    ),
                    TextField(
                      controller: controller,
                      obscureText: obscure,
                      onChanged: (_) => setModalState(() {}),
                      style: const TextStyle(fontFamily: 'Courier', fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1.5),
                      decoration: InputDecoration(
                        border: const OutlineInputBorder(),
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          icon: Icon(obscure ? Icons.visibility_off : Icons.visibility),
                          onPressed: () => setModalState(() => obscure = !obscure),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Icon(hasMin && hasLetter && hasDigit ? Icons.check_circle : Icons.info, size: 14, color: hasMin && hasLetter && hasDigit ? const Color(AppColors.primaryGreen) : Colors.orange),
                        const SizedBox(width: 6),
                        const Text(
                          'قواعد الأمان: لا تقل عن 6 خانات، وتحتوي حروفاً وأرقاماً.',
                          style: TextStyle(fontFamily: 'Cairo', fontSize: 11, color: Colors.black54),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(AppColors.primaryGreen),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        icon: const Icon(Icons.check),
                        label: const Text('حفظ وتحديث كلمة المرور', style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold)),
                        onPressed: () {
                          final newP = controller.text.trim();
                          if (newP.length < 6) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('يجب ألا تقل كلمة المرور عن 6 خانات', style: TextStyle(fontFamily: 'Cairo'))),
                            );
                            return;
                          }
                          AppDataStore.instance.updateCirclePassword(circle.id, newP);
                          Navigator.pop(ctx);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('تم تحديث كلمة المرور للحلقة والمدرس بنجاح', style: TextStyle(fontFamily: 'Cairo'))),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
