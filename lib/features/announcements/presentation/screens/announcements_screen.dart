import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_enums.dart';
import '../../../../core/services/app_data_store.dart';
import '../../../../core/widgets/app_sidebar.dart';
import '../../../../core/widgets/app_bottom_nav.dart';
import '../../../../data/models/announcement_model.dart';

class AnnouncementsScreen extends ConsumerStatefulWidget {
  const AnnouncementsScreen({super.key});

  @override
  ConsumerState<AnnouncementsScreen> createState() =>
      _AnnouncementsScreenState();
}

class _AnnouncementsScreenState extends ConsumerState<AnnouncementsScreen>
    with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;
  AnnouncementType? _filterType;

  @override
  Widget build(BuildContext context) {
    final store = AppDataStore.instance;
    final isAdmin = store.currentUser?.role == UserRole.admin ||
        store.currentUser?.role == UserRole.viceAdmin;
    final isWide = MediaQuery.of(context).size.width > 800;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F3ED),
      appBar: isWide
          ? null
          : AppBar(
              backgroundColor: const Color(AppColors.primaryGreen),
              foregroundColor: Colors.white,
              title: const Text(
                'الإعلانات والأنشطة',
                style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold),
              ),
              actions: [
                if (isAdmin)
                  IconButton(
                    icon: const Icon(Icons.add_circle_outline),
                    onPressed: () => _showAddAnnouncementDialog(context),
                    tooltip: 'إضافة إعلان',
                  ),
              ],
            ),
      drawer: isWide ? null : const AppSidebar(),
      body: ListenableBuilder(
        listenable: AppDataStore.instance,
        builder: (context, _) {
          return isWide
              ? Row(children: [
                  const AppSidebar(isDrawer: false),
                  Expanded(child: _buildBody(context, store, isAdmin)),
                ])
              : _buildBody(context, store, isAdmin);
        },
      ),
      floatingActionButton: isAdmin
          ? FloatingActionButton.extended(
              onPressed: () => _showAddAnnouncementDialog(context),
              backgroundColor: const Color(AppColors.goldAccent),
              foregroundColor: Colors.white,
              icon: const Icon(Icons.add),
              label: const Text('إعلان جديد',
                  style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold)),
            )
          : null,
      bottomNavigationBar: isWide
          ? null
          : AppBottomNav(
              selectedIndex: _selectedIndex,
              onIndexChanged: (i) => setState(() => _selectedIndex = i),
            ),
    );
  }

  Widget _buildBody(BuildContext context, AppDataStore store, bool isAdmin) {
    var items = List<AnnouncementModel>.from(store.announcements);
    if (_filterType != null) {
      items = items.where((a) => a.type == _filterType).toList();
    }
    // المثبتة أولاً
    items.sort((a, b) {
      if (a.isPinned && !b.isPinned) return -1;
      if (!a.isPinned && b.isPinned) return 1;
      return b.createdAt.compareTo(a.createdAt);
    });

    return Column(
      children: [
        _buildFilterBar(),
        Expanded(
          child: items.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: items.length,
                  itemBuilder: (ctx, i) =>
                      _buildAnnouncementCard(ctx, items[i], isAdmin),
                ),
        ),
      ],
    );
  }

  Widget _buildFilterBar() {
    final types = [null, ...AnnouncementType.values];
    return Container(
      height: 52,
      color: Colors.white,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: types.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (ctx, i) {
          final t = types[i];
          final selected = _filterType == t;
          return GestureDetector(
            onTap: () => setState(() => _filterType = t),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
              decoration: BoxDecoration(
                color: selected
                    ? const Color(AppColors.primaryGreen)
                    : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: selected
                      ? const Color(AppColors.primaryGreen)
                      : Colors.grey.shade300,
                ),
              ),
              child: Text(
                t == null ? '📋 الكل' : '${t.icon} ${t.displayName}',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: selected ? Colors.white : Colors.grey.shade700,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAnnouncementCard(
      BuildContext context, AnnouncementModel ann, bool isAdmin) {
    final color = Color(ann.type.colorValue);
    final fmt = DateFormat('yyyy/MM/dd', 'ar');
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(10),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: ann.isPinned
            ? Border.all(color: const Color(AppColors.goldAccent), width: 1.5)
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header بلون النوع
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: color.withAlpha(20),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              children: [
                Text(ann.type.icon, style: const TextStyle(fontSize: 20)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    ann.title,
                    style: const TextStyle(
                      fontFamily: 'Cairo',
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ),
                if (ann.isPinned)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(AppColors.goldAccent).withAlpha(30),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Text('📌 مثبت',
                        style:
                            TextStyle(fontFamily: 'Cairo', fontSize: 11)),
                  ),
                if (isAdmin) ...[
                  const SizedBox(width: 8),
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert, size: 18),
                    onSelected: (val) {
                      if (val == 'delete') {
                        AppDataStore.instance.deleteAnnouncement(ann.id);
                      } else if (val == 'pin') {
                        AppDataStore.instance.updateAnnouncement(
                            ann.copyWith(isPinned: !ann.isPinned));
                      }
                    },
                    itemBuilder: (ctx) => [
                      PopupMenuItem(
                        value: 'pin',
                        child: Text(
                          ann.isPinned ? 'إلغاء التثبيت' : 'تثبيت',
                          style: const TextStyle(fontFamily: 'Cairo'),
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Text('حذف',
                            style: TextStyle(
                                fontFamily: 'Cairo', color: Colors.red)),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          // المحتوى
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  ann.content,
                  style: const TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 14,
                    height: 1.6,
                    color: Color(0xFF444444),
                  ),
                ),
                if (ann.eventDate != null) ...[
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(AppColors.primaryGreen).withAlpha(15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.event,
                            size: 14,
                            color: Color(AppColors.primaryGreen)),
                        const SizedBox(width: 6),
                        Text(
                          'الموعد: ${fmt.format(ann.eventDate!)}',
                          style: const TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 12,
                            color: Color(AppColors.primaryGreen),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.person_outline,
                        size: 13, color: Colors.grey.shade500),
                    const SizedBox(width: 4),
                    Text(
                      ann.createdByName,
                      style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 11,
                          color: Colors.grey.shade500),
                    ),
                    const Spacer(),
                    Text(
                      fmt.format(ann.createdAt),
                      style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 11,
                          color: Colors.grey.shade400),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: const Color(AppColors.primaryGreen).withAlpha(15),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.campaign_outlined,
                size: 50, color: Color(AppColors.primaryGreen)),
          ),
          const SizedBox(height: 16),
          const Text('لا توجد إعلانات',
              style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(AppColors.primaryGreen))),
          const SizedBox(height: 8),
          Text(
            'ستظهر هنا إعلانات المسجد والأنشطة والمسابقات',
            style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 13,
                color: Colors.grey.shade500),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _showAddAnnouncementDialog(BuildContext context) {
    final titleCtrl = TextEditingController();
    final contentCtrl = TextEditingController();
    AnnouncementType selectedType = AnnouncementType.general;
    bool isPinned = false;
    DateTime? eventDate;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setStateDialog) => AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Row(
            children: [
              Icon(Icons.campaign, color: Color(AppColors.primaryGreen)),
              SizedBox(width: 8),
              Text('إعلان جديد',
                  style: TextStyle(
                      fontFamily: 'Cairo', fontWeight: FontWeight.bold)),
            ],
          ),
          content: SizedBox(
            width: 400,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: titleCtrl,
                    decoration: InputDecoration(
                      labelText: 'عنوان الإعلان *',
                      labelStyle:
                          const TextStyle(fontFamily: 'Cairo'),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                    style: const TextStyle(fontFamily: 'Cairo'),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<AnnouncementType>(
                    value: selectedType,
                    decoration: InputDecoration(
                      labelText: 'نوع الإعلان',
                      labelStyle: const TextStyle(fontFamily: 'Cairo'),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                    items: AnnouncementType.values
                        .map((t) => DropdownMenuItem(
                              value: t,
                              child: Text('${t.icon} ${t.displayName}',
                                  style:
                                      const TextStyle(fontFamily: 'Cairo')),
                            ))
                        .toList(),
                    onChanged: (v) {
                      if (v != null) {
                        setStateDialog(() => selectedType = v);
                      }
                    },
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: contentCtrl,
                    maxLines: 4,
                    decoration: InputDecoration(
                      labelText: 'نص الإعلان *',
                      alignLabelWithHint: true,
                      labelStyle: const TextStyle(fontFamily: 'Cairo'),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                    style: const TextStyle(fontFamily: 'Cairo', height: 1.5),
                  ),
                  const SizedBox(height: 12),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.event,
                        color: Color(AppColors.primaryGreen)),
                    title: Text(
                      eventDate == null
                          ? 'تحديد تاريخ الفعالية (اختياري)'
                          : 'الموعد: ${DateFormat('yyyy/MM/dd', 'ar').format(eventDate!)}',
                      style: const TextStyle(fontFamily: 'Cairo', fontSize: 13),
                    ),
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: ctx,
                        initialDate: DateTime.now(),
                        firstDate: DateTime.now(),
                        lastDate:
                            DateTime.now().add(const Duration(days: 365)),
                      );
                      if (picked != null) {
                        setStateDialog(() => eventDate = picked);
                      }
                    },
                  ),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    activeColor: const Color(AppColors.goldAccent),
                    title: const Text('تثبيت الإعلان',
                        style:
                            TextStyle(fontFamily: 'Cairo', fontSize: 13)),
                    value: isPinned,
                    onChanged: (v) => setStateDialog(() => isPinned = v),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('إلغاء',
                  style: TextStyle(fontFamily: 'Cairo', color: Colors.grey)),
            ),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(AppColors.primaryGreen),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              icon: const Icon(Icons.send, size: 16),
              label: const Text('نشر',
                  style: TextStyle(fontFamily: 'Cairo')),
              onPressed: () {
                if (titleCtrl.text.trim().isEmpty ||
                    contentCtrl.text.trim().isEmpty) {
                  ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(
                    content: Text('يرجى ملء العنوان والمحتوى',
                        style: TextStyle(fontFamily: 'Cairo')),
                  ));
                  return;
                }
                final store = AppDataStore.instance;
                final user = store.currentUser!;
                store.addAnnouncement(AnnouncementModel(
                  id: 'ann_${DateTime.now().millisecondsSinceEpoch}',
                  title: titleCtrl.text.trim(),
                  content: contentCtrl.text.trim(),
                  type: selectedType,
                  createdAt: DateTime.now(),
                  eventDate: eventDate,
                  createdBy: user.id,
                  createdByName: user.name,
                  isPinned: isPinned,
                ));
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text('✅ تم نشر الإعلان بنجاح',
                      style: TextStyle(fontFamily: 'Cairo')),
                  backgroundColor: Color(AppColors.primaryGreen),
                ));
              },
            ),
          ],
        ),
      ),
    );
  }
}
