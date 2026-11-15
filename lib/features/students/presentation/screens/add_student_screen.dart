import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/app_routes.dart';
import '../../../../core/constants/app_enums.dart';
import '../../../../core/services/app_data_store.dart';
import '../../../../data/models/student_model.dart';

class AddStudentScreen extends ConsumerStatefulWidget {
  final String? initialCircleId;

  const AddStudentScreen({super.key, this.initialCircleId});

  @override
  ConsumerState<AddStudentScreen> createState() => _AddStudentScreenState();
}

class _AddStudentScreenState extends ConsumerState<AddStudentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _studentNumberController = TextEditingController();
  final _fullNameController = TextEditingController();
  final _guardianNameController = TextEditingController();
  final _guardianPhoneController = TextEditingController();
  final _guardianPhone2Controller = TextEditingController();
  final _addressController = TextEditingController(text: 'تريم - دمون');
  final _notesController = TextEditingController();
  final _studentPasswordController = TextEditingController(text: '123456');
  final _guardianPasswordController = TextEditingController(text: '123456');

  String? _selectedCircleId;
  String? _selectedCircleName;
  String _selectedLevel = 'المستوى الأول';
  String _selectedRelation = 'الأب';
  DateTime _birthDate = DateTime(2015, 5, 1);

  @override
  void initState() {
    super.initState();
    _studentNumberController.text = 'STD-${1000 + Random().nextInt(9000)}';
    final circles = AppDataStore.instance.getVisibleCircles();
    if (widget.initialCircleId != null && circles.any((c) => c.id == widget.initialCircleId)) {
      final match = circles.firstWhere((c) => c.id == widget.initialCircleId);
      _selectedCircleId = match.id;
      _selectedCircleName = match.name;
    } else if (circles.isNotEmpty) {
      _selectedCircleId = circles.first.id;
      _selectedCircleName = circles.first.name;
    }
  }

  @override
  void dispose() {
    _studentNumberController.dispose();
    _fullNameController.dispose();
    _guardianNameController.dispose();
    _guardianPhoneController.dispose();
    _guardianPhone2Controller.dispose();
    _addressController.dispose();
    _notesController.dispose();
    _studentPasswordController.dispose();
    _guardianPasswordController.dispose();
    super.dispose();
  }

  void _saveStudent() {
    if (_formKey.currentState!.validate()) {
      if (_selectedCircleId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('يرجى اختيار الحلقة المسجل بها الطالب', style: TextStyle(fontFamily: 'Cairo')),
            backgroundColor: Color(AppColors.warning),
          ),
        );
        return;
      }

      final newStudent = StudentModel(
        id: 'std_${DateTime.now().millisecondsSinceEpoch}',
        studentNumber: _studentNumberController.text.trim(),
        fullName: _fullNameController.text.trim(),
        birthDate: _birthDate,
        enrollmentDate: DateTime.now(),
        circleId: _selectedCircleId!,
        circleName: _selectedCircleName ?? '',
        level: _selectedLevel,
        status: StudentStatus.active,
        guardianName: _guardianNameController.text.trim(),
        guardianRelation: _selectedRelation,
        guardianPhone: _guardianPhoneController.text.trim(),
        guardianPhone2: _guardianPhone2Controller.text.trim(),
        address: _addressController.text.trim(),
        adminNotes: _notesController.text.trim(),
        password: _studentPasswordController.text.trim().isNotEmpty ? _studentPasswordController.text.trim() : '123456',
        guardianPassword: _guardianPasswordController.text.trim().isNotEmpty ? _guardianPasswordController.text.trim() : '123456',
        createdAt: DateTime.now(),
      );

      AppDataStore.instance.addStudent(newStudent);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'ما شاء الله! تم تسجيل الطالب ${_fullNameController.text} بنجاح في $_selectedCircleName',
            style: const TextStyle(fontFamily: 'Cairo'),
          ),
          backgroundColor: const Color(AppColors.success),
        ),
      );
      if (context.canPop()) {
        context.pop();
      } else {
        context.go(AppRoutes.students);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final circles = AppDataStore.instance.getVisibleCircles();

    if (_selectedCircleId == null && circles.isNotEmpty) {
      _selectedCircleId = circles.first.id;
      _selectedCircleName = circles.first.name;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('تسجيل طالب جديد'),
      ),
      body: circles.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        color: const Color(AppColors.primaryGreenSoft).withAlpha(60),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.groups_outlined, size: 48, color: Color(AppColors.primaryGreenDark)),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'لا توجد حلقات قرآنية مضافة بعد',
                      style: TextStyle(fontFamily: 'Cairo', fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'لتسجيل طالب، يرجى أولاً إنشاء حلقة قرآنية وتحديد مدرسها المسؤول عنها.',
                      style: TextStyle(fontFamily: 'Cairo', fontSize: 13, color: Colors.grey),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () {
                        context.pop();
                        context.push(AppRoutes.addCircle);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(AppColors.primaryGreen),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      ),
                      icon: const Icon(Icons.add),
                      label: const Text('إنشاء حلقة جديدة الآن', style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // رقم الطالب
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _studentNumberController,
                            decoration: const InputDecoration(
                              labelText: 'رقم الطالب الأكاديمي (يحدده المدير أو يولد آلياً) *',
                              hintText: 'مثال: STD-1024',
                              prefixIcon: Icon(Icons.badge),
                            ),
                            validator: (val) {
                              if (val == null || val.trim().isEmpty) return 'يرجى كتابة رقم الطالب';
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: const Icon(Icons.refresh, color: Color(AppColors.goldDark)),
                          tooltip: 'توليد رقم أكاديمي تلقائي',
                          onPressed: () {
                            setState(() {
                              _studentNumberController.text = 'STD-${1000 + Random().nextInt(9000)}';
                            });
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // اسم الطالب
                    TextFormField(
                      controller: _fullNameController,
                      decoration: const InputDecoration(
                        labelText: 'اسم الطالب الرباعي واللقب *',
                        hintText: 'مثال: محمد سعيد بن سالم الكندي',
                        prefixIcon: Icon(Icons.person),
                      ),
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) return AppStrings.requiredField;
                        return null;
                      },
                    ),
                    const SizedBox(height: 14),

                    // اختيار الحلقة
                    DropdownButtonFormField<String>(
                      initialValue: _selectedCircleId,
                      decoration: const InputDecoration(
                        labelText: 'الحلقة المسجل بها *',
                        prefixIcon: Icon(Icons.groups),
                      ),
                      items: circles.map((c) {
                        return DropdownMenuItem(
                          value: c.id,
                          child: Text('${c.name} (المدرس: ${c.teacherName})', style: const TextStyle(fontFamily: 'Cairo')),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) {
                          final circle = circles.firstWhere((c) => c.id == val);
                          setState(() {
                            _selectedCircleId = circle.id;
                            _selectedCircleName = circle.name;
                          });
                        }
                      },
                      validator: (val) => val == null ? 'يرجى اختيار الحلقة' : null,
                    ),
                    const SizedBox(height: 14),

                    // المستوى التعليمي
                    DropdownButtonFormField<String>(
                      initialValue: _selectedLevel,
                      decoration: const InputDecoration(
                        labelText: 'المستوى التعليمي للحفظ',
                        prefixIcon: Icon(Icons.school),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'المستوى الأول', child: Text('المستوى الأول', style: TextStyle(fontFamily: 'Cairo'))),
                        DropdownMenuItem(value: 'المستوى الثاني', child: Text('المستوى الثاني', style: TextStyle(fontFamily: 'Cairo'))),
                        DropdownMenuItem(value: 'المستوى الثالث', child: Text('المستوى الثالث', style: TextStyle(fontFamily: 'Cairo'))),
                      ],
                      onChanged: (val) => setState(() => _selectedLevel = val ?? _selectedLevel),
                    ),

                    const Divider(height: 36),

                    // بيانات ولي الأمر
                    const Text(
                      'بيانات ولي الأمر (للتواصل الهاتفي والواتساب)',
                      style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                    const SizedBox(height: 12),

                    Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: TextFormField(
                            controller: _guardianNameController,
                            decoration: const InputDecoration(
                              labelText: 'اسم ولي الأمر *',
                              prefixIcon: Icon(Icons.family_restroom),
                            ),
                            validator: (val) {
                              if (val == null || val.trim().isEmpty) return AppStrings.requiredField;
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 2,
                          child: DropdownButtonFormField<String>(
                            initialValue: _selectedRelation,
                            decoration: const InputDecoration(labelText: 'صلة القرابة'),
                            items: const [
                              DropdownMenuItem(value: 'الأب', child: Text('الأب', style: TextStyle(fontFamily: 'Cairo'))),
                              DropdownMenuItem(value: 'الأم', child: Text('الأم', style: TextStyle(fontFamily: 'Cairo'))),
                              DropdownMenuItem(value: 'الأخ', child: Text('الأخ', style: TextStyle(fontFamily: 'Cairo'))),
                              DropdownMenuItem(value: 'العم/الخال', child: Text('العم/الخال', style: TextStyle(fontFamily: 'Cairo'))),
                            ],
                            onChanged: (val) => setState(() => _selectedRelation = val ?? _selectedRelation),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    TextFormField(
                      controller: _guardianPhoneController,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        labelText: 'رقم هاتف ولي الأمر (واتساب) *',
                        hintText: 'مثال: 777123456',
                        prefixIcon: Icon(Icons.phone),
                      ),
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) return AppStrings.requiredField;
                        return null;
                      },
                    ),
                    const SizedBox(height: 14),

                    TextFormField(
                      controller: _addressController,
                      decoration: const InputDecoration(
                        labelText: 'عنوان السكن والملاحظات',
                        prefixIcon: Icon(Icons.location_on),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // إعدادات قواعد الأمان وكلمات المرور
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(AppColors.primaryGreen).withAlpha(12),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(AppColors.primaryGreen).withAlpha(40)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.security, color: Color(AppColors.primaryGreen), size: 20),
                              SizedBox(width: 8),
                              Text(
                                'قواعد الأمان وبيانات تسجيل الدخول (خاص بالإدارة)',
                                style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold, fontSize: 13),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  controller: _studentPasswordController,
                                  decoration: const InputDecoration(
                                    labelText: 'كلمة مرور الطالب',
                                    prefixIcon: Icon(Icons.lock_outline),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: TextFormField(
                                  controller: _guardianPasswordController,
                                  decoration: const InputDecoration(
                                    labelText: 'كلمة مرور ولي الأمر',
                                    prefixIcon: Icon(Icons.lock_person),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),

                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton.icon(
                        onPressed: _saveStudent,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(AppColors.primaryGreen),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        icon: const Icon(Icons.person_add),
                        label: const Text(
                          'اعتماد وتسجيل الطالب في الحلقة',
                          style: TextStyle(fontFamily: 'Cairo', fontSize: 15, fontWeight: FontWeight.bold),
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
