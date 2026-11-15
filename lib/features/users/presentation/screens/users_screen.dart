import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_enums.dart';
import '../../../../core/services/app_data_store.dart';
import '../../../../data/models/user_model.dart';
import '../../../../data/models/circle_model.dart';

/// شاشة إدارة المستخدمين والمدرسين وكلمات المرور وقواعد الأمان للمدير
class UsersScreen extends ConsumerStatefulWidget {
  const UsersScreen({super.key});

  @override
  ConsumerState<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends ConsumerState<UsersScreen> {
  String _selectedRoleFilter = 'all'; // all, teacher, supervisor, admin
  String _searchQuery = '';
  final Set<String> _revealedPasswordUserIds = {}; // تتبع المستخدمين المعروضة كلمات مرورهم

  @override
  void initState() {
    super.initState();
    // مزامنة المدرسين من الحلقات تلقائياً لضمان عدم ضياع أي مدرس
    WidgetsBinding.instance.addPostFrameCallback((_) {
      AppDataStore.instance.syncTeachersFromCircles();
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    // الاستماع لمخزن البيانات
    ref.watch(appDataStoreProvider);
    final store = AppDataStore.instance;

    final allUsers = store.users;
    final teachersCount = allUsers.where((u) => u.role == UserRole.teacher).length;
    final supervisorsCount = allUsers.where((u) => u.role == UserRole.supervisor).length;

    // تصفية المستخدمين
    final filteredUsers = allUsers.where((u) {
      if (_selectedRoleFilter == 'teacher' && u.role != UserRole.teacher) return false;
      if (_selectedRoleFilter == 'supervisor' && u.role != UserRole.supervisor) return false;
      if (_selectedRoleFilter == 'admin' && u.role != UserRole.admin) return false;

      if (_searchQuery.trim().isNotEmpty) {
        final query = _searchQuery.trim().toLowerCase();
        final nameMatch = u.name.toLowerCase().contains(query);
        final phoneMatch = (u.phone ?? '').contains(query);
        final emailMatch = u.email.toLowerCase().contains(query);
        return nameMatch || phoneMatch || emailMatch;
      }
      return true;
    }).toList();

    return Scaffold(
      backgroundColor: const Color(AppColors.offWhite),
      appBar: AppBar(
        title: const Text(
          'إدارة المدرسين وقواعد الأمان',
          style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.shield_outlined),
            tooltip: 'قواعد الأمان والسياسات',
            onPressed: () => _showSecurityPoliciesDialog(context),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'تحديث ومزامنة',
            onPressed: () {
              store.syncTeachersFromCircles();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('تمت مزامنة بيانات المدرسين والحلقات بنجاح', style: TextStyle(fontFamily: 'Cairo')),
                  duration: Duration(seconds: 2),
                ),
              );
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddTeacherDialog(context),
        backgroundColor: const Color(AppColors.primaryGreen),
        icon: const Icon(Icons.person_add_alt_1, color: Colors.white),
        label: const Text(
          'إضافة مدرس / مستخدم',
          style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
      body: Column(
        children: [
          // لوحة المؤشرات والإحصائيات العلوية الفاخرة
          _buildStatsHeader(allUsers.length, teachersCount, supervisorsCount, store.circles.length),

          // شريط البحث والتصفية
          _buildSearchAndFilterBar(),

          // قائمة المستخدمين والمدرسين
          Expanded(
            child: filteredUsers.isEmpty
                ? _buildEmptyState(context)
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: filteredUsers.length,
                    itemBuilder: (context, index) {
                      final user = filteredUsers[index];
                      return _buildUserCard(context, user, store);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  // =================== بطاقة رأسية للمؤشرات ===================
  Widget _buildStatsHeader(int totalUsers, int teachers, int supervisors, int circlesCount) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(AppColors.primaryGreenDark),
            Color(AppColors.primaryGreen),
          ],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Color(AppColors.primaryGreenDark).withOpacity(0.25),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(AppColors.gold).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.verified_user, color: Color(AppColors.gold), size: 24),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'منظومة الأمان والتحكم بالصلاحيات',
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'رؤية كلمات المرور وتعديلها وفق المعايير الأمنية المعتمدة',
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 11,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(AppColors.gold).withOpacity(0.25),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(AppColors.gold).withOpacity(0.5)),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.lock, size: 12, color: Color(AppColors.gold)),
                    SizedBox(width: 4),
                    Text(
                      'مشفر ومحمي',
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Color(AppColors.goldLight),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(color: Colors.white24, height: 1),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem('المدرسون', teachers.toString(), Icons.school_outlined),
              _buildStatDivider(),
              _buildStatItem('الحلقات', circlesCount.toString(), Icons.auto_stories_outlined),
              _buildStatDivider(),
              _buildStatItem('المشرفون', supervisors.toString(), Icons.supervisor_account_outlined),
              _buildStatDivider(),
              _buildStatItem('إجمالي الحسابات', totalUsers.toString(), Icons.badge_outlined),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: const Color(AppColors.goldLight)),
            const SizedBox(width: 4),
            Text(
              value,
              style: const TextStyle(
                fontFamily: 'Cairo',
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.white,
              ),
            ),
          ],
        ),
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Cairo',
            fontSize: 10,
            color: Colors.white70,
          ),
        ),
      ],
    );
  }

  Widget _buildStatDivider() {
    return Container(
      width: 1,
      height: 24,
      color: Colors.white24,
    );
  }

  // =================== شريط البحث والتصفية ===================
  Widget _buildSearchAndFilterBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Column(
        children: [
          // حقل البحث
          TextField(
            onChanged: (val) => setState(() => _searchQuery = val),
            decoration: InputDecoration(
              hintText: 'ابحث عن مدرس بالاسم أو الهاتف أو البريد...',
              hintStyle: const TextStyle(fontFamily: 'Cairo', fontSize: 12),
              prefixIcon: const Icon(Icons.search, color: Color(AppColors.primaryGreen)),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, size: 18),
                      onPressed: () => setState(() => _searchQuery = ''),
                    )
                  : null,
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade200),
              ),
            ),
          ),
          const SizedBox(height: 8),

          // رقائق التصفية (Chips)
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip('الكل', 'all'),
                const SizedBox(width: 8),
                _buildFilterChip('المدرسون فقط', 'teacher'),
                const SizedBox(width: 8),
                _buildFilterChip('المشرفون', 'supervisor'),
                const SizedBox(width: 8),
                _buildFilterChip('الإدارة العامة', 'admin'),
              ],
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _selectedRoleFilter == value;
    return ChoiceChip(
      label: Text(
        label,
        style: TextStyle(
          fontFamily: 'Cairo',
          fontSize: 11,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: isSelected ? Colors.white : Colors.black87,
        ),
      ),
      selected: isSelected,
      selectedColor: const Color(AppColors.primaryGreen),
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: isSelected ? const Color(AppColors.primaryGreen) : Colors.grey.shade300,
        ),
      ),
      onSelected: (_) => setState(() => _selectedRoleFilter = value),
    );
  }

  // =================== بطاقة المدرس / المستخدم ===================
  Widget _buildUserCard(BuildContext context, UserModel user, AppDataStore store) {
    final isRevealed = _revealedPasswordUserIds.contains(user.id);
    final isTeacher = user.role == UserRole.teacher;
    final isAdmin = user.role == UserRole.admin;

    // الحصول على حلقات المعلم إن وجدت
    final userCircles = store.circles.where((c) {
      return user.assignedCircleIds.contains(c.id) ||
          c.teacherId == user.id ||
          (user.name.trim().isNotEmpty && c.teacherName.trim() == user.name.trim());
    }).toList();

    // استخراج كلمة المرور (إما من المستخدم أو من حلقته الأولى)
    String effectivePassword = user.password ?? '';
    if (effectivePassword.isEmpty && userCircles.isNotEmpty) {
      effectivePassword = userCircles.first.accessPassword;
    }
    if (effectivePassword.isEmpty) {
      effectivePassword = 'غير محددة';
    }

    // لون الدور
    Color roleColor = const Color(AppColors.info);
    String roleLabel = 'معلم حلقة';
    if (isAdmin) {
      roleColor = const Color(AppColors.primaryGreenDark);
      roleLabel = 'مدير عام';
    } else if (user.role == UserRole.supervisor) {
      roleColor = const Color(AppColors.goldDark);
      roleLabel = 'مشرف تعليمي';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isTeacher ? const Color(AppColors.gold).withOpacity(0.3) : Colors.grey.shade200,
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ترويسة البطاقة: الصورة، الاسم، الدور
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: roleColor.withOpacity(0.12),
                  child: Text(
                    user.name.isNotEmpty ? user.name[0] : '؟',
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: roleColor,
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
                              user.name,
                              style: const TextStyle(
                                fontFamily: 'Cairo',
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: Color(AppColors.grey900),
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: roleColor.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              roleLabel,
                              style: TextStyle(
                                fontFamily: 'Cairo',
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: roleColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      if (user.phone != null && user.phone!.isNotEmpty)
                        Row(
                          children: [
                            const Icon(Icons.phone_android, size: 12, color: Colors.grey),
                            const SizedBox(width: 4),
                            Text(
                              user.phone!,
                              style: const TextStyle(
                                fontFamily: 'Cairo',
                                fontSize: 11,
                                color: Colors.black54,
                              ),
                              textDirection: TextDirection.ltr,
                            ),
                          ],
                        ),
                      if (user.email.isNotEmpty)
                        Text(
                          user.email,
                          style: const TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 11,
                            color: Colors.black45,
                          ),
                          textDirection: TextDirection.ltr,
                        ),
                    ],
                  ),
                ),
              ],
            ),

            // الحلقات المرتبطة بهذا المعلم
            if (userCircles.isNotEmpty) ...[
              const SizedBox(height: 10),
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: userCircles.map((circle) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(AppColors.gold).withOpacity(0.12),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(AppColors.gold).withOpacity(0.4)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.auto_stories, size: 11, color: Color(AppColors.goldDark)),
                        const SizedBox(width: 4),
                        Text(
                          '${circle.name} (${circle.circleCode})',
                          style: const TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Color(AppColors.goldDark),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ],

            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 12),

            // ===== قسم كلمة المرور وقواعد الأمان للمدير =====
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFF9FBF9),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: const Color(AppColors.primaryGreen).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.key, size: 16, color: Color(AppColors.primaryGreen)),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'كلمة المرور المسجلة:',
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 10,
                            color: Colors.black54,
                          ),
                        ),
                        const SizedBox(height: 1),
                        Text(
                          isRevealed ? effectivePassword : '••••••••••••',
                          style: TextStyle(
                            fontFamily: isRevealed ? 'Courier' : 'Cairo',
                            fontWeight: FontWeight.bold,
                            fontSize: isRevealed ? 15 : 12,
                            letterSpacing: isRevealed ? 2 : 1,
                            color: const Color(AppColors.primaryGreenDark),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // زر إظهار / إخفاء كلمة المرور
                  IconButton(
                    icon: Icon(
                      isRevealed ? Icons.visibility_off : Icons.visibility,
                      size: 20,
                      color: isRevealed ? const Color(AppColors.primaryGreen) : Colors.grey,
                    ),
                    tooltip: isRevealed ? 'إخفاء كلمة المرور' : 'إظهار كلمة المرور للمدير',
                    onPressed: () {
                      setState(() {
                        if (isRevealed) {
                          _revealedPasswordUserIds.remove(user.id);
                        } else {
                          _revealedPasswordUserIds.add(user.id);
                        }
                      });
                    },
                  ),

                  // زر نسخ كلمة المرور
                  IconButton(
                    icon: const Icon(Icons.copy, size: 18, color: Colors.grey),
                    tooltip: 'نسخ كلمة المرور للحافظة',
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: effectivePassword));
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('تم نسخ كلمة مرور ${user.name} بنجاح', style: const TextStyle(fontFamily: 'Cairo')),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),

            // أزرار الإجراءات: تعديل كلمة المرور + إرسال عبر واتساب
            Row(
              children: [
                // زر تعديل كلمة المرور وقواعد الأمان
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(AppColors.primaryGreen),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    icon: const Icon(Icons.security_update_good, size: 16),
                    label: const Text(
                      'تعديل وفق قواعد الأمان',
                      style: TextStyle(fontFamily: 'Cairo', fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                    onPressed: () => _showEditPasswordDialog(context, user, effectivePassword, userCircles),
                  ),
                ),
                const SizedBox(width: 8),

                // زر إرسال عبر واتساب
                if (user.phone != null && user.phone!.isNotEmpty)
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF25D366),
                      side: const BorderSide(color: Color(0xFF25D366)),
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    icon: const Icon(Icons.share, size: 16),
                    label: const Text(
                      'إرسال واتساب',
                      style: TextStyle(fontFamily: 'Cairo', fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                    onPressed: () => _shareViaWhatsApp(user, effectivePassword, userCircles),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // =================== نافذة تعديل كلمة المرور وقواعد الأمان ===================
  void _showEditPasswordDialog(
    BuildContext context,
    UserModel user,
    String currentPassword,
    List<CircleModel> userCircles,
  ) {
    final passwordController = TextEditingController(text: currentPassword);
    bool obscure = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (dialogCtx, setModalState) {
            final pass = passwordController.text;

            // حساب قواعد الأمان
            final hasMinLength = pass.length >= 6;
            final hasLetter = RegExp(r'[a-zA-Z\u0621-\u064A]').hasMatch(pass);
            final hasDigit = RegExp(r'[0-9]').hasMatch(pass);
            final hasSpecial = RegExp(r'[!@#\$%^&*(),.?":{}|<>_\-]').hasMatch(pass);

            // قوة كلمة المرور
            int strengthScore = 0;
            if (hasMinLength) strengthScore++;
            if (hasLetter) strengthScore++;
            if (hasDigit) strengthScore++;
            if (hasSpecial) strengthScore++;

            String strengthText = 'ضعيفة جداً';
            Color strengthColor = const Color(AppColors.error);
            double progress = 0.25;

            if (strengthScore == 2) {
              strengthText = 'مقبولة';
              strengthColor = Colors.orange;
              progress = 0.5;
            } else if (strengthScore == 3) {
              strengthText = 'قوية وآمنة';
              strengthColor = Colors.lightGreen;
              progress = 0.75;
            } else if (strengthScore >= 4) {
              strengthText = 'ممتازة وفائقة الأمان';
              strengthColor = const Color(AppColors.primaryGreen);
              progress = 1.0;
            }

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
                    // شريط إغلاق علوي
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // عنوان النافذة
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(AppColors.gold).withOpacity(0.15),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.security, color: Color(AppColors.goldDark), size: 24),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'تعديل كلمة مرور: ${user.name}',
                                style: const TextStyle(
                                  fontFamily: 'Cairo',
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: Color(AppColors.primaryGreenDark),
                                ),
                              ),
                              const Text(
                                'تطبيق قواعد الأمان المعتمدة لمنصة الريان',
                                style: TextStyle(fontFamily: 'Cairo', fontSize: 11, color: Colors.black54),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // حقل إدخال كلمة المرور مع زر توليد كلمة قوية
                    Row(
                      children: [
                        const Text(
                          'كلمة المرور الجديدة',
                          style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                        const Spacer(),
                        TextButton.icon(
                          onPressed: () {
                            final generated = _generateStrongPassword();
                            passwordController.text = generated;
                            setModalState(() {});
                          },
                          icon: const Icon(Icons.auto_awesome, size: 14, color: Color(AppColors.goldDark)),
                          label: const Text(
                            'توليد كلمة قوية تلقائياً',
                            style: TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Color(AppColors.goldDark),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),

                    TextField(
                      controller: passwordController,
                      obscureText: obscure,
                      onChanged: (_) => setModalState(() {}),
                      style: const TextStyle(
                        fontFamily: 'Courier',
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                      ),
                      decoration: InputDecoration(
                        hintText: 'أدخل كلمة المرور الجديدة',
                        prefixIcon: const Icon(Icons.lock_outline, color: Color(AppColors.primaryGreen)),
                        suffixIcon: IconButton(
                          icon: Icon(obscure ? Icons.visibility_off : Icons.visibility),
                          onPressed: () => setModalState(() => obscure = !obscure),
                        ),
                        filled: true,
                        fillColor: const Color(0xFFF9FBF9),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // مقياس قوة كلمة المرور
                    Row(
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: progress,
                              backgroundColor: Colors.grey.shade200,
                              valueColor: AlwaysStoppedAnimation<Color>(strengthColor),
                              minHeight: 6,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          strengthText,
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: strengthColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // معايير وقواعد الأمان Checklist
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'قواعد الأمان الإلزامية للمنظومة:',
                            style: TextStyle(
                              fontFamily: 'Cairo',
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                              color: Color(AppColors.primaryGreenDark),
                            ),
                          ),
                          const SizedBox(height: 8),
                          _buildRuleCheckItem('طول كلمة المرور 6 خانات على الأقل', hasMinLength),
                          _buildRuleCheckItem('تحتوي على حروف أبجدية', hasLetter),
                          _buildRuleCheckItem('تحتوي على أرقام (0-9)', hasDigit),
                          _buildRuleCheckItem('تحتوي على رمز خاص أو صيغة النظام (RYN-...)', hasSpecial),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),

                    if (userCircles.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(AppColors.gold).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(AppColors.gold).withOpacity(0.3)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.info_outline, size: 16, color: Color(AppColors.goldDark)),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'تنبيه: سيتم تلقائياً تحديث رمز الدخول للحلقات المرتبطة: ${userCircles.map((c) => c.name).join('، ')}.',
                                style: const TextStyle(fontFamily: 'Cairo', fontSize: 10, color: Color(AppColors.goldDark)),
                              ),
                            ),
                          ],
                        ),
                      ),
                    const SizedBox(height: 20),

                    // زر حفظ وتأكيد
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(AppColors.primaryGreen),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        icon: const Icon(Icons.save),
                        label: const Text(
                          'اعتماد وحفظ كلمة المرور الجديدة',
                          style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                        onPressed: () {
                          final newPass = passwordController.text.trim();
                          if (newPass.length < 6) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('يجب ألا تقل كلمة المرور عن 6 خانات وفق قواعد الأمان', style: TextStyle(fontFamily: 'Cairo')),
                                backgroundColor: Color(AppColors.error),
                              ),
                            );
                            return;
                          }

                          // تحديث في مخزن البيانات
                          AppDataStore.instance.updateUserPassword(user.id, newPass);

                          Navigator.pop(ctx);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('تم تحديث كلمة المرور لـ (${user.name}) بنجاح ومزامنة الحلقات', style: const TextStyle(fontFamily: 'Cairo')),
                              backgroundColor: const Color(AppColors.primaryGreen),
                              action: user.phone != null && user.phone!.isNotEmpty
                                  ? SnackBarAction(
                                      label: 'إرسال عبر واتساب',
                                      textColor: Colors.white,
                                      onPressed: () => _shareViaWhatsApp(user, newPass, userCircles),
                                    )
                                  : null,
                            ),
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

  Widget _buildRuleCheckItem(String label, bool isSatisfied) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Icon(
            isSatisfied ? Icons.check_circle : Icons.radio_button_unchecked,
            size: 16,
            color: isSatisfied ? const Color(AppColors.primaryGreen) : Colors.grey,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 11,
                color: isSatisfied ? Colors.black87 : Colors.grey,
                fontWeight: isSatisfied ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // =================== توليد كلمة مرور قوية تلقائياً ===================
  String _generateStrongPassword() {
    final random = Random();
    const letters = 'ABCDEFGHJKLMNPQRSTUVWXYZ';
    const numbers = '23456789';
    const symbols = '!@#*';

    final part1 = List.generate(3, (_) => letters[random.nextInt(letters.length)]).join();
    final part2 = List.generate(3, (_) => numbers[random.nextInt(numbers.length)]).join();
    final sym = symbols[random.nextInt(symbols.length)];

    return 'RYN-$part1$sym$part2';
  }

  // =================== مشاركة كلمة المرور مع المدرس عبر واتساب ===================
  void _shareViaWhatsApp(UserModel user, String password, List<CircleModel> userCircles) async {
    final phone = (user.phone ?? '').replaceAll(RegExp(r'[^0-9]'), '');
    final circleInfo = userCircles.isNotEmpty
        ? 'حلقة: ${userCircles.first.name} (رمز: ${userCircles.first.circleCode})'
        : 'منظومة حلقات الريان';

    final text = 'السلام عليكم ورحمة الله وبركاته يا أستاذ ${user.name} 🌿\n\n'
        'بيانات حسابكم في منصة الريان لإدارة الحلقات القرآنية (مسجد الريان - تريم دمون):\n'
        '• الدور: معلم حلقة\n'
        '• $circleInfo\n'
        '• اسم المستخدم: ${user.name} أو ${user.email}\n'
        '• كلمة المرور الخاصة بكم: $password\n\n'
        'يمكنكم الدخول عبر شاشة المعلم برمز الحلقة أو البريد وكلمة المرور أعلاه.\n'
        'وفقكم الله وسدد خطاكم.';

    final uri = Uri.parse('https://wa.me/$phone?text=${Uri.encodeComponent(text)}');
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      if (mounted) {
        Clipboard.setData(ClipboardData(text: text));
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم نسخ نص الرسالة للحافظة لتعذر فتح واتساب تلقائياً', style: TextStyle(fontFamily: 'Cairo')),
          ),
        );
      }
    }
  }

  // =================== إضافة مدرس / مستخدم جديد ===================
  void _showAddTeacherDialog(BuildContext context) {
    final nameController = TextEditingController();
    final phoneController = TextEditingController();
    final emailController = TextEditingController();
    final passwordController = TextEditingController(text: _generateStrongPassword());
    UserRole selectedRole = UserRole.teacher;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (dialogCtx, setModalState) {
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
                    const Row(
                      children: [
                        Icon(Icons.person_add_alt_1, color: Color(AppColors.primaryGreen)),
                        SizedBox(width: 8),
                        Text(
                          'إضافة كادر تعليمي / إداري جديد',
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Color(AppColors.primaryGreenDark),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: 'اسم المدرس / المشرف كاملاً',
                        prefixIcon: Icon(Icons.person_outline),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),

                    TextField(
                      controller: phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        labelText: 'رقم الهاتف (واتساب)',
                        prefixIcon: Icon(Icons.phone_outlined),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),

                    TextField(
                      controller: emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: 'البريد الإلكتروني (اختياري)',
                        prefixIcon: Icon(Icons.email_outlined),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // اختيار الدور
                    DropdownButtonFormField<UserRole>(
                      initialValue: selectedRole,
                      decoration: const InputDecoration(
                        labelText: 'الدور الصلاحياتي',
                        prefixIcon: Icon(Icons.badge_outlined),
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: UserRole.teacher,
                          child: Text('معلم حلقة قرآنية', style: TextStyle(fontFamily: 'Cairo')),
                        ),
                        DropdownMenuItem(
                          value: UserRole.supervisor,
                          child: Text('مشرف تعليمي', style: TextStyle(fontFamily: 'Cairo')),
                        ),
                        DropdownMenuItem(
                          value: UserRole.admin,
                          child: Text('نائب مدير / إدارة', style: TextStyle(fontFamily: 'Cairo')),
                        ),
                      ],
                      onChanged: (val) {
                        if (val != null) setModalState(() => selectedRole = val);
                      },
                    ),
                    const SizedBox(height: 12),

                    // حقل كلمة المرور مع زر التوليد
                    Row(
                      children: [
                        const Text(
                          'كلمة المرور المحددة:',
                          style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                        const Spacer(),
                        TextButton.icon(
                          onPressed: () {
                            passwordController.text = _generateStrongPassword();
                            setModalState(() {});
                          },
                          icon: const Icon(Icons.refresh, size: 14),
                          label: const Text('توليد أخرى', style: TextStyle(fontFamily: 'Cairo', fontSize: 11)),
                        ),
                      ],
                    ),
                    TextField(
                      controller: passwordController,
                      style: const TextStyle(fontFamily: 'Courier', fontWeight: FontWeight.bold, letterSpacing: 1.5),
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.lock_outline),
                        border: OutlineInputBorder(),
                        filled: true,
                        fillColor: Color(0xFFF9FBF9),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // زر الإنشاء
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(AppColors.primaryGreen),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        icon: const Icon(Icons.check_circle_outline),
                        label: const Text(
                          'حفظ وإنشاء الحساب في المنظومة',
                          style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                        onPressed: () {
                          final name = nameController.text.trim();
                          if (name.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('يرجى كتابة اسم المدرس', style: TextStyle(fontFamily: 'Cairo'))),
                            );
                            return;
                          }

                          final phone = phoneController.text.trim();
                          final email = emailController.text.trim().isNotEmpty
                              ? emailController.text.trim()
                              : 'user_${DateTime.now().millisecondsSinceEpoch}@alrayyan.com';
                          final password = passwordController.text.trim();

                          final newUser = UserModel(
                            id: 'usr_${DateTime.now().millisecondsSinceEpoch}',
                            name: name,
                            phone: phone,
                            email: email,
                            role: selectedRole,
                            password: password,
                            createdAt: DateTime.now(),
                          );

                          AppDataStore.instance.addUser(newUser);

                          Navigator.pop(ctx);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('تمت إضافة ($name) بنجاح ويمكنه الآن تسجيل الدخول', style: const TextStyle(fontFamily: 'Cairo')),
                              backgroundColor: const Color(AppColors.primaryGreen),
                            ),
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

  // =================== نافذة قواعد الأمان وسياسات المنظومة ===================
  void _showSecurityPoliciesDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Row(
            children: [
              Icon(Icons.shield, color: Color(AppColors.goldDark)),
              SizedBox(width: 8),
              Text(
                'سياسات وقواعد الأمان',
                style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildPolicyItem(
                  'صلاحيات المدير العام',
                  'المدير العام يمتلك حق الوصول الكامل لجميع السجلات، الحلقات، ورؤية وتحديث كلمات مرور المعلمين لضمان استمرارية العمل عند نسيانها.',
                  Icons.admin_panel_settings_outlined,
                ),
                const SizedBox(height: 12),
                _buildPolicyItem(
                  'قواعد تعقيد كلمة المرور',
                  'يجب ألا تقل كلمات المرور عن 6 أحرف/أرقام، ويفضل أن تبدأ برمز النظام المعتمد RYN- لتفادي التخمين.',
                  Icons.password_outlined,
                ),
                const SizedBox(height: 12),
                _buildPolicyItem(
                  'عزل صلاحيات المعلم',
                  'المعلم لا يمكنه الاطلاع على أداء المعلمين الآخرين أو تعديل قرارات الإدارة العامة أو تغيير أسعار الرسوم.',
                  Icons.lock_person_outlined,
                ),
                const SizedBox(height: 12),
                _buildPolicyItem(
                  'خصوصية أولياء الأمور والطلاب',
                  'تسجيل دخول أولياء الأمور برقم الهاتف المعتمد فقط لضمان سهولة الوصول وحماية خصوصية الأبناء.',
                  Icons.family_restroom_outlined,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('إغلاق', style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  Widget _buildPolicyItem(String title, String desc, IconData icon) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: const Color(AppColors.primaryGreen).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 18, color: const Color(AppColors.primaryGreenDark)),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold, fontSize: 12)),
              const SizedBox(height: 2),
              Text(desc, style: const TextStyle(fontFamily: 'Cairo', fontSize: 11, color: Colors.black54)),
            ],
          ),
        ),
      ],
    );
  }

  // =================== حالة خلو القائمة ===================
  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(AppColors.gold).withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.people_outline, size: 48, color: Color(AppColors.goldDark)),
            ),
            const SizedBox(height: 16),
            const Text(
              'لا يوجد مدرسون مطابقون لبحثك حالياً',
              style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold, fontSize: 15),
            ),
            const SizedBox(height: 6),
            const Text(
              'يمكنك إضافة مدرس جديد من الصفر أو إنشاء حلقة جديدة وتعيين مدرسها',
              textAlign: TextAlign.center,
              style: TextStyle(fontFamily: 'Cairo', fontSize: 12, color: Colors.black54),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(AppColors.primaryGreen),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              icon: const Icon(Icons.person_add),
              label: const Text('إضافة مدرس الآن', style: TextStyle(fontFamily: 'Cairo')),
              onPressed: () => _showAddTeacherDialog(context),
            ),
          ],
        ),
      ),
    );
  }
}
