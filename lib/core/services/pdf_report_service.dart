import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../constants/app_strings.dart';

class PdfReportService {
  Future<Uint8List> generateMonthlyReportPdf({
    required String circleName,
    required String teacherName,
    required String month,
    required String attendanceRate,
    required int studentCount,
  }) async {
    final pdf = pw.Document();

    // تحميل خط عربي للـ PDF
    final fontData = await rootBundle.load('assets/fonts/Cairo-Regular.ttf').catchError((_) {
      return rootBundle.load('packages/alrayyan_app/assets/fonts/Cairo-Regular.ttf');
    });
    final ttf = pw.Font.ttf(fontData);

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        textDirection: pw.TextDirection.rtl,
        theme: pw.ThemeData.withFont(base: ttf),
        build: (pw.Context context) {
          return pw.Container(
            padding: const pw.EdgeInsets.all(24),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // ترويسة التقرير
                pw.Container(
                  padding: const pw.EdgeInsets.all(16),
                  decoration: pw.BoxDecoration(
                    color: PdfColor.fromHex('#1B5E20'),
                    borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
                  ),
                  child: pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                            AppStrings.institutionName,
                            style: pw.TextStyle(font: ttf, color: PdfColors.white, fontSize: 13, fontWeight: pw.FontWeight.bold),
                          ),
                          pw.SizedBox(height: 4),
                          pw.Text(
                            '${AppStrings.location} • العام الدراسي: ${AppStrings.academicYear}',
                            style: pw.TextStyle(font: ttf, color: PdfColor.fromHex('#F5D87E'), fontSize: 10),
                          ),
                        ],
                      ),
                      pw.Text(
                        'تقرير شهري',
                        style: pw.TextStyle(font: ttf, color: PdfColors.white, fontSize: 16, fontWeight: pw.FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                pw.SizedBox(height: 20),

                // معلومات الحلقة والشهر
                pw.Text(
                  'بيانات التقرير: $month',
                  style: pw.TextStyle(font: ttf, fontSize: 14, fontWeight: pw.FontWeight.bold),
                ),
                pw.SizedBox(height: 10),
                pw.TableHelper.fromTextArray(
                  context: context,
                  cellStyle: pw.TextStyle(font: ttf, fontSize: 11),
                  headerStyle: pw.TextStyle(font: ttf, fontSize: 11, fontWeight: pw.FontWeight.bold, color: PdfColors.white),
                  headerDecoration: pw.BoxDecoration(color: PdfColor.fromHex('#2E7D32')),
                  headers: ['اسم الحلقة', 'مدرس الحلقة', 'عدد الطلاب', 'نسبة الحضور'],
                  data: [
                    [circleName, teacherName, '$studentCount طالب', attendanceRate],
                  ],
                ),

                pw.SizedBox(height: 25),
                pw.Text(
                  'ملخص الإنجاز الشهري',
                  style: pw.TextStyle(font: ttf, fontSize: 13, fontWeight: pw.FontWeight.bold),
                ),
                pw.SizedBox(height: 8),
                pw.TableHelper.fromTextArray(
                  context: context,
                  cellStyle: pw.TextStyle(font: ttf, fontSize: 10),
                  headerStyle: pw.TextStyle(font: ttf, fontSize: 10, fontWeight: pw.FontWeight.bold, color: PdfColors.white),
                  headerDecoration: pw.BoxDecoration(color: PdfColor.fromHex('#2E7D32')),
                  headers: ['المجال', 'الإنجاز الفعلي', 'مستوى الإتقان'],
                  data: [
                    ['الحفظ الجديد', 'من سورة النبأ إلى سورة المطففين', 'ممتاز'],
                    ['المراجعة المقررة', 'الأجزاء: 28 و 29', 'جيد جداً'],
                    ['الاختبار الشهري', 'اختبار الجزء الثلاثين بنجاح', 'نسبة النجاح 95%'],
                  ],
                ),

                pw.Spacer(),

                // خانات التوقيع والاعتماد
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Column(
                      children: [
                        pw.Text('توقيع المدرس', style: pw.TextStyle(font: ttf, fontSize: 11, fontWeight: pw.FontWeight.bold)),
                        pw.SizedBox(height: 35),
                        pw.Text('................................', style: const pw.TextStyle(fontSize: 10)),
                      ],
                    ),
                    pw.Column(
                      children: [
                        pw.Text('توقيع مدير الحلقات والختم', style: pw.TextStyle(font: ttf, fontSize: 11, fontWeight: pw.FontWeight.bold)),
                        pw.SizedBox(height: 35),
                        pw.Text('................................', style: const pw.TextStyle(fontSize: 10)),
                      ],
                    ),
                  ],
                ),
                pw.SizedBox(height: 15),
              ],
            ),
          );
        },
      ),
    );

    return pdf.save();
  }

  Future<void> printMonthlyReport({
    required String circleName,
    required String teacherName,
    required String month,
    required String attendanceRate,
    required int studentCount,
  }) async {
    final pdfBytes = await generateMonthlyReportPdf(
      circleName: circleName,
      teacherName: teacherName,
      month: month,
      attendanceRate: attendanceRate,
      studentCount: studentCount,
    );
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdfBytes,
      name: 'تقرير_${circleName}_$month.pdf',
    );
  }

  Future<void> shareMonthlyReport({
    required String circleName,
    required String teacherName,
    required String month,
    required String attendanceRate,
    required int studentCount,
  }) async {
    final pdfBytes = await generateMonthlyReportPdf(
      circleName: circleName,
      teacherName: teacherName,
      month: month,
      attendanceRate: attendanceRate,
      studentCount: studentCount,
    );
    await Printing.sharePdf(
      bytes: pdfBytes,
      filename: 'تقرير_${circleName}_$month.pdf',
    );
  }
}
