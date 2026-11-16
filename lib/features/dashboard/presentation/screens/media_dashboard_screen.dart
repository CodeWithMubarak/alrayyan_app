import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:responsive_framework/responsive_framework.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_routes.dart';
import '../../../../core/services/app_data_store.dart';
import '../../../../core/widgets/app_sidebar.dart';
import '../../../../core/widgets/app_bottom_nav.dart';
import '../../../../core/widgets/quran_daily_verse_card.dart';
import '../../../../data/models/announcement_model.dart';

/// لوحة تحكم المسؤول الإعلامي المستقلة تماماً
class MediaDashboardScreen extends ConsumerStatefulWidget {
  const MediaDashboardScreen({super.key});

  @override
  ConsumerState<MediaDashboardScreen> createState() => _MediaDashboardScreenState();
}

class _MediaDashboardScreenState extends ConsumerState<MediaDashboardScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final isDesktop = ResponsiveBreakpoints.of(context).isDesktop ||
        ResponsiveBreakpoints.of(context).isTablet;

    return Scaffold(
      backgroundColor: const Color(AppColors.offWhite),
      appBar: isDesktop
          ? null
          : AppBar(
              title: const Text(
                'بوابة الإعلام والتواصل',
                style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold),
              ),
              backgroundColor: const Color(AppColors.primaryGreen),
              foregroundColor: Colors.white,
              actions: [
                IconButton(
                  icon: const Icon(Icons.add_alert_outlined),
                  tooltip: 'إرسال تنبيه عاجل',
                  onPressed: () => _showBroadcastDialog(context),
                ),
                IconButton(
                  icon: const Icon(Icons.notifications_outlined),
                  onPressed: () => context.push(AppRoutes.notifications),
                ),
              ],
            ),
      drawer: isDesktop ? null : const AppSidebar(),
      body: ListenableBuilder(
        listenable: AppDataStore.instance,
        builder: (context, _) {
          return isDesktop
              ? Row(
                  children: [
                    const AppSidebar(isDrawer: false),
                    Expanded(child: _buildContent(context)),
                  ],
                )
              : _buildContent(context);
        },
      ),
      bottomNavigationBar: isDesktop
          ? null
          : AppBottomNav(
              selectedIndex: _selectedIndex,
              onIndexChanged: (i) => setState(() => _selectedIndex = i),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showNewAnnouncementDialog(context),
        backgroundColor: const Color(AppColors.primaryGreen),
        icon: const Icon(Icons.campaign, color: Colors.white),
        label: const Text(
          'نشر إعلان / نشاط جديد',
          style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    final store = AppDataStore.instance;
    final mediaOfficerName = store.currentUser?.name ?? 'المسؤول الإعلامي';
    final announcements = store.announcements;
    final achievements = store.achievements;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // بطاقة الترحيب والتعريف بالدور الإعلامي
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF103D32), Color(0xFF1B5E20)],
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF103D32).withAlpha(50),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(AppColors.goldAccent).withAlpha(40),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          '📸 مهمة: التغطية الإعلامية ونشر الأنشطة',
                          style: TextStyle(fontFamily: 'Cairo', fontSize: 11, fontWeight: FontWeight.bold, color: Color(AppColors.goldLight)),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'مرحباً بك، $mediaOfficerName',
                        style: const TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'أنت مسؤول عن إدارة التغطيات الإعلامية، نشر إعلانات المسجد، وتكريم الحفظة في لوحة الشرف.',
                        style: TextStyle(fontFamily: 'Cairo', fontSize: 12, color: Colors.white70),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(30),
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(AppColors.goldAccent), width: 2),
                  ),
                  child: const Icon(Icons.photo_camera_back, color: Colors.white, size: 30),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),
          const QuranDailyVerseCard(),
          const SizedBox(height: 16),

          // إجراءات سريعة خاصة بالإعلامي
          Row(
            children: [
              Expanded(
                child: _buildActionCard(
                  title: 'نشر إعلان جديد',
                  subtitle: 'أخبار وفعاليات المسجد',
                  icon: Icons.campaign_outlined,
                  color: const Color(AppColors.primaryGreen),
                  onTap: () => _showNewAnnouncementDialog(context),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildActionCard(
                  title: 'لوحة الشرف والتكريم',
                  subtitle: '${achievements.length} تكريم منشور',
                  icon: Icons.emoji_events_outlined,
                  color: const Color(AppColors.goldDark),
                  onTap: () => context.push(AppRoutes.achievements),
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // قسم الإعلانات والأنشطة الحالية
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '📢 الإعلانات والتغطيات المنشورة (${announcements.length})',
                style: const TextStyle(fontFamily: 'Cairo', fontSize: 16, fontWeight: FontWeight.bold),
              ),
              TextButton.icon(
                onPressed: () => context.push(AppRoutes.notifications),
                icon: const Icon(Icons.arrow_forward, size: 16),
                label: const Text('عرض الكل', style: TextStyle(fontFamily: 'Cairo')),
              ),
            ],
          ),
          const SizedBox(height: 8),

          if (announcements.isEmpty)
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(
                child: Text(
                  'لا توجد إعلانات منشورة حالياً. ابدأ بنشر أول تغطية أو إعلان للطلاب.',
                  style: TextStyle(fontFamily: 'Cairo', color: Colors.grey),
                ),
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: announcements.take(5).length,
              itemBuilder: (context, i) {
                final item = announcements[i];
                return Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: item.isPinned
                          ? const Color(AppColors.goldAccent).withAlpha(40)
                          : const Color(AppColors.primaryGreen).withAlpha(30),
                      child: Icon(
                        item.isPinned ? Icons.push_pin : Icons.article_outlined,
                        color: item.isPinned ? const Color(AppColors.goldDark) : const Color(AppColors.primaryGreen),
                      ),
                    ),
                    title: Text(
                      item.title,
                      style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    subtitle: Text(
                      '${item.type.displayName} • ${item.createdAt.toString().split(" ")[0]}',
                      style: const TextStyle(fontFamily: 'Cairo', fontSize: 11, color: Colors.grey),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                      tooltip: 'حذف الإعلان',
                      onPressed: () {
                        store.deleteAnnouncement(item.id);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('تم حذف الإعلان بنجاح', style: TextStyle(fontFamily: 'Cairo'))),
                        );
                      },
                    ),
                  ),
                );
              },
            ),

          const SizedBox(height: 24),

          // قسم تكريم الطلاب والأوسمة
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '🏆 سجل الأوسمة والمتفوقين (${achievements.length})',
                style: const TextStyle(fontFamily: 'Cairo', fontSize: 16, fontWeight: FontWeight.bold),
              ),
              TextButton.icon(
                onPressed: () => context.push(AppRoutes.achievements),
                icon: const Icon(Icons.arrow_forward, size: 16),
                label: const Text('لوحة الشرف', style: TextStyle(fontFamily: 'Cairo')),
              ),
            ],
          ),
          const SizedBox(height: 8),

          if (achievements.isEmpty)
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(
                child: Text(
                  'لم يتم تسجيل أي أوسمة تكريمية بعد.',
                  style: TextStyle(fontFamily: 'Cairo', color: Colors.grey),
                ),
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: achievements.take(4).length,
              itemBuilder: (context, i) {
                final ach = achievements[i];
                return Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: Color(AppColors.goldSoft),
                      child: Icon(Icons.military_tech, color: Color(AppColors.goldDark)),
                    ),
                    title: Text(
                      ach.title,
                      style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                    subtitle: Text(
                      'المكرم: ${ach.studentName} • ${ach.description}',
                      style: const TextStyle(fontFamily: 'Cairo', fontSize: 11),
                    ),
                  ),
                );
              },
            ),

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildActionCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withAlpha(40)),
          boxShadow: [
            BoxShadow(
              color: color.withAlpha(15),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: color.withAlpha(30),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold, fontSize: 13),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: TextStyle(fontFamily: 'Cairo', fontSize: 11, color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }

  void _showNewAnnouncementDialog(BuildContext context) {
    final titleController = TextEditingController();
    final contentController = TextEditingController();
    AnnouncementType selectedType = AnnouncementType.general;
    bool isPinned = false;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (dialogCtx, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: const Row(
                children: [
                  Icon(Icons.campaign, color: Color(AppColors.primaryGreen)),
                  SizedBox(width: 8),
                  Text('نشر إعلان / نشاط جديد', style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold, fontSize: 16)),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: titleController,
                      decoration: const InputDecoration(labelText: 'عنوان الإعلان أو الفعالية', hintText: 'مثال: حفل تكريم حفظة القرآن'),
                      style: const TextStyle(fontFamily: 'Cairo'),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<AnnouncementType>(
                      value: selectedType,
                      decoration: const InputDecoration(labelText: 'تصنيف الإعلان'),
                      items: AnnouncementType.values.map((t) {
                        return DropdownMenuItem(value: t, child: Text(t.displayName, style: const TextStyle(fontFamily: 'Cairo')));
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) setDialogState(() => selectedType = val);
                      },
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: contentController,
                      maxLines: 4,
                      decoration: const InputDecoration(labelText: 'تفاصيل التغطية أو نص الإعلان', hintText: 'اكتب التفاصيل الكاملة هنا...'),
                      style: const TextStyle(fontFamily: 'Cairo'),
                    ),
                    const SizedBox(height: 8),
                    CheckboxListTile(
                      title: const Text('تثبيت الإعلان في الواجهة الرئيسية', style: TextStyle(fontFamily: 'Cairo', fontSize: 12)),
                      value: isPinned,
                      onChanged: (val) => setDialogState(() => isPinned = val ?? false),
                      controlAffinity: ListTileControlAffinity.leading,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('إلغاء', style: TextStyle(fontFamily: 'Cairo')),
                ),
                ElevatedButton(
                  onPressed: () {
                    final title = titleController.text.trim();
                    final content = contentController.text.trim();
                    if (title.isEmpty) return;

                    final store = AppDataStore.instance;
                    final newAnn = AnnouncementModel(
                      id: 'ann_${DateTime.now().millisecondsSinceEpoch}',
                      title: title,
                      content: content,
                      type: selectedType,
                      isPinned: isPinned,
                      createdAt: DateTime.now(),
                      createdBy: store.currentUser?.id ?? 'media_officer',
                      createdByName: store.currentUser?.name ?? 'المسؤول الإعلامي',
                    );
                    store.addAnnouncement(newAnn);

                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('تم نشر الإعلان الإعلامي بنجاح وتعميمه', style: TextStyle(fontFamily: 'Cairo')),
                        backgroundColor: Color(AppColors.primaryGreen),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(AppColors.primaryGreen),
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('نشر وتعميم الآن', style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showBroadcastDialog(BuildContext context) {
    final alertController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Row(
            children: [
              Icon(Icons.add_alert, color: Color(AppColors.goldDark)),
              SizedBox(width: 8),
              Text('إرسال تنبيه عاجل لجميع الطلاب والأولياء', style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold, fontSize: 14)),
            ],
          ),
          content: TextField(
            controller: alertController,
            maxLines: 3,
            decoration: const InputDecoration(hintText: 'اكتب التنبيه هنا (مثال: غداً تبدأ اختبارات الأجزاء القرآنية)', labelText: 'نص التنبيه'),
            style: const TextStyle(fontFamily: 'Cairo'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('إلغاء', style: TextStyle(fontFamily: 'Cairo')),
            ),
            ElevatedButton(
              onPressed: () {
                final txt = alertController.text.trim();
                if (txt.isEmpty) return;

                final store = AppDataStore.instance;
                final newAnn = AnnouncementModel(
                  id: 'alert_${DateTime.now().millisecondsSinceEpoch}',
                  title: '🔔 تنبيه هام وعاجل',
                  content: txt,
                  type: AnnouncementType.urgent,
                  isPinned: true,
                  createdAt: DateTime.now(),
                  createdBy: store.currentUser?.id ?? 'media_officer',
                  createdByName: store.currentUser?.name ?? 'المسؤول الإعلامي',
                );
                store.addAnnouncement(newAnn);

                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('تم إرسال التنبيه العاجل بنجاح لكافة مستخدمي المنظومة', style: TextStyle(fontFamily: 'Cairo')),
                    backgroundColor: Color(AppColors.primaryGreen),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: const Color(AppColors.goldDark), foregroundColor: Colors.white),
              child: const Text('إرسال التنبيه', style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }
}
