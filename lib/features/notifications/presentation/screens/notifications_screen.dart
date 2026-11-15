import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';

/// شاشة الإشعارات
class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الإشعارات'),
        actions: [
          TextButton(
            onPressed: () {},
            child: const Text(
              'تحديد الكل كمقروء',
              style: TextStyle(color: Colors.white, fontFamily: 'Cairo', fontSize: 12),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildNotificationGroup(context, 'اليوم', [
            _buildNotificationItem(
              context,
              icon: Icons.person_add,
              color: const Color(AppColors.success),
              title: 'تم تسجيل طالب جديد',
              body: 'تم إضافة الطالب محمد أحمد إلى حلقة الفجر',
              time: 'منذ ساعة',
              isRead: false,
            ),
            _buildNotificationItem(
              context,
              icon: Icons.assignment_outlined,
              color: const Color(AppColors.warning),
              title: 'تقرير ينتظر الاعتماد',
              body: 'التقرير الشهري لحلقة الفجر - أكتوبر 2026',
              time: 'منذ 3 ساعات',
              isRead: false,
            ),
          ]),
          const SizedBox(height: 16),
          _buildNotificationGroup(context, 'أمس', [
            _buildNotificationItem(
              context,
              icon: Icons.check_circle,
              color: const Color(AppColors.success),
              title: 'تم اعتماد التقرير',
              body: 'تم اعتماد التقرير الشهري لحلقة المغرب - سبتمبر 2026',
              time: 'أمس 10:30 ص',
              isRead: true,
            ),
          ]),
        ],
      ),
    );
  }

  Widget _buildNotificationGroup(BuildContext context, String title, List<Widget> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: Colors.grey[600],
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        Card(
          child: Column(children: items),
        ),
      ],
    );
  }

  Widget _buildNotificationItem(
    BuildContext context, {
    required IconData icon,
    required Color color,
    required String title,
    required String body,
    required String time,
    required bool isRead,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isRead ? null : color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 22),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 14,
                  fontWeight: isRead ? FontWeight.w500 : FontWeight.w700,
                ),
              ),
            ),
            if (!isRead)
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              body,
              style: const TextStyle(fontFamily: 'Cairo', fontSize: 12),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              time,
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 11,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
        onTap: () {},
      ),
    );
  }
}
