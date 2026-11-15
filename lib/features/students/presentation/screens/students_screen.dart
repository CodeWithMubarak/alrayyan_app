import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/app_routes.dart';
import '../../../../core/constants/app_enums.dart';
import '../../../../core/utils/permissions_helper.dart';
import '../../../../core/services/app_data_store.dart';
import '../../../../core/services/export_service.dart';
import '../../../../data/models/student_model.dart';

/// شاشة قائمة الطلاب
class StudentsScreen extends ConsumerStatefulWidget {
  const StudentsScreen({super.key});

  @override
  ConsumerState<StudentsScreen> createState() => _StudentsScreenState();
}

class _StudentsScreenState extends ConsumerState<StudentsScreen> {
  final _searchController = TextEditingController();
  String _selectedFilter = 'all';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _callPhone(String phone) async {
    final uri = Uri.parse('tel:$phone');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('الاتصال بالرقم: $phone', style: const TextStyle(fontFamily: 'Cairo'))),
        );
      }
    }
  }

  void _openWhatsApp(String phone, String studentName) async {
    final message = Uri.encodeComponent('السلام عليكم ورحمة الله، ولي أمر الطالب $studentName، نتواصل معكم من حلقات مسجد الريان لتعليم القرآن الكريم.');
    final uri = Uri.parse('https://wa.me/967$phone?text=$message');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('فتح محادثة واتساب مع: $phone', style: const TextStyle(fontFamily: 'Cairo'))),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = AppDataStore.instance.currentUser;
    final isTeacher = user?.role == UserRole.teacher;
    final canAdd = PermissionsHelper.canAddStudent(
      user?.role ?? UserRole.teacher,
      permissions: user?.permissions,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(isTeacher ? 'طلابي' : AppStrings.students),
        actions: [
          IconButton(
            icon: const Icon(Icons.table_view_outlined),
            tooltip: 'تصدير كشف الطلاب إلى Excel',
            onPressed: () async {
              final store = AppDataStore.instance;
              await ExportService.instance.exportStudentsToExcel(store.students);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('تم تصدير كشف الطلاب بنجاح (Excel)', style: TextStyle(fontFamily: 'Cairo')),
                    backgroundColor: Color(AppColors.primaryGreen),
                  ),
                );
              }
            },
          ),
        ],
      ),
      body: ListenableBuilder(
        listenable: AppDataStore.instance,
        builder: (context, _) {
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: TextField(
                  controller: _searchController,
                  decoration: const InputDecoration(
                    hintText: 'ابحث بالاسم أو رقم الطالب أو ولي الأمر...',
                    prefixIcon: Icon(Icons.search),
                    isDense: true,
                  ),
                  onChanged: (_) => setState(() {}),
                ),
              ),
              _buildStatusFilters(),
              Expanded(child: _buildStudentsList()),
            ],
          );
        },
      ),
      floatingActionButton: canAdd
          ? FloatingActionButton.extended(
              onPressed: () => context.push(AppRoutes.addStudent),
              icon: const Icon(Icons.person_add),
              label: const Text(AppStrings.addStudent),
              backgroundColor: const Color(AppColors.primaryGreen),
            )
          : null,
    );
  }

  Widget _buildStatusFilters() {
    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _buildChip('الكل', 'all'),
          const SizedBox(width: 8),
          _buildChip('نشط', 'active'),
          const SizedBox(width: 8),
          _buildChip('متوقف', 'suspended'),
        ],
      ),
    );
  }

  Widget _buildChip(String label, String value) {
    final isSelected = _selectedFilter == value;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (sel) => setState(() => _selectedFilter = sel ? value : 'all'),
      selectedColor: const Color(AppColors.primaryGreenSoft).withAlpha(80),
      checkmarkColor: const Color(AppColors.primaryGreenDark),
      labelStyle: TextStyle(
        fontFamily: 'Cairo',
        fontSize: 12,
        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
        color: isSelected ? const Color(AppColors.primaryGreenDark) : Colors.grey[700],
      ),
      visualDensity: VisualDensity.compact,
    );
  }

  Widget _buildStudentsList() {
    final query = _searchController.text.trim().toLowerCase();
    final allStudents = AppDataStore.instance.getVisibleStudents();

    final filtered = allStudents.where((s) {
      final matchesQuery = query.isEmpty ||
          s.fullName.toLowerCase().contains(query) ||
          s.studentNumber.toLowerCase().contains(query) ||
          s.guardianName.toLowerCase().contains(query);
      final matchesStatus = _selectedFilter == 'all' ||
          (_selectedFilter == 'active' && s.status == StudentStatus.active) ||
          (_selectedFilter == 'suspended' && s.status != StudentStatus.active);
      return matchesQuery && matchesStatus;
    }).toList();

    if (filtered.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.person_search, size: 70, color: Colors.grey[400]),
            const SizedBox(height: 12),
            const Text('لا يوجد طلاب مطابقون للبحث', style: TextStyle(fontFamily: 'Cairo', color: Colors.grey)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filtered.length,
      itemBuilder: (context, index) {
        return _buildStudentCard(filtered[index]);
      },
    );
  }

  Widget _buildStudentCard(StudentModel student) {
    final isActive = student.status == StudentStatus.active;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => context.push('/students/${student.id}'),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: const Color(AppColors.primaryGreenSoft).withAlpha(60),
                    child: Text(
                      student.fullName.isNotEmpty ? student.fullName[0] : 'ط',
                      style: const TextStyle(
                        color: Color(AppColors.primaryGreenDark),
                        fontFamily: 'Cairo',
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                student.fullName,
                                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            _buildStatusBadge(isActive ? 'نشط' : 'متوقف'),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${student.studentNumber} • ${student.circleName}',
                          style: TextStyle(fontFamily: 'Cairo', fontSize: 11, color: Colors.grey[700]),
                        ),
                        Text(
                          'المستوى: ${student.level}',
                          style: TextStyle(fontFamily: 'Cairo', fontSize: 11, color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const Divider(height: 18),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      'ولي الأمر: ${student.guardianName} (${student.guardianRelation})',
                      style: const TextStyle(fontFamily: 'Cairo', fontSize: 11, fontWeight: FontWeight.w600),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.phone, size: 20, color: Color(AppColors.primaryGreen)),
                        tooltip: 'اتصال بولي الأمر',
                        onPressed: () => _callPhone(student.guardianPhone),
                      ),
                      IconButton(
                        icon: const Icon(Icons.chat, size: 20, color: Color(AppColors.success)),
                        tooltip: 'واتساب ولي الأمر',
                        onPressed: () => _openWhatsApp(student.guardianPhone, student.fullName),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color bgColor = status == 'نشط' ? const Color(AppColors.successLight) : const Color(AppColors.errorLight);
    Color textColor = status == 'نشط' ? const Color(AppColors.success) : const Color(AppColors.error);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(12)),
      child: Text(
        status,
        style: TextStyle(color: textColor, fontSize: 10, fontFamily: 'Cairo', fontWeight: FontWeight.w700),
      ),
    );
  }
}
