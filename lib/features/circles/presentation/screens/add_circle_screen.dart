import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/app_routes.dart';
import '../../../../core/constants/app_enums.dart';
import '../../../../core/services/app_data_store.dart';
import '../../../../data/models/circle_model.dart';
import '../../../../data/models/user_model.dart';

class AddCircleScreen extends ConsumerStatefulWidget {
  const AddCircleScreen({super.key});

  @override
  ConsumerState<AddCircleScreen> createState() => _AddCircleScreenState();
}

class _AddCircleScreenState extends ConsumerState<AddCircleScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _codeController = TextEditingController();
  final _passwordController = TextEditingController();
  final _teacherNameController = TextEditingController();
  final _teacherPhoneController = TextEditingController();
  final _locationController = TextEditingController(text: 'مسجد الريان - تريم دمون');
  final _notesController = TextEditingController();

  String _selectedLevel = 'المستوى الأول (تلقين وقصار السور)';
  final List<String> _selectedDays = ['السبت', 'الاثنين', 'الأربعاء'];

  bool _obscurePassword = false;

  @override
  void initState() {
    super.initState();
    _generateCircleCredentials();
  }

  void _generateCircleCredentials() {
    final random = Random();
    final randomNum = 100 + random.nextInt(900);
    _codeController.text = 'RYN-$randomNum';

    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    final pass = List.generate(6, (index) => chars[random.nextInt(chars.length)]).join();
    _passwordController.text = pass;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _codeController.dispose();
    _passwordController.dispose();
    _teacherNameController.dispose();
    _teacherPhoneController.dispose();
    _locationController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final circleName = _nameController.text.trim();
      final circleCode = _codeController.text.trim();
      final circlePass = _passwordController.text.trim();
      final teacherName = _teacherNameController.text.trim();
      final teacherPhone = _teacherPhoneController.text.trim();

      final circleId = 'crc_${DateTime.now().millisecondsSinceEpoch}';
      final teacherId = 'tch_${DateTime.now().millisecondsSinceEpoch}';

      // حفظ الحلقة في مخزن البيانات الفعلي
      final newCircle = CircleModel(
        id: circleId,
        circleCode: circleCode,
        accessPassword: circlePass,
        name: circleName,
        teacherId: teacherId,
        teacherName: teacherName,
        level: _selectedLevel,
        stage: 'ابتدائي / متوسط / ثانوي',
        studyDays: List<String>.from(_selectedDays),
        startTime: '4:30 م',
        endTime: '6:00 م',
        studentCount: 0,
        location: _locationController.text.trim(),
        notes: _notesController.text.trim(),
        status: CircleStatus.active,
        createdAt: DateTime.now(),
      );

      AppDataStore.instance.addCircle(newCircle);

      // تسجيل المدرس كمستخدم جديد في المنظومة تلقائياً
      final teacherUser = UserModel(
        id: teacherId,
        name: teacherName,
        email: '${circleCode.toLowerCase()}@alrayyan.com',
        phone: teacherPhone,
        role: UserRole.teacher,
        password: circlePass,
        assignedCircleIds: [circleId],
        createdAt: DateTime.now(),
      );
      AppDataStore.instance.addUser(teacherUser);

      _showSuccessCredentialsDialog();
    }
  }

  void _showSuccessCredentialsDialog() {
    final circleName = _nameController.text.trim();
    final circleCode = _codeController.text.trim();
    final circlePass = _passwordController.text.trim();
    final teacherName = _teacherNameController.text.trim();
    final teacherPhone = _teacherPhoneController.text.trim();

    final messageText = '''
السلام عليكم ورحمة الله وبركاته..
أستاذنا الفاضل: $teacherName
تم اعتماد وتعيينكم لحلقة في ${AppStrings.institutionName}

📌 اسم الحلقة: $circleName
🔑 كود الحلقة: $circleCode
🔒 كلمة مرور الحلقة: $circlePass
📖 المستوى: $_selectedLevel
📅 أيام الدوام: ${_selectedDays.join(' - ')}

يمكنكم تسجيل الدخول إلى تطبيق حلقات مسجد الريان باستخدام كود الحلقة وكلمة المرور أعلاه لمتابعة الحضور والحفظ والتسميع. بارك الله في جهودكم.
''';

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(AppColors.primaryGreen).withAlpha(30),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_circle, color: Color(AppColors.primaryGreen), size: 28),
            ),
            const SizedBox(width: 10),
            const Expanded(
              child: Text(
                'تم إنشاء الحلقة بنجاح! 🎉',
                style: TextStyle(fontFamily: 'Cairo', fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'بيانات الاعتماد الأمنية لتسليمها للمدرس:',
                style: TextStyle(fontFamily: 'Cairo', fontSize: 13, color: Colors.grey),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(AppColors.grey100),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(AppColors.grey300)),
                ),
                child: Column(
                  children: [
                    _buildCredentialRow('اسم الحلقة', circleName),
                    const Divider(height: 14),
                    _buildCredentialRow('أستاذ الحلقة', teacherName, isBold: true),
                    const Divider(height: 14),
                    _buildCredentialRow('كود الدخول', circleCode, isBold: true, color: const Color(AppColors.primaryGreenDark)),
                    const Divider(height: 14),
                    _buildCredentialRow('كلمة المرور', circlePass, isBold: true, color: const Color(AppColors.goldDark)),
                    if (teacherPhone.isNotEmpty) ...[
                      const Divider(height: 14),
                      _buildCredentialRow('هاتف المدرس', teacherPhone),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // زر إرسال مباشر عبر واتساب
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    final cleanPhone = teacherPhone.replaceAll(RegExp(r'[^0-9]'), '');
                    final encodedMsg = Uri.encodeComponent(messageText);
                    final url = cleanPhone.isNotEmpty
                        ? 'https://wa.me/967$cleanPhone?text=$encodedMsg'
                        : 'https://wa.me/?text=$encodedMsg';
                    final uri = Uri.parse(url);
                    if (await canLaunchUrl(uri)) {
                      await launchUrl(uri, mode: LaunchMode.externalApplication);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(AppColors.success),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  icon: const Icon(Icons.send_rounded, size: 18),
                  label: const Text(
                    'إرسال كود الدخول للمدرس عبر واتساب 📲',
                    style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          OutlinedButton.icon(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: messageText));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('تم نسخ بيانات الدخول كاملة للحافظة جاهزة للمشاركة', style: TextStyle(fontFamily: 'Cairo')),
                  backgroundColor: Color(AppColors.primaryGreen),
                ),
              );
            },
            icon: const Icon(Icons.copy, size: 16),
            label: const Text('نسخ البيانات', style: TextStyle(fontFamily: 'Cairo', fontSize: 12)),
          ),
          OutlinedButton.icon(
            onPressed: () {
              Navigator.pop(ctx);
              context.go(AppRoutes.addStudent);
            },
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Color(AppColors.goldDark)),
              foregroundColor: const Color(AppColors.goldDark),
            ),
            icon: const Icon(Icons.person_add, size: 16),
            label: const Text('إضافة طالب للحلقة الآن', style: TextStyle(fontFamily: 'Cairo', fontSize: 12, fontWeight: FontWeight.bold)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.go(AppRoutes.circles);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(AppColors.primaryGreen),
              foregroundColor: Colors.white,
            ),
            child: const Text('عرض الحلقات والباركود', style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildCredentialRow(String label, String value, {bool isBold = false, Color? color}) {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('إنشاء حلقة جديدة وتعيين المدرس'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // بطاقة تعريفية ترحيبية
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(AppColors.primaryGreenSoft).withAlpha(50),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(AppColors.primaryGreenSoft)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.mosque, color: Color(AppColors.primaryGreenDark), size: 28),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'يقوم المدير العام بتحديد اسم الحلقة وكتابة اسم المدرس، ويتم توليد كود دخول سري لإرساله للمدرس لفتح لوحة تحكمه الخاصة.',
                        style: TextStyle(fontFamily: 'Cairo', fontSize: 12, color: Color(AppColors.primaryGreenDark)),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // اسم الحلقة
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'اسم الحلقة القرآنية *',
                  hintText: 'مثال: حلقة الإمام نافع (بعد الفجر)',
                  prefixIcon: Icon(Icons.bookmark_border),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) return 'يرجى إدخال اسم الحلقة';
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // اسم المدرس (يكتبه المدير بحرية تامة)
              TextFormField(
                controller: _teacherNameController,
                decoration: const InputDecoration(
                  labelText: 'اسم أستاذ / مدرس الحلقة *',
                  hintText: 'اكتب اسم المدرس بالكامل (مثال: أ. صالح عمر باحميد)',
                  prefixIcon: Icon(Icons.person_pin),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) return 'يرجى كتابة اسم المدرس المسؤول عن الحلقة';
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // رقم هاتف المدرس
              TextFormField(
                controller: _teacherPhoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'رقم هاتف / واتساب المدرس (اختياري)',
                  hintText: 'مثال: 771234567 (لإرسال كود الدخول له مباشرة)',
                  prefixIcon: Icon(Icons.phone_android),
                ),
              ),
              const SizedBox(height: 16),

              // كود وكلمة مرور الحلقة
              Row(
                children: [
                  Expanded(
                    flex: 5,
                    child: TextFormField(
                      controller: _codeController,
                      decoration: const InputDecoration(
                        labelText: 'كود / رمز الحلقة (يكتبه المدير أو يولد آلياً) *',
                        hintText: 'مثال: RYN-101 أو 101',
                        prefixIcon: Icon(Icons.tag),
                      ),
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) return 'يرجى كتابة رمز الحلقة';
                        final code = val.trim().toUpperCase();
                        final exists = AppDataStore.instance.circles.any((c) => c.circleCode.trim().toUpperCase() == code);
                        if (exists) return 'هذا الكود مستخدم لحلقة أخرى، اختر كوداً آخر';
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 5,
                    child: TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      decoration: InputDecoration(
                        labelText: 'كلمة مرور الحلقة *',
                        hintText: 'أدخل كلمة المرور',
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          icon: Icon(_obscurePassword ? Icons.visibility : Icons.visibility_off, size: 20),
                          onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                        ),
                      ),
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) return 'يرجى تعيين كلمة مرور';
                        if (val.length < 4) return 'كلمة المرور 4 خانات على الأقل';
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'الرمز وكلمة المرور يتم تحديدها بالكامل من خلال المدير العام.',
                    style: TextStyle(fontSize: 11, fontFamily: 'Cairo', color: Colors.grey.shade600),
                  ),
                  TextButton.icon(
                    onPressed: () => setState(_generateCircleCredentials),
                    icon: const Icon(Icons.auto_awesome, size: 16, color: Color(AppColors.goldDark)),
                    label: const Text('توليد كود تلقائي', style: TextStyle(fontSize: 12, fontFamily: 'Cairo', color: Color(AppColors.goldDark), fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // المستوى الدراسي
              DropdownButtonFormField<String>(
                initialValue: _selectedLevel,
                decoration: const InputDecoration(
                  labelText: 'المستوى الدراسي للحلقة',
                  prefixIcon: Icon(Icons.school),
                ),
                items: const [
                  DropdownMenuItem(value: 'المستوى الأول (تلقين وقصار السور)', child: Text('المستوى الأول (تلقين وقصار السور)', style: TextStyle(fontFamily: 'Cairo'))),
                  DropdownMenuItem(value: 'المستوى الثاني (أجزاء عم وتبارك)', child: Text('المستوى الثاني (أجزاء عم وتبارك)', style: TextStyle(fontFamily: 'Cairo'))),
                  DropdownMenuItem(value: 'المستوى الثالث (حفظ 5 أجزاء فأعلى)', child: Text('المستوى الثالث (حفظ 5 أجزاء فأعلى)', style: TextStyle(fontFamily: 'Cairo'))),
                  DropdownMenuItem(value: 'حلقة الإتقان والإجازة بالسند', child: Text('حلقة الإتقان والإجازة بالسند', style: TextStyle(fontFamily: 'Cairo'))),
                ],
                onChanged: (val) => setState(() => _selectedLevel = val ?? _selectedLevel),
              ),
              const SizedBox(height: 16),

              // أيام الدراسة
              const Text(
                'أيام الدراسة الأسبوعية',
                style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold, fontSize: 13),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: ['السبت', 'الأحد', 'الاثنين', 'الثلاثاء', 'الأربعاء', 'الخميس'].map((day) {
                  final isSelected = _selectedDays.contains(day);
                  return FilterChip(
                    label: Text(day, style: const TextStyle(fontFamily: 'Cairo', fontSize: 12)),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          _selectedDays.add(day);
                        } else {
                          if (_selectedDays.length > 1) {
                            _selectedDays.remove(day);
                          }
                        }
                      });
                    },
                    selectedColor: const Color(AppColors.primaryGreenSoft).withAlpha(80),
                    checkmarkColor: const Color(AppColors.primaryGreenDark),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),

              // موقع الحلقة وملاحظات
              TextFormField(
                controller: _locationController,
                decoration: const InputDecoration(
                  labelText: 'موقع انعقاد الحلقة داخل المسجد',
                  prefixIcon: Icon(Icons.place),
                ),
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(
                  labelText: 'ملاحظات إدارية أو تعليمية إضافية',
                  prefixIcon: Icon(Icons.note),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 28),

              // زر الحفظ
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(AppColors.primaryGreen),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  icon: const Icon(Icons.check_circle_outline, size: 20),
                  label: const Text(
                    'اعتماد وإنشاء الحلقة واستخراج بيانات الدخول للمدرس',
                    style: TextStyle(fontFamily: 'Cairo', fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
