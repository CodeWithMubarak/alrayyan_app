import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_enums.dart';
import '../../../../core/services/app_data_store.dart';
import '../../../../core/services/export_service.dart';
import '../../../../core/widgets/stat_card.dart';
import '../../../../data/models/fee_model.dart';

/// شاشة الإدارة المالية المتكاملة: الرسوم الشهرية، الرحلات، الأنشطة، وتصدير Excel و PDF
class FeesScreen extends ConsumerStatefulWidget {
  const FeesScreen({super.key});

  @override
  ConsumerState<FeesScreen> createState() => _FeesScreenState();
}

class _FeesScreenState extends ConsumerState<FeesScreen> {
  String _selectedFilter = 'all'; // all, monthly, trip, paid, unpaid
  double _defaultMonthlyFee = 5000.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F6),
      appBar: AppBar(
        title: const Text('الإدارة المالية والرحلات', style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.table_view_outlined),
            tooltip: 'تصدير السجل المالي إلى Excel (.xlsx)',
            onPressed: () => _exportToExcel(context),
          ),
          IconButton(
            icon: const Icon(Icons.print_outlined),
            tooltip: 'طباعة كشف الحساب المالي العام (PDF)',
            onPressed: () => _printFinancialReport(context),
          ),
          IconButton(
            icon: const Icon(Icons.tune),
            tooltip: 'تحديد مقدار الرسوم الشهرية للمسجد',
            onPressed: () => _showSetDefaultFeeDialog(context),
          ),
        ],
      ),
      body: ListenableBuilder(
        listenable: AppDataStore.instance,
        builder: (context, _) {
          final store = AppDataStore.instance;
          final allFees = store.fees;

          final totalDue = allFees.fold(0.0, (sum, f) => sum + f.amountDue);
          final totalPaid = allFees.fold(0.0, (sum, f) => sum + f.amountPaid);
          final remaining = (totalDue - totalPaid).clamp(0.0, totalDue);

          // تصفية السجلات
          final filtered = allFees.where((f) {
            final isTrip = (f.notes ?? '').contains('رحلة') || (f.notes ?? '').contains('نشاط') || (f.notes ?? '').contains('مسابقة');
            if (_selectedFilter == 'monthly' && isTrip) return false;
            if (_selectedFilter == 'trip' && !isTrip) return false;
            if (_selectedFilter == 'paid' && f.status != FeeStatus.paid) return false;
            if (_selectedFilter == 'unpaid' && f.status == FeeStatus.paid) return false;
            return true;
          }).toList();

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // لوحة المؤشرات المالية
                Row(
                  children: [
                    Expanded(
                      child: StatCard(
                        icon: Icons.payments_outlined,
                        title: 'إجمالي المبالغ المطلوبة',
                        value: '${totalDue.toInt()} ر.ي',
                        color: const Color(AppColors.warning),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: StatCard(
                        icon: Icons.check_circle_outline,
                        title: 'المحصل الفعلي بالخزينة',
                        value: '${totalPaid.toInt()} ر.ي',
                        color: const Color(AppColors.success),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: StatCard(
                        icon: Icons.hourglass_empty,
                        title: 'المتبقي غير المحصل',
                        value: '${remaining.toInt()} ر.ي',
                        color: const Color(AppColors.error),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: StatCard(
                        icon: Icons.settings_suggest,
                        title: 'الاشتراك الشهري المعتمد',
                        value: '${_defaultMonthlyFee.toInt()} ر.ي',
                        color: const Color(AppColors.primaryGreen),
                        subtitle: 'محدد من المدير',
                        onTap: () => _showSetDefaultFeeDialog(context),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // شريط أزرار العمليات الإدارية السريعة
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(AppColors.primaryGreen),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        icon: const Icon(Icons.receipt_long, size: 16),
                        label: const Text('سند اشتراك شهري', style: TextStyle(fontFamily: 'Cairo', fontSize: 11, fontWeight: FontWeight.bold)),
                        onPressed: () => _showAddPaymentSheet(context, isTrip: false),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(AppColors.goldDark),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        icon: const Icon(Icons.directions_bus, size: 16),
                        label: const Text('مساهمة رحلة / نشاط', style: TextStyle(fontFamily: 'Cairo', fontSize: 11, fontWeight: FontWeight.bold)),
                        onPressed: () => _showAddPaymentSheet(context, isTrip: true),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // رقائق التصفية
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFilterChip('الكل (${allFees.length})', 'all'),
                      const SizedBox(width: 6),
                      _buildFilterChip('الرسوم الشهرية', 'monthly'),
                      const SizedBox(width: 6),
                      _buildFilterChip('الرحلات والأنشطة 🚌', 'trip'),
                      const SizedBox(width: 6),
                      _buildFilterChip('مسدد بالكامل ✅', 'paid'),
                      const SizedBox(width: 6),
                      _buildFilterChip('متبقي ومتأخر ⚠️', 'unpaid'),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'سجل العمليات المالية وسندات القبض',
                      style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    Text(
                      '(${filtered.length} سند مسجل)',
                      style: TextStyle(fontFamily: 'Cairo', fontSize: 11, color: Colors.grey.shade600),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                if (filtered.isEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Column(
                      children: [
                        const Icon(Icons.account_balance_wallet_outlined, size: 48, color: Colors.grey),
                        const SizedBox(height: 12),
                        const Text(
                          'لا توجد سندات مالية مسجلة في هذا القسم حالياً',
                          style: TextStyle(fontFamily: 'Cairo', fontSize: 13, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'يمكن للمدير تسجيل اشتراك شهري أو مساهمة لرحلة أو نشاط بضغطة زر أعلاه.',
                          style: TextStyle(fontFamily: 'Cairo', fontSize: 11, color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                  )
                else
                  ...filtered.map((fee) => _buildFeeTile(fee)),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddPaymentSheet(context, isTrip: false),
        backgroundColor: const Color(AppColors.primaryGreen),
        icon: const Icon(Icons.add_card, color: Colors.white),
        label: const Text('سند قبض جديد', style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold, color: Colors.white)),
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _selectedFilter == value;
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
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: isSelected ? const Color(AppColors.primaryGreen) : Colors.grey.shade300),
      ),
      onSelected: (_) => setState(() => _selectedFilter = value),
    );
  }

  Widget _buildFeeTile(FeeModel fee) {
    final isTrip = (fee.notes ?? '').contains('رحلة') || (fee.notes ?? '').contains('نشاط') || (fee.notes ?? '').contains('مسابقة');
    Color color;
    String statusName;
    if (fee.status == FeeStatus.paid) {
      color = const Color(AppColors.success);
      statusName = 'مسدد بالكامل';
    } else if (fee.status == FeeStatus.partial) {
      color = const Color(AppColors.warning);
      statusName = 'مسدد جزئياً';
    } else {
      color = const Color(AppColors.error);
      statusName = 'غير مسدد';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: isTrip ? const Color(AppColors.gold).withOpacity(0.4) : Colors.grey.shade200),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 6, offset: const Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: (isTrip ? const Color(AppColors.goldDark) : color).withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isTrip ? Icons.directions_bus : Icons.receipt_long,
              color: isTrip ? const Color(AppColors.goldDark) : color,
              size: 20,
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
                        fee.studentName,
                        style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                    ),
                    if (isTrip)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(AppColors.gold).withOpacity(0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          'رحلة / نشاط',
                          style: TextStyle(fontFamily: 'Cairo', fontSize: 9, fontWeight: FontWeight.bold, color: Color(AppColors.goldDark)),
                        ),
                      ),
                  ],
                ),
                Text(
                  fee.notes != null && fee.notes!.isNotEmpty ? fee.notes! : 'رسوم اشتراك شهر ${fee.month}/${fee.year}',
                  style: TextStyle(fontFamily: 'Cairo', fontSize: 11, color: Colors.grey.shade700),
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    Text(
                      'المدفوع: ${fee.amountPaid.toInt()} ر.ي',
                      style: TextStyle(fontFamily: 'Cairo', fontSize: 11, fontWeight: FontWeight.bold, color: color),
                    ),
                    if (fee.amountRemaining > 0) ...[
                      const SizedBox(width: 8),
                      Text(
                        'المتبقي: ${fee.amountRemaining.toInt()} ر.ي',
                        style: const TextStyle(fontFamily: 'Cairo', fontSize: 11, color: Color(AppColors.error)),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  statusName,
                  style: TextStyle(fontFamily: 'Cairo', fontSize: 10, fontWeight: FontWeight.bold, color: color),
                ),
              ),
              const SizedBox(height: 4),
              IconButton(
                icon: const Icon(Icons.print, size: 20, color: Color(AppColors.primaryGreen)),
                tooltip: 'طباعة سند القبض الرسمي (PDF)',
                onPressed: () => ExportService.instance.printReceiptPdf(fee),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // =================== نافذة تحديد مقدار الرسوم الشهرية للمسجد ===================
  void _showSetDefaultFeeDialog(BuildContext context) {
    final controller = TextEditingController(text: _defaultMonthlyFee.toInt().toString());
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.tune, color: Color(AppColors.primaryGreen)),
            SizedBox(width: 8),
            Text('تحديد الرسوم الشهرية المعتمدة', style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold, fontSize: 15)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'يستطيع المدير العام هنا تقدير وتحديد قيمة الاشتراك الشهري لجميع الطلاب بالحلقات:',
              style: TextStyle(fontFamily: 'Cairo', fontSize: 12, color: Colors.black54),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'المبلغ الشهري للطالب (ريال يمني)',
                suffixText: 'ر.ي',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('إلغاء', style: TextStyle(fontFamily: 'Cairo')),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(AppColors.primaryGreen)),
            onPressed: () {
              final newFee = double.tryParse(controller.text) ?? _defaultMonthlyFee;
              setState(() => _defaultMonthlyFee = newFee);
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('تم اعتماد الرسم الشهري: ${newFee.toInt()} ريال يمني بنجاح', style: const TextStyle(fontFamily: 'Cairo')),
                  backgroundColor: const Color(AppColors.primaryGreen),
                ),
              );
            },
            child: const Text('اعتماد المبلغ', style: TextStyle(fontFamily: 'Cairo', color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  // =================== نافذة تسجيل سند قبض (شهري أو رحلة/نشاط) ===================
  void _showAddPaymentSheet(BuildContext context, {required bool isTrip}) {
    final students = AppDataStore.instance.students;
    if (students.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى أولاً تسجيل الطلاب في الحلقات قبل إصدار السندات المالية', style: TextStyle(fontFamily: 'Cairo'))),
      );
      return;
    }

    String selectedStudentId = students.first.id;
    final activityNameController = TextEditingController(text: isTrip ? 'رحلة وادي دوعن الترفيهية' : 'رسوم اشتراك حلقة');
    final amountDueController = TextEditingController(text: isTrip ? '3000' : _defaultMonthlyFee.toInt().toString());
    final amountPaidController = TextEditingController(text: isTrip ? '3000' : _defaultMonthlyFee.toInt().toString());
    final receiverController = TextEditingController(text: 'إدارة المسجد');
    String paymentMethod = 'نقداً';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setSheetState) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
            left: 20, right: 20, top: 20,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)))),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Icon(isTrip ? Icons.directions_bus : Icons.receipt_long, color: isTrip ? const Color(AppColors.goldDark) : const Color(AppColors.primaryGreen)),
                    const SizedBox(width: 8),
                    Text(
                      isTrip ? 'تسجيل مساهمة رحلة / نشاط للطلاب' : 'تسجيل سند اشتراك شهري',
                      style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                DropdownButtonFormField<String>(
                  initialValue: selectedStudentId,
                  decoration: const InputDecoration(labelText: 'اختر الطالب المسدد', prefixIcon: Icon(Icons.person_outline), border: OutlineInputBorder()),
                  items: students.map((s) => DropdownMenuItem(value: s.id, child: Text('${s.fullName} (${s.circleName})', style: const TextStyle(fontFamily: 'Cairo')))).toList(),
                  onChanged: (val) => setSheetState(() => selectedStudentId = val ?? selectedStudentId),
                ),
                const SizedBox(height: 12),

                TextField(
                  controller: activityNameController,
                  decoration: InputDecoration(
                    labelText: isTrip ? 'اسم الرحلة أو النشاط (مثال: رحلة بحرية، مسابقة الحفظ)' : 'بيان الرسم',
                    prefixIcon: Icon(isTrip ? Icons.local_activity_outlined : Icons.description_outlined),
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),

                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: amountDueController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'المبلغ المطلوب (ر.ي)', prefixIcon: Icon(Icons.money), border: OutlineInputBorder()),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: amountPaidController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'المبلغ المدفوع (ر.ي)', prefixIcon: Icon(Icons.payments), border: OutlineInputBorder()),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                DropdownButtonFormField<String>(
                  initialValue: paymentMethod,
                  decoration: const InputDecoration(labelText: 'طريقة السداد', prefixIcon: Icon(Icons.account_balance_wallet), border: OutlineInputBorder()),
                  items: const [
                    DropdownMenuItem(value: 'نقداً', child: Text('نقداً (كاش)', style: TextStyle(fontFamily: 'Cairo'))),
                    DropdownMenuItem(value: 'تحويل بنكي / صرافة', child: Text('تحويل بنكي / صرافة العمقي/البسيري', style: TextStyle(fontFamily: 'Cairo'))),
                    DropdownMenuItem(value: 'سداد ولي الأمر', child: Text('سداد ولي الأمر مباشرة', style: TextStyle(fontFamily: 'Cairo'))),
                  ],
                  onChanged: (val) => setSheetState(() => paymentMethod = val ?? 'نقداً'),
                ),
                const SizedBox(height: 12),

                TextField(
                  controller: receiverController,
                  decoration: const InputDecoration(labelText: 'اسم المستلم والملاحظات', prefixIcon: Icon(Icons.person_pin), border: OutlineInputBorder()),
                ),
                const SizedBox(height: 20),

                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isTrip ? const Color(AppColors.goldDark) : const Color(AppColors.primaryGreen),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    icon: const Icon(Icons.check_circle_outline),
                    label: const Text('اعتماد وحفظ السند في السجل المالي', style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold, fontSize: 13)),
                    onPressed: () {
                      final store = AppDataStore.instance;
                      final student = store.students.firstWhere((s) => s.id == selectedStudentId);
                      final due = double.tryParse(amountDueController.text) ?? _defaultMonthlyFee;
                      final paid = double.tryParse(amountPaidController.text) ?? due;

                      final newFee = FeeModel(
                        id: 'REC-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
                        studentId: student.id,
                        studentName: student.fullName,
                        circleId: student.circleId,
                        month: DateTime.now().month,
                        year: DateTime.now().year,
                        amountDue: due,
                        amountPaid: paid,
                        amountRemaining: (due - paid).clamp(0, due),
                        paymentDate: DateTime.now(),
                        paymentMethod: paymentMethod,
                        receiverName: receiverController.text.trim(),
                        notes: activityNameController.text.trim(),
                        status: paid >= due ? FeeStatus.paid : (paid > 0 ? FeeStatus.partial : FeeStatus.unpaid),
                        createdBy: 'المدير العام',
                        createdAt: DateTime.now(),
                      );

                      store.addFeePayment(newFee);
                      Navigator.pop(ctx);

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('تم تسجيل السند لـ (${student.fullName}) بنجاح', style: const TextStyle(fontFamily: 'Cairo')),
                          backgroundColor: const Color(AppColors.primaryGreen),
                          action: SnackBarAction(
                            label: 'طباعة السند',
                            textColor: Colors.white,
                            onPressed: () => ExportService.instance.printReceiptPdf(newFee),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _exportToExcel(BuildContext context) async {
    final fees = AppDataStore.instance.fees;
    if (fees.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('لا توجد سجلات مالية بعد لتصديرها كـ Excel', style: TextStyle(fontFamily: 'Cairo'))),
      );
      return;
    }
    await ExportService.instance.exportFeesToExcel(fees);
  }

  void _printFinancialReport(BuildContext context) async {
    final fees = AppDataStore.instance.fees;
    final totalDue = fees.fold(0.0, (sum, f) => sum + f.amountDue);
    final totalPaid = fees.fold(0.0, (sum, f) => sum + f.amountPaid);
    await ExportService.instance.printFinancialReportPdf(fees, totalDue, totalPaid);
  }
}
