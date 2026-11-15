import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';

/// شاشة الإعدادات
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.settings),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ===== معلومات المؤسسة =====
          _buildSection(context, 'معلومات المؤسسة', [
            _buildTile(context,
              icon: Icons.mosque_outlined,
              title: AppStrings.institutionName,
              subtitle: AppStrings.location,
              trailing: null,
              onTap: null,
            ),
            _buildTile(context,
              icon: Icons.calendar_today_outlined,
              title: 'العام الدراسي',
              subtitle: AppStrings.academicYear,
              trailing: null,
              onTap: null,
            ),
          ]),

          const SizedBox(height: 16),

          // ===== التطبيق =====
          _buildSection(context, 'إعدادات التطبيق', [
            _buildTile(context,
              icon: Icons.dark_mode_outlined,
              title: 'المظهر',
              subtitle: 'فاتح / داكن',
              trailing: const Icon(Icons.arrow_forward_ios, size: 14),
              onTap: () => _showThemeDialog(context, ref),
            ),
            _buildTile(context,
              icon: Icons.language_outlined,
              title: 'اللغة',
              subtitle: 'العربية',
              trailing: const Icon(Icons.arrow_forward_ios, size: 14),
              onTap: null,
            ),
            _buildTile(context,
              icon: Icons.notifications_outlined,
              title: 'الإشعارات',
              subtitle: 'إعداد الإشعارات',
              trailing: const Icon(Icons.arrow_forward_ios, size: 14),
              onTap: null,
            ),
          ]),

          const SizedBox(height: 16),

          // ===== النظام =====
          _buildSection(context, 'إدارة النظام', [
            _buildTile(context,
              icon: Icons.people_outline,
              title: 'إدارة المستخدمين',
              subtitle: 'إضافة وتعديل الحسابات',
              trailing: const Icon(Icons.arrow_forward_ios, size: 14),
              onTap: () => context.push('/users'),
            ),
            _buildTile(context,
              icon: Icons.security_outlined,
              title: 'قواعد الأمان وكلمات المرور',
              subtitle: 'إدارة كلمات مرور المدرسين والصلاحيات',
              trailing: const Icon(Icons.arrow_forward_ios, size: 14),
              onTap: () => context.push('/users'),
            ),
            _buildTile(context,
              icon: Icons.history_outlined,
              title: 'سجل العمليات',
              subtitle: 'تتبع جميع الأنشطة',
              trailing: const Icon(Icons.arrow_forward_ios, size: 14),
              onTap: () => context.push('/settings/audit-logs'),
            ),
            _buildTile(context,
              icon: Icons.backup_outlined,
              title: 'النسخ الاحتياطي',
              subtitle: 'نسخ واستعادة البيانات',
              trailing: const Icon(Icons.arrow_forward_ios, size: 14),
              onTap: () => context.push('/settings/backup'),
            ),
          ]),

          const SizedBox(height: 16),

          // ===== التقديرات =====
          _buildSection(context, 'إعدادات التقديرات', [
            _buildTile(context,
              icon: Icons.grade_outlined,
              title: 'جدول التقديرات',
              subtitle: 'تعديل نطاقات الدرجات والتقديرات',
              trailing: const Icon(Icons.arrow_forward_ios, size: 14),
              onTap: null,
            ),
          ]),

          const SizedBox(height: 16),

          // ===== عن التطبيق =====
          _buildSection(context, 'عن التطبيق', [
            _buildTile(context,
              icon: Icons.info_outline,
              title: 'الإصدار',
              subtitle: AppStrings.version,
              trailing: null,
              onTap: null,
            ),
            _buildTile(context,
              icon: Icons.update_outlined,
              title: 'التحديثات',
              subtitle: 'التحقق من وجود تحديثات',
              trailing: const Icon(Icons.arrow_forward_ios, size: 14),
              onTap: null,
            ),
          ]),

          const SizedBox(height: 24),

          // ===== تسجيل الخروج =====
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: OutlinedButton.icon(
              onPressed: () => _showLogoutDialog(context, ref),
              icon: const Icon(Icons.logout, color: Color(AppColors.error)),
              label: const Text(
                AppStrings.logout,
                style: TextStyle(color: Color(AppColors.error), fontFamily: 'Cairo'),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(AppColors.error)),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSection(BuildContext context, String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(right: 4, bottom: 8),
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: const Color(AppColors.primaryGreen),
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        Card(
          child: Column(
            children: children,
          ),
        ),
      ],
    );
  }

  Widget _buildTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Widget? trailing,
    required VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: const Color(AppColors.primaryGreenSoft).withOpacity(0.2),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: const Color(AppColors.primaryGreen), size: 20),
      ),
      title: Text(title, style: const TextStyle(fontFamily: 'Cairo', fontSize: 14, fontWeight: FontWeight.w600)),
      subtitle: Text(subtitle, style: const TextStyle(fontFamily: 'Cairo', fontSize: 12)),
      trailing: trailing,
      onTap: onTap,
    );
  }

  void _showThemeDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: const Text('اختر المظهر', style: TextStyle(fontFamily: 'Cairo')),
        children: [
          SimpleDialogOption(
            child: const Text('فاتح', style: TextStyle(fontFamily: 'Cairo')),
            onPressed: () {
              Navigator.pop(ctx);
            },
          ),
          SimpleDialogOption(
            child: const Text('داكن', style: TextStyle(fontFamily: 'Cairo')),
            onPressed: () {
              Navigator.pop(ctx);
            },
          ),
          SimpleDialogOption(
            child: const Text('تلقائي (حسب الجهاز)', style: TextStyle(fontFamily: 'Cairo')),
            onPressed: () {
              Navigator.pop(ctx);
            },
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(AppStrings.logout, style: TextStyle(fontFamily: 'Cairo')),
        content: const Text(AppStrings.logoutConfirm, style: TextStyle(fontFamily: 'Cairo')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(AppStrings.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              // TODO: تنفيذ تسجيل الخروج
              context.go('/login');
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(AppColors.error)),
            child: const Text(AppStrings.logout),
          ),
        ],
      ),
    );
  }
}
