import 'package:flutter/services.dart';
import 'package:excel/excel.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../constants/app_enums.dart';
import '../../data/models/student_model.dart';
import '../../data/models/attendance_model.dart';
import '../../data/models/fee_model.dart';

/// خدمة التصدير والطباعة الشاملة: تصدير إلى Excel (.xlsx) وطباعة تقارير وسندات رسمية (PDF / Word Compatible)
class ExportService {
  static final ExportService instance = ExportService._internal();
  ExportService._internal();

  // =================== 1. تصدير كشف الطلاب إلى Excel ===================
  Future<void> exportStudentsToExcel(List<StudentModel> students) async {
    final excel = Excel.createExcel();
    const sheetName = 'كشف الطلاب';
    final sheet = excel[sheetName];
    excel.setDefaultSheet(sheetName);

    // ترويسة الأعمدة
    sheet.appendRow([
      TextCellValue('الرقم الأكاديمي'),
      TextCellValue('اسم الطالب الرباعي'),
      TextCellValue('الحلقة القرآنية'),
      TextCellValue('المستوى'),
      TextCellValue('اسم ولي الأمر'),
      TextCellValue('صلة القرابة'),
      TextCellValue('هاتف ولي الأمر'),
      TextCellValue('العنوان'),
      TextCellValue('حالة القيد'),
    ]);

    // بيانات الطلاب
    for (final s in students) {
      sheet.appendRow([
        TextCellValue(s.studentNumber),
        TextCellValue(s.fullName),
        TextCellValue(s.circleName),
        TextCellValue(s.level),
        TextCellValue(s.guardianName),
        TextCellValue(s.guardianRelation),
        TextCellValue(s.guardianPhone),
        TextCellValue(s.address ?? 'تريم - دمون'),
        TextCellValue(s.status.displayName),
      ]);
    }

    final bytes = excel.save();
    if (bytes != null) {
      await Printing.sharePdf(
        bytes: Uint8List.fromList(bytes),
        filename: 'كشف_طلاب_مسجد_الريان_${DateTime.now().year}.xlsx',
      );
    }
  }

  // =================== 2. تصدير الحضور والغياب إلى Excel ===================
  Future<void> exportAttendanceToExcel(List<AttendanceModel> records) async {
    final excel = Excel.createExcel();
    const sheetName = 'سجل الحضور';
    final sheet = excel[sheetName];
    excel.setDefaultSheet(sheetName);

    sheet.appendRow([
      TextCellValue('التاريخ'),
      TextCellValue('اليوم'),
      TextCellValue('اسم الطالب'),
      TextCellValue('الحلقة'),
      TextCellValue('الحالة'),
      TextCellValue('المدرس'),
      TextCellValue('الملاحظات'),
    ]);

    for (final r in records) {
      sheet.appendRow([
        TextCellValue('${r.date.year}-${r.date.month.toString().padLeft(2, '0')}-${r.date.day.toString().padLeft(2, '0')}'),
        TextCellValue(r.dayName),
        TextCellValue(r.studentName),
        TextCellValue(r.circleName),
        TextCellValue(r.status.displayName),
        TextCellValue(r.teacherName),
        TextCellValue(r.notes ?? ''),
      ]);
    }

    final bytes = excel.save();
    if (bytes != null) {
      await Printing.sharePdf(
        bytes: Uint8List.fromList(bytes),
        filename: 'كشف_حضور_مسجد_الريان_${DateTime.now().month}_${DateTime.now().year}.xlsx',
      );
    }
  }

  // =================== 3. تصدير السجل المالي والرحلات إلى Excel ===================
  Future<void> exportFeesToExcel(List<FeeModel> fees) async {
    final excel = Excel.createExcel();
    const sheetName = 'السجل المالي والرحلات';
    final sheet = excel[sheetName];
    excel.setDefaultSheet(sheetName);

    sheet.appendRow([
      TextCellValue('رقم السند'),
      TextCellValue('اسم الطالب'),
      TextCellValue('بيان المعاملة / النشاط'),
      TextCellValue('الشهر / الفترة'),
      TextCellValue('المبلغ المستحق (ر.ي)'),
      TextCellValue('المبلغ المدفوع (ر.ي)'),
      TextCellValue('المتبقي (ر.ي)'),
      TextCellValue('طريقة السداد'),
      TextCellValue('المستلم'),
      TextCellValue('الحالة'),
    ]);

    for (final f in fees) {
      sheet.appendRow([
        TextCellValue(f.id),
        TextCellValue(f.studentName),
        TextCellValue(f.notes != null && f.notes!.isNotEmpty ? f.notes! : 'رسوم اشتراك شهري'),
        TextCellValue('${f.month}/${f.year}'),
        DoubleCellValue(f.amountDue),
        DoubleCellValue(f.amountPaid),
        DoubleCellValue(f.amountRemaining),
        TextCellValue(f.paymentMethod ?? 'نقداً'),
        TextCellValue(f.receiverName ?? 'إدارة المسجد'),
        TextCellValue(f.status == FeeStatus.paid ? 'مسدد بالكامل' : (f.status == FeeStatus.partial ? 'مسدد جزئياً' : 'غير مسدد')),
      ]);
    }

    final bytes = excel.save();
    if (bytes != null) {
      await Printing.sharePdf(
        bytes: Uint8List.fromList(bytes),
        filename: 'السجل_المالي_والرحلات_مسجد_الريان.xlsx',
      );
    }
  }

  // =================== 4. طباعة سند قبض رسمي PDF ===================
  Future<void> printReceiptPdf(FeeModel fee) async {
    final doc = pw.Document();

    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a5,
        textDirection: pw.TextDirection.rtl,
        build: (pw.Context context) {
          return pw.Container(
            padding: const pw.EdgeInsets.all(20),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColors.green800, width: 2),
              borderRadius: pw.BorderRadius.circular(14),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // ترويسة سند القبض
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text('حلقات مسجد الريان النموذجية', style: pw.TextStyle(fontSize: 15, fontWeight: pw.FontWeight.bold)),
                        pw.Text('تريم - دمون • حضرموت', style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700)),
                      ],
                    ),
                    pw.Container(
                      padding: const pw.EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      decoration: pw.BoxDecoration(
                        color: PdfColor.fromHex('#103D32'),
                        borderRadius: pw.BorderRadius.circular(8),
                      ),
                      child: pw.Text('سند قبض مالي رسمي', style: pw.TextStyle(color: PdfColors.white, fontWeight: pw.FontWeight.bold, fontSize: 13)),
                    ),
                  ],
                ),
                pw.Divider(thickness: 1, height: 20),

                // تفاصيل السند
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('رقم السند: ${fee.id}', style: const pw.TextStyle(fontSize: 11)),
                    pw.Text('التاريخ: ${fee.createdAt.year}/${fee.createdAt.month}/${fee.createdAt.day}', style: const pw.TextStyle(fontSize: 11)),
                  ],
                ),
                pw.SizedBox(height: 12),

                pw.Container(
                  padding: const pw.EdgeInsets.all(12),
                  decoration: pw.BoxDecoration(
                    color: PdfColors.grey100,
                    borderRadius: pw.BorderRadius.circular(8),
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      _buildReceiptRow('استلمنا من ولي أمر الطالب:', fee.studentName),
                      pw.SizedBox(height: 6),
                      _buildReceiptRow('مبلغ وقدره:', '${fee.amountPaid.toInt()} ريال يمني'),
                      pw.SizedBox(height: 6),
                      _buildReceiptRow('وذلك عن:', fee.notes != null && fee.notes!.isNotEmpty ? fee.notes! : 'رسوم اشتراك حلقة لشهر (${fee.month}/${fee.year})'),
                      pw.SizedBox(height: 6),
                      _buildReceiptRow('طريقة السداد:', fee.paymentMethod ?? 'نقداً'),
                      pw.SizedBox(height: 6),
                      _buildReceiptRow('المبلغ المتبقي:', '${fee.amountRemaining.toInt()} ريال يمني'),
                    ],
                  ),
                ),
                pw.Spacer(),

                // التوقيعات والختم
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.center,
                      children: [
                        pw.Text('المستلم / أمين الصندوق', style: const pw.TextStyle(fontSize: 10)),
                        pw.SizedBox(height: 4),
                        pw.Text(fee.receiverName ?? 'إدارة المسجد', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11)),
                      ],
                    ),
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.center,
                      children: [
                        pw.Text('الختم والاعتماد', style: const pw.TextStyle(fontSize: 10)),
                        pw.SizedBox(height: 4),
                        pw.Text('إدارة حلقات مسجد الريان', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11)),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => doc.save(),
      name: 'سند_قبض_${fee.studentName}_${fee.id}',
    );
  }

  pw.Widget _buildReceiptRow(String label, String value) {
    return pw.Row(
      children: [
        pw.Text(label, style: const pw.TextStyle(fontSize: 11, color: PdfColors.grey800)),
        pw.SizedBox(width: 8),
        pw.Text(value, style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold)),
      ],
    );
  }

  // =================== 5. طباعة كشف التقرير المالي والرحلات PDF ===================
  Future<void> printFinancialReportPdf(List<FeeModel> fees, double totalDue, double totalPaid) async {
    final doc = pw.Document();

    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        textDirection: pw.TextDirection.rtl,
        build: (pw.Context context) {
          return pw.Container(
            padding: const pw.EdgeInsets.all(24),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text('مسجد الريان - تريم دمون', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
                        pw.Text('التقرير المالي العام لحسابات الحلقات والأنشطة والرحلات', style: const pw.TextStyle(fontSize: 11, color: PdfColors.grey700)),
                      ],
                    ),
                    pw.Text('تاريخ التقرير: ${DateTime.now().year}/${DateTime.now().month}/${DateTime.now().day}', style: const pw.TextStyle(fontSize: 10)),
                  ],
                ),
                pw.Divider(thickness: 1, height: 20),

                // بطاقات الإجماليات
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
                  children: [
                    pw.Container(
                      padding: const pw.EdgeInsets.all(10),
                      decoration: pw.BoxDecoration(color: PdfColors.grey200, borderRadius: pw.BorderRadius.circular(8)),
                      child: pw.Text('إجمالي المستحق: ${totalDue.toInt()} ر.ي', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                    ),
                    pw.Container(
                      padding: const pw.EdgeInsets.all(10),
                      decoration: pw.BoxDecoration(color: PdfColors.green100, borderRadius: pw.BorderRadius.circular(8)),
                      child: pw.Text('إجمالي المحصل: ${totalPaid.toInt()} ر.ي', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.green900)),
                    ),
                    pw.Container(
                      padding: const pw.EdgeInsets.all(10),
                      decoration: pw.BoxDecoration(color: PdfColors.red100, borderRadius: pw.BorderRadius.circular(8)),
                      child: pw.Text('المتبقي المتأخر: ${(totalDue - totalPaid).clamp(0, totalDue).toInt()} ر.ي', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.red900)),
                    ),
                  ],
                ),
                pw.SizedBox(height: 20),

                // جدول العمليات
                pw.TableHelper.fromTextArray(
                  headers: ['الطالب', 'البيان / النشاط', 'المستحق', 'المدفوع', 'المتبقي', 'طريقة السداد', 'الحالة'],
                  data: fees.map((f) => [
                    f.studentName,
                    f.notes != null && f.notes!.isNotEmpty ? f.notes! : 'رسوم اشتراك',
                    '${f.amountDue.toInt()} ر.ي',
                    '${f.amountPaid.toInt()} ر.ي',
                    '${f.amountRemaining.toInt()} ر.ي',
                    f.paymentMethod ?? 'نقداً',
                    f.status == FeeStatus.paid ? 'مسدد' : 'متبقي',
                  ]).toList(),
                  headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10),
                  cellStyle: const pw.TextStyle(fontSize: 9),
                  cellAlignment: pw.Alignment.centerRight,
                  headerDecoration: const pw.BoxDecoration(color: PdfColors.grey300),
                ),
              ],
            ),
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => doc.save(),
      name: 'التقرير_المالي_مسجد_الريان',
    );
  }
}
