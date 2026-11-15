import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/app_routes.dart';
import '../../../../core/constants/app_enums.dart';
import '../../../../core/services/app_data_store.dart';
import '../../../../data/models/user_model.dart';
import '../../../../data/models/student_model.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();

  // بيانات المدير العام الرسمية
  static const String officialAdminEmail = 'hymdyhmbarksyd@gmail.com';
  static const String officialAdminPassword = '77815779805';

  // حقول الدخول بحساب المعلم
  final _teacherEmailController = TextEditingController(text: 'teacher@alrayyan.com');
  final _teacherPasswordController = TextEditingController(text: '123456');

  // حقول الدخول بكود الحلقة للمعلم
  final _circleCodeController = TextEditingController(text: 'RYN-101');
  final _circlePassController = TextEditingController(text: '4K8B9Z');

  // حقول الدخول لولي الأمر (برقم الجوال)
  final _guardianPhoneController = TextEditingController(text: '770123456');
  final _guardianPasswordController = TextEditingController(text: '123456');

  // حقول الدخول للطالب (برقم الطالب أو اسمه)
  final _studentNumberController = TextEditingController(text: '2024001');
  final _studentPasswordController = TextEditingController(text: '123456');

  bool _obscurePassword = true;
  bool _isLoading = false;
  int _logoTapCount = 0; // نقرات سرية للانتقال لبوابة الإدارة المنفصلة

  // 0 = المعلم، 1 = ولي الأمر، 2 = الطالب
  int _userType = 0;
  // 0 = بالبريد/كلمة المرور، 1 = بكود الحلقة (خاص بالمعلم)
  int _teacherLoginMode = 0;

  @override
  void dispose() {
    _teacherEmailController.dispose();
    _teacherPasswordController.dispose();
    _circleCodeController.dispose();
    _circlePassController.dispose();
    _guardianPhoneController.dispose();
    _guardianPasswordController.dispose();
    _studentNumberController.dispose();
    _studentPasswordController.dispose();
    super.dispose();
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(fontFamily: 'Cairo')),
        backgroundColor: const Color(AppColors.error),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _handleUserLogin() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 300));

    final store = AppDataStore.instance;
    if (!mounted) return;

    if (_userType == 0) {
      // ===== المعلم =====
      if (_teacherLoginMode == 0) {
        final email = _teacherEmailController.text.trim().toLowerCase();
        final pass = _teacherPasswordController.text.trim();

        if (email.isEmpty || pass.isEmpty) {
          setState(() => _isLoading = false);
          _showError('يرجى إدخال البريد الإلكتروني أو رقم الهاتف وكلمة المرور');
          return;
        }

        // تحويل ذكي: إذا أدخل المدير بياناته هنا، يسجل دخوله كمدير عام
        if (email == officialAdminEmail.toLowerCase() && pass == officialAdminPassword) {
          _loginAsAdmin(store);
          return;
        }

        // فحص صارم: البحث في المستخدمين المسجلين كمعلمين فقط
        final teacher = store.users.cast<UserModel?>().firstWhere(
          (u) =>
              u != null &&
              u.role == UserRole.teacher &&
              (u.email.toLowerCase() == email || (u.phone != null && u.phone!.trim() == email)),
          orElse: () => null,
        );

        if (teacher == null) {
          setState(() => _isLoading = false);
          _showError('هذا الحساب غير مسجل كمعلم في النظام. يرجى من إدارة المسجد إضافتك أولاً.');
          return;
        }

        if ((teacher.password ?? '123456') != pass) {
          setState(() => _isLoading = false);
          _showError('كلمة المرور غير صحيحة. يرجى مراجعة إدارة المسجد.');
          return;
        }

        // دخول المعلم بحسابه المعتمد
        store.currentUser = teacher;
        setState(() => _isLoading = false);
        context.go(AppRoutes.dashboard);
      } else {
        // دخول المعلم بكود الحلقة الموزع له من المدير
        final code = _circleCodeController.text.trim().toUpperCase();
        final pass = _circlePassController.text.trim();

        if (code.isEmpty || pass.isEmpty) {
          setState(() => _isLoading = false);
          _showError('يرجى إدخال كود الحلقة وكلمة المرور');
          return;
        }

        final circle = store.findCircleByCode(code);
        if (circle == null) {
          setState(() => _isLoading = false);
          _showError('كود الحلقة ($code) غير مسجل في النظام. يرجى مراجعة إدارة المسجد.');
          return;
        }

        if (circle.accessPassword != pass) {
          setState(() => _isLoading = false);
          _showError('كلمة مرور الحلقة غير صحيحة. يرجى مراجعة إدارة المسجد.');
          return;
        }

        store.currentUser = UserModel(
          id: circle.teacherId.isNotEmpty ? circle.teacherId : 'tch_${circle.id}',
          name: circle.teacherName.isNotEmpty ? circle.teacherName : 'مدرس ${circle.name}',
          email: '${circle.circleCode.toLowerCase()}@alrayyan.com',
          role: UserRole.teacher,
          assignedCircleIds: [circle.id],
          createdAt: DateTime.now(),
        );
        setState(() => _isLoading = false);
        context.go(AppRoutes.dashboard);
      }
    } else if (_userType == 1) {
      // ===== ولي الأمر: تسجيل الدخول برقم الجوال وكلمة المرور مع فحص أمني حقيقي =====
      final phone = _guardianPhoneController.text.trim();
      final pass = _guardianPasswordController.text.trim();

      if (phone.isEmpty || pass.isEmpty) {
        setState(() => _isLoading = false);
        _showError('يرجى إدخال رقم جوال ولي الأمر وكلمة المرور');
        return;
      }

      // البحث عن الطلاب المرتبطين برقم جوال ولي الأمر
      final target = phone.replaceAll(' ', '');
      final matchingStudents = store.students.where((s) {
        final p1 = s.guardianPhone.trim().replaceAll(' ', '');
        final p2 = s.guardianPhone2?.trim().replaceAll(' ', '') ?? '';
        return p1 == target || (p2.isNotEmpty && p2 == target);
      }).toList();

      if (matchingStudents.isEmpty) {
        setState(() => _isLoading = false);
        _showError('لم يتم العثور على أي طالب مسجل برقم الجوال ($phone). يرجى مراجعة إدارة المسجد.');
        return;
      }

      // مطابقة كلمة المرور المعتمدة
      final isPasswordCorrect = matchingStudents.any((s) => (s.guardianPassword ?? '123456') == pass);
      if (!isPasswordCorrect) {
        setState(() => _isLoading = false);
        _showError('كلمة المرور غير صحيحة لولي الأمر. يرجى التأكد أو مراجعة إدارة المسجد.');
        return;
      }

      final guardianName = matchingStudents.first.guardianName;
      store.currentUser = UserModel(
        id: 'parent_${matchingStudents.first.id}',
        name: guardianName.isNotEmpty ? guardianName : 'ولي الأمر',
        email: 'parent@alrayyan.com',
        phone: phone,
        role: UserRole.parent,
        createdAt: DateTime.now(),
      );

      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'أهلاً بك يا $guardianName • متابعة: ${matchingStudents.map((s) => s.fullName).join("، ")}',
            style: const TextStyle(fontFamily: 'Cairo'),
          ),
          backgroundColor: const Color(AppColors.primaryGreen),
        ),
      );
      context.go(AppRoutes.dashboard);
    } else if (_userType == 2) {
      // ===== الطالب: تسجيل الدخول برقم الطالب أو اسمه مع كلمة المرور =====
      final input = _studentNumberController.text.trim().toLowerCase();
      final pass = _studentPasswordController.text.trim();

      if (input.isEmpty || pass.isEmpty) {
        setState(() => _isLoading = false);
        _showError('يرجى إدخال الرقم الأكاديمي أو اسم الطالب وكلمة المرور');
        return;
      }

      final matchingStudent = store.students.cast<StudentModel?>().firstWhere(
        (s) {
          if (s == null) return false;
          final sNum = s.studentNumber.trim().toLowerCase();
          final sName = s.fullName.trim().toLowerCase();
          return sNum == input || sName == input || sName.contains(input);
        },
        orElse: () => null,
      );

      if (matchingStudent == null) {
        setState(() => _isLoading = false);
        _showError('الرقم الأكاديمي أو اسم الطالب ($input) غير مسجل في النظام. يرجى مراجعة إدارة المسجد.');
        return;
      }

      // مطابقة كلمة المرور للطالب
      if ((matchingStudent.password ?? '123456') != pass) {
        setState(() => _isLoading = false);
        _showError('كلمة المرور غير صحيحة للطالب. يرجى مراجعة المعلم أو إدارة المسجد.');
        return;
      }

      final studentName = matchingStudent.fullName;
      store.currentUser = UserModel(
        id: matchingStudent.id,
        name: studentName,
        email: 'student@alrayyan.com',
        role: UserRole.student,
        assignedCircleIds: [matchingStudent.circleId],
        createdAt: DateTime.now(),
      );

      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'مرحباً بك يا $studentName في حلقة ${matchingStudent.circleName}',
            style: const TextStyle(fontFamily: 'Cairo'),
          ),
          backgroundColor: const Color(AppColors.primaryGreen),
        ),
      );
      context.go(AppRoutes.dashboard);
    }
  }

  void _loginAsAdmin(AppDataStore store) {
    store.currentUser = UserModel(
      id: 'admin_official',
      name: 'المدير العام',
      email: officialAdminEmail,
      role: UserRole.admin,
      phone: officialAdminPassword,
      createdAt: DateTime.now(),
      permissions: {
        'canAddStudent': true,
        'canManageCircles': true,
        'canViewFees': true,
        'canApproveReports': true,
      },
    );
    setState(() => _isLoading = false);
    context.go(AppRoutes.dashboard);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDesktop = size.width > 700;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F3ED),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: isDesktop ? 480 : double.infinity),
            child: Card(
              elevation: 6,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              child: Padding(
                padding: const EdgeInsets.all(28.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // شعار المسجد (مع نقرة سرية 4 مرات لفتح شاشة المدير الخاصة)
                      GestureDetector(
                        onTap: () {
                          _logoTapCount++;
                          if (_logoTapCount >= 4) {
                            _logoTapCount = 0;
                            context.push(AppRoutes.adminLogin);
                          }
                        },
                        child: Container(
                          width: 85,
                          height: 85,
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: const Color(AppColors.goldAccent), width: 2),
                          ),
                          child: ClipOval(
                            child: Image.asset(
                              'assets/icons/app_icon.png',
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Image.asset(
                                'assets/images/logo.jpg',
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => const Icon(
                                  Icons.mosque,
                                  size: 45,
                                  color: Color(AppColors.primaryGreen),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      const Text(
                        AppStrings.appName,
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(AppColors.primaryGreen),
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'منصة إدارة الحلقات القرآنية والتعليمية',
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 22),

                      // تبويبات المستخدمين العامة فقط (المعلم، ولي الأمر، الطالب) - لا يظهر المدير إطلاقاً
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Row(
                          children: [
                            _buildRoleTab(0, 'المعلم', Icons.school),
                            _buildRoleTab(1, 'ولي الأمر', Icons.family_restroom),
                            _buildRoleTab(2, 'الطالب', Icons.person),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // محتوى النموذج حسب الدور المختار
                      if (_userType == 0) ...[
                        // خيار تسجيل المعلم: بالحساب أو بكود الحلقة
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ChoiceChip(
                              label: const Text('دخول بالحساب', style: TextStyle(fontFamily: 'Cairo', fontSize: 11)),
                              selected: _teacherLoginMode == 0,
                              selectedColor: const Color(AppColors.primaryGreen),
                              labelStyle: TextStyle(
                                color: _teacherLoginMode == 0 ? Colors.white : Colors.black87,
                                fontWeight: _teacherLoginMode == 0 ? FontWeight.bold : FontWeight.normal,
                              ),
                              onSelected: (val) {
                                if (val) setState(() => _teacherLoginMode = 0);
                              },
                            ),
                            const SizedBox(width: 8),
                            ChoiceChip(
                              label: const Text('كود الحلقة', style: TextStyle(fontFamily: 'Cairo', fontSize: 11)),
                              selected: _teacherLoginMode == 1,
                              selectedColor: const Color(AppColors.goldAccent),
                              labelStyle: TextStyle(
                                color: _teacherLoginMode == 1 ? Colors.white : Colors.black87,
                                fontWeight: _teacherLoginMode == 1 ? FontWeight.bold : FontWeight.normal,
                              ),
                              onSelected: (val) {
                                if (val) setState(() => _teacherLoginMode = 1);
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        if (_teacherLoginMode == 0) ...[
                          TextFormField(
                            controller: _teacherEmailController,
                            keyboardType: TextInputType.emailAddress,
                            textDirection: TextDirection.ltr,
                            decoration: const InputDecoration(
                              labelText: 'البريد الإلكتروني للمعلم',
                              prefixIcon: Icon(Icons.email_outlined),
                            ),
                          ),
                          const SizedBox(height: 14),
                          TextFormField(
                            controller: _teacherPasswordController,
                            textDirection: TextDirection.ltr,
                            decoration: InputDecoration(
                              labelText: 'كلمة المرور',
                              prefixIcon: const Icon(Icons.lock_outline),
                              suffixIcon: IconButton(
                                icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
                                onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                              ),
                            ),
                            obscureText: _obscurePassword,
                          ),
                        ] else ...[
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: const Color(AppColors.goldAccent).withAlpha(20),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Row(
                              children: [
                                Icon(Icons.qr_code, color: Color(AppColors.goldAccent), size: 18),
                                SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'أدخل كود الحلقة وكلمة المرور المسلمة لك من إدارة المسجد',
                                    style: TextStyle(fontFamily: 'Cairo', fontSize: 11),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _circleCodeController,
                            decoration: const InputDecoration(
                              labelText: 'كود الحلقة (مثال: RYN-101)',
                              prefixIcon: Icon(Icons.tag),
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _circlePassController,
                            decoration: const InputDecoration(
                              labelText: 'كلمة مرور الحلقة',
                              prefixIcon: Icon(Icons.key),
                            ),
                            obscureText: _obscurePassword,
                          ),
                        ],
                      ] else if (_userType == 1) ...[
                        // واجهة ولي الأمر: الدخول برقم الجوال
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(AppColors.goldAccent).withAlpha(20),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.family_restroom, color: Color(AppColors.goldAccent), size: 30),
                              SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'بوابة متابعة الأبناء: أدخل رقم جوالك المسجل في بيانات الطلاب للاطلاع الفوري على سجلاتهم',
                                  style: TextStyle(fontFamily: 'Cairo', fontSize: 12, height: 1.4),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _guardianPhoneController,
                          keyboardType: TextInputType.phone,
                          decoration: const InputDecoration(
                            labelText: 'رقم جوال ولي الأمر (مثال: 778157798)',
                            prefixIcon: Icon(Icons.phone_outlined),
                            hintText: 'أدخل رقم الهاتف المسجل في ملف الطالب',
                          ),
                          style: const TextStyle(fontFamily: 'Cairo'),
                        ),
                        const SizedBox(height: 14),
                        TextFormField(
                          controller: _guardianPasswordController,
                          obscureText: _obscurePassword,
                          decoration: InputDecoration(
                            labelText: 'كلمة مرور ولي الأمر',
                            prefixIcon: const Icon(Icons.lock_outline),
                            suffixIcon: IconButton(
                              icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
                              onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                            ),
                          ),
                          style: const TextStyle(fontFamily: 'Cairo'),
                        ),
                      ] else if (_userType == 2) ...[
                        // واجهة الطالب: الدخول برقم الطالب أو اسمه
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(AppColors.primaryGreen).withAlpha(15),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.school, color: Color(AppColors.primaryGreen), size: 30),
                              SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'بوابة الطالب: أدخل رقمك الدراسي أو اسمك للدخول إلى سجلك القرآني ومتابعة أوسمتك',
                                  style: TextStyle(fontFamily: 'Cairo', fontSize: 12, height: 1.4),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _studentNumberController,
                          decoration: const InputDecoration(
                            labelText: 'رقم الطالب أو اسمه (مثال: STU-2026-001)',
                            prefixIcon: Icon(Icons.badge_outlined),
                            hintText: 'أدخل رقمك أو اسمك للبحث في المنظومة',
                          ),
                          style: const TextStyle(fontFamily: 'Cairo'),
                        ),
                        const SizedBox(height: 14),
                        TextFormField(
                          controller: _studentPasswordController,
                          obscureText: _obscurePassword,
                          decoration: InputDecoration(
                            labelText: 'كلمة مرور الطالب',
                            prefixIcon: const Icon(Icons.lock_outline),
                            suffixIcon: IconButton(
                              icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
                              onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                            ),
                          ),
                          style: const TextStyle(fontFamily: 'Cairo'),
                        ),
                      ],

                      const SizedBox(height: 24),

                      // زر الدخول الرئيسي
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _handleUserLogin,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(AppColors.primaryGreen),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                                )
                              : Text(
                                  _userType == 0
                                      ? 'تسجيل دخول المعلم'
                                      : _userType == 1
                                          ? 'دخول ولي الأمر'
                                          : 'دخول الطالب',
                                  style: const TextStyle(
                                    fontFamily: 'Cairo',
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 18),

                      // زر تحميل تطبيق الأندرويد للجوال مباشرة
                      OutlinedButton.icon(
                        onPressed: () async {
                          final uri = Uri.parse('app-release.apk');
                          if (await canLaunchUrl(uri)) {
                            await launchUrl(uri, mode: LaunchMode.externalApplication);
                          }
                        },
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(AppColors.goldAccent), width: 1.5),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                        ),
                        icon: const Icon(Icons.android, color: Color(AppColors.primaryGreenDark)),
                        label: const Text(
                          '📲 تنزيل تطبيق الأندرويد للجوال (APK)',
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                            color: Color(AppColors.primaryGreenDark),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRoleTab(int type, String title, IconData icon) {
    final isSelected = _userType == type;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _userType = type),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? const Color(AppColors.primaryGreen) : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 16,
                color: isSelected ? Colors.white : Colors.grey.shade700,
              ),
              const SizedBox(width: 6),
              Text(
                title,
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  color: isSelected ? Colors.white : Colors.grey.shade700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
