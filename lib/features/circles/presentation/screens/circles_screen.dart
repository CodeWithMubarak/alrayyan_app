import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/app_routes.dart';
import '../../../../core/constants/app_enums.dart';
import '../../../../core/services/app_data_store.dart';
import '../../../../data/models/circle_model.dart';
import '../widgets/circle_barcode_dialog.dart';

/// شاشة إدارة الحلقات
class CirclesScreen extends ConsumerStatefulWidget {
  const CirclesScreen({super.key});

  @override
  ConsumerState<CirclesScreen> createState() => _CirclesScreenState();
}

class _CirclesScreenState extends ConsumerState<CirclesScreen> {
  String _selectedStatus = 'all';

  @override
  Widget build(BuildContext context) {
    final user = AppDataStore.instance.currentUser;
    final isTeacher = user?.role == UserRole.teacher;

    return Scaffold(
      appBar: AppBar(
        title: Text(isTeacher ? 'حلقاتي المسندة' : AppStrings.circles),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: _showSearchDialog,
          ),
        ],
      ),
      body: ListenableBuilder(
        listenable: AppDataStore.instance,
        builder: (context, _) {
          return Column(
            children: [
              _buildFilterChips(),
              Expanded(child: _buildCirclesList()),
            ],
          );
        },
      ),
      floatingActionButton: isTeacher
          ? null
          : FloatingActionButton.extended(
              onPressed: () => context.push(AppRoutes.addCircle),
              icon: const Icon(Icons.add),
              label: const Text(AppStrings.addCircle),
              backgroundColor: const Color(AppColors.primaryGreen),
            ),
    );
  }

  Widget _buildFilterChips() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Theme.of(context).colorScheme.surface,
      child: Row(
        children: [
          _buildFilterChip('الكل', 'all'),
          const SizedBox(width: 8),
          _buildFilterChip('نشطة', 'active'),
          const SizedBox(width: 8),
          _buildFilterChip('متوقفة', 'inactive'),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _selectedStatus == value;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() => _selectedStatus = selected ? value : 'all');
      },
      selectedColor: const Color(AppColors.primaryGreenSoft).withAlpha(80),
      checkmarkColor: const Color(AppColors.primaryGreenDark),
      labelStyle: TextStyle(
        color: isSelected ? const Color(AppColors.primaryGreenDark) : Colors.grey[700],
        fontFamily: 'Cairo',
        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
      ),
    );
  }

  Widget _buildCirclesList() {
    final allCircles = AppDataStore.instance.getVisibleCircles();
    final filtered = _selectedStatus == 'all'
        ? allCircles
        : allCircles.where((c) => (_selectedStatus == 'active' && c.status == CircleStatus.active) || (_selectedStatus == 'inactive' && c.status != CircleStatus.active)).toList();

    if (filtered.isEmpty) {
      final user = AppDataStore.instance.currentUser;
      final isTeacher = user?.role == UserRole.teacher;

      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(AppColors.primaryGreenSoft).withAlpha(80),
                      const Color(AppColors.goldSoft).withAlpha(60),
                    ],
                  ),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.mosque, size: 48, color: Color(AppColors.primaryGreenDark)),
              ),
              const SizedBox(height: 18),
              Text(
                isTeacher ? 'لا توجد حلقات مسندة إليك حالياً' : 'بسم الله نبدأ مسيرة الخير والبركة',
                style: const TextStyle(fontFamily: 'Cairo', fontSize: 18, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                isTeacher
                    ? 'يرجى مراجعة إدارة مسجد الريان لربط حلقتك القرآنية بكود الدخول المخصص لك.'
                    : 'لم يتم إنشاء أي حلقة بعد. بادر الآن بإنشاء أول حلقة قرآنية واكتب اسم مدرسها ليبدأ رصد الطلاب والحفظ.',
                style: const TextStyle(fontFamily: 'Cairo', fontSize: 13, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
              if (!isTeacher) ...[
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () => context.push(AppRoutes.addCircle),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(AppColors.primaryGreen),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  icon: const Icon(Icons.add_circle_outline),
                  label: const Text(
                    '✨ إنشاء أول حلقة قرآنية الآن',
                    style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                ),
              ],
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filtered.length,
      itemBuilder: (context, index) {
        return _buildCircleCard(filtered[index]);
      },
    );
  }

  Widget _buildCircleCard(CircleModel circle) {
    final isActive = circle.status == CircleStatus.active;
    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      elevation: 2,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => context.push('/circles/${circle.id}'),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: const Color(AppColors.primaryGreenSoft).withAlpha(60),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.groups,
                      color: Color(AppColors.primaryGreenDark),
                      size: 26,
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
                                circle.name,
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: isActive ? const Color(AppColors.successLight) : const Color(AppColors.errorLight),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                circle.status.displayName,
                                style: TextStyle(
                                  color: isActive ? const Color(AppColors.success) : const Color(AppColors.error),
                                  fontSize: 11,
                                  fontFamily: 'Cairo',
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                        Text(
                          'المدرس: ${circle.teacherName}',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey[700],
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const Divider(height: 20),

              // كود الدخول وكلمة المرور
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(AppColors.grey100),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.key, size: 16, color: Color(AppColors.goldDark)),
                    const SizedBox(width: 6),
                    Text(
                      'كود: ${circle.circleCode}  |  كلمة المرور: ${circle.accessPassword}',
                      style: const TextStyle(fontFamily: 'Cairo', fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.qr_code_2, size: 22, color: Color(AppColors.goldAccent)),
                      tooltip: 'إنشاء وعرض باركود الحلقة',
                      onPressed: () => CircleBarcodeDialog.show(context, circle),
                    ),
                    IconButton(
                      icon: const Icon(Icons.copy, size: 18, color: Color(AppColors.primaryGreen)),
                      tooltip: 'نسخ بيانات الدخول للمدرس',
                      onPressed: () {
                        final text = '''
حلقات مسجد الريان
السلام عليكم أستاذنا: ${circle.teacherName}
بيانات دخول حلقتكم (${circle.name}):
- كود الحلقة: ${circle.circleCode}
- كلمة مرور الحلقة: ${circle.accessPassword}
''';
                        Clipboard.setData(ClipboardData(text: text));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('تم نسخ بيانات الدخول للحافظة بنجاح', style: TextStyle(fontFamily: 'Cairo'))),
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),

              Row(
                children: [
                  _buildInfoItem(Icons.people_outline, '${circle.studentCount} طالب'),
                  const SizedBox(width: 16),
                  Expanded(child: _buildInfoItem(Icons.school_outlined, circle.level)),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  _buildInfoItem(Icons.calendar_today_outlined, circle.studyDays.join(' - ')),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: Colors.grey[600]),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(
            fontSize: 12,
            fontFamily: 'Cairo',
            color: Colors.grey[700],
          ),
        ),
      ],
    );
  }

  void _showSearchDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('بحث عن حلقة', style: TextStyle(fontFamily: 'Cairo')),
        content: const TextField(
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'اكتب اسم الحلقة أو كود الدخول...',
            prefixIcon: Icon(Icons.search),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('إغلاق', style: TextStyle(fontFamily: 'Cairo')),
          ),
        ],
      ),
    );
  }
}
