import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_enums.dart';
import '../../../../core/services/app_data_store.dart';
import '../../../../core/services/pdf_report_service.dart';

class ReportsScreen extends ConsumerStatefulWidget {
  const ReportsScreen({super.key});

  @override
  ConsumerState<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends ConsumerState<ReportsScreen> {
  final _pdfService = PdfReportService();

  @override
  Widget build(BuildContext context) {
    final user = AppDataStore.instance.currentUser;
    final isTeacher = user?.role == UserRole.teacher;

    final allReports = [
      {
        'id': 'rep_01',
        'title': 'التقرير الشهري - شهر أكتوبر 2026',
        'circleName': 'حلقة الفجر',
        'teacherName': 'أحمد محمد الحضرمي',
        'studentsCount': 15,
        'attendanceRate': '92%',
        'memorizationCount': 45,
        'status': 'معتمد',
        'statusColor': const Color(AppColors.success),
      },
      {
        'id': 'rep_02',
        'title': 'التقرير الشهري - شهر أكتوبر 2026',
        'circleName': 'حلقة المغرب',
        'teacherName': 'عبدالرحمن علي الكندي',
        'studentsCount': 12,
        'attendanceRate': '88%',
        'memorizationCount': 38,
        'status': 'قيد المراجعة',
        'statusColor': const Color(AppColors.warning),
      },
    ];

    final demoReports = isTeacher
        ? allReports.where((r) => r['teacherName'] == (user?.name ?? '')).toList()
        : allReports;

    return Scaffold(
      appBar: AppBar(
        title: const Text('التقارير الشهرية والسنوية'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {},
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: demoReports.length,
        itemBuilder: (context, index) {
          final report = demoReports[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(AppColors.primaryGreenSoft).withAlpha(50),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.picture_as_pdf, color: Color(AppColors.primaryGreen)),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              report['title'].toString(),
                              style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                            Text(
                              '${report['circleName']} • المدرس: ${report['teacherName']}',
                              style: TextStyle(fontFamily: 'Cairo', fontSize: 11, color: Colors.grey[600]),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: (report['statusColor'] as Color).withAlpha(40),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          report['status'].toString(),
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: report['statusColor'] as Color,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildMiniStat('الطلاب', report['studentsCount'].toString()),
                      _buildMiniStat('نسبة الحضور', report['attendanceRate'].toString()),
                      _buildMiniStat('جلسات الحفظ', report['memorizationCount'].toString()),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () async {
                            await _pdfService.printMonthlyReport(
                              circleName: report['circleName'].toString(),
                              teacherName: report['teacherName'].toString(),
                              month: 'أكتوبر 2026',
                              attendanceRate: report['attendanceRate'].toString(),
                              studentCount: int.tryParse(report['studentsCount'].toString()) ?? 15,
                            );
                          },
                          icon: const Icon(Icons.print, size: 16),
                          label: const Text('طباعة PDF', style: TextStyle(fontFamily: 'Cairo', fontSize: 12)),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () async {
                            await _pdfService.shareMonthlyReport(
                              circleName: report['circleName'].toString(),
                              teacherName: report['teacherName'].toString(),
                              month: 'أكتوبر 2026',
                              attendanceRate: report['attendanceRate'].toString(),
                              studentCount: int.tryParse(report['studentsCount'].toString()) ?? 15,
                            );
                          },
                          style: ElevatedButton.styleFrom(backgroundColor: const Color(AppColors.primaryGreen)),
                          icon: const Icon(Icons.share, size: 16),
                          label: const Text('مشاركة', style: TextStyle(fontFamily: 'Cairo', fontSize: 12)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showGenerateReportDialog,
        backgroundColor: const Color(AppColors.primaryGreen),
        icon: const Icon(Icons.auto_awesome),
        label: const Text('إعداد تقرير جديد'),
      ),
    );
  }

  Widget _buildMiniStat(String label, String value) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold, fontSize: 13, color: Color(AppColors.primaryGreenDark))),
        Text(label, style: TextStyle(fontFamily: 'Cairo', fontSize: 11, color: Colors.grey[600])),
      ],
    );
  }

  void _showGenerateReportDialog() {
    final circles = AppDataStore.instance.getVisibleCircles();
    String? selectedCircleId = circles.isNotEmpty ? circles.first.id : null;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
            left: 20, right: 20, top: 20,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('إعداد التقرير الشهري', style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 16),
                if (circles.isEmpty)
                  const Text('لا توجد حلقات مسجلة بعد، قم بإضافة حلقة أولاً.', style: TextStyle(fontFamily: 'Cairo', color: Colors.orange))
                else
                  DropdownButtonFormField<String>(
                    initialValue: selectedCircleId,
                    decoration: const InputDecoration(labelText: 'اختر الحلقة'),
                    items: circles.map((c) => DropdownMenuItem(value: c.id, child: Text(c.name, style: const TextStyle(fontFamily: 'Cairo')))).toList(),
                    onChanged: (v) => setS(() => selectedCircleId = v),
                  ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: '11',
                  decoration: const InputDecoration(labelText: 'اختر الشهر'),
                  items: const [
                    DropdownMenuItem(value: '10', child: Text('أكتوبر 2026', style: TextStyle(fontFamily: 'Cairo'))),
                    DropdownMenuItem(value: '11', child: Text('نوفمبر 2026', style: TextStyle(fontFamily: 'Cairo'))),
                    DropdownMenuItem(value: '12', child: Text('ديسمبر 2026', style: TextStyle(fontFamily: 'Cairo'))),
                  ],
                  onChanged: (_) {},
                ),
                const SizedBox(height: 12),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'ملاحظات وتوصيات الإدارة والمدرس'),
                  maxLines: 3,
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 46,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('✅ تم تجميع بيانات الشهر تلقائياً وإنشاء التقرير بنجاح', style: TextStyle(fontFamily: 'Cairo')),
                          backgroundColor: Color(AppColors.primaryGreen),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(AppColors.primaryGreen), foregroundColor: Colors.white),
                    icon: const Icon(Icons.flash_on),
                    label: const Text('تجميع البيانات تلقائياً وإنشاء التقرير', style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
