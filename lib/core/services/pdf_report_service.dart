import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../constants/app_strings.dart';
import '../constants/app_enums.dart';
import '../../data/models/circle_model.dart';
import '../../data/models/student_model.dart';
import 'app_data_store.dart';

class PdfReportService {
  static final PdfReportService instance = PdfReportService();

  /// طباعة وحفظ التقرير الشهري الشامل للحلقة (الحضور، الغياب، الحفظ، الإنجاز)
  Future<void> printCircleMonthlyReport({
    required CircleModel circle,
    int? year,
    int? month,
  }) async {
    final store = AppDataStore.instance;
    final now = DateTime.now();
    final targetYear = year ?? now.year;
    final targetMonth = month ?? now.month;

    final monthNames = [
      '', 'يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو',
      'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر'
    ];
    final monthName = monthNames[targetMonth];

    final students = store.getStudentsByCircle(circle.id);
    final monthAttendance = store.attendanceRecords.where((a) {
      return a.circleId == circle.id && a.date.year == targetYear && a.date.month == targetMonth;
    }).toList();

    final pdf = pw.Document();

    // تحميل خط عربي
    pw.Font ttf;
    try {
      final fontData = await rootBundle.load('assets/fonts/Cairo-Regular.ttf');
      ttf = pw.Font.ttf(fontData);
    } catch (_) {
      try {
        final fontData = await rootBundle.load('packages/alrayyan_app/assets/fonts/Cairo-Regular.ttf');
        ttf = pw.Font.ttf(fontData);
      } catch (_) {
        ttf = await PdfGoogleFonts.cairoRegular();
      }
    }

    final tableData = <List<String>>[];
    for (var i = 0; i < students.length; i++) {
      final s = students[i];
      final pDays = monthAttendance.where((a) => a.studentId == s.id && a.status == AttendanceStatus.present).length;
      final aDays = monthAttendance.where((a) => a.studentId == s.id && a.status == AttendanceStatus.absent).length;
      final eDays = monthAttendance.where((a) => a.studentId == s.id && (a.status == AttendanceStatus.excusedAbsent || a.status == AttendanceStatus.late)).length;
      final total = pDays + aDays + eDays;
      final rate = total > 0 ? '${((pDays / total) * 100).toStringAsFixed(0)}%' : '100%';

      final prog = store.getQuranProgress(s.id);
      final memorization = prog != null ? 'سورة ${prog.lastSurahName} (${prog.totalMemorizedPages} صفحة)' : 'جزء عم (مستمر)';

      tableData.add([
        '${i + 1}',
        s.fullName,
        s.studentNumber,
        '$pDays',
        '$aDays',
        '$eDays',
        rate,
        memorization,
      ]);
    }

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        textDirection: pw.TextDirection.rtl,
        theme: pw.ThemeData.withFont(base: ttf),
        header: (pw.Context ctx) {
          return pw.Container(
            padding: const pw.EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            margin: const pw.EdgeInsets.only(bottom: 12),
            decoration: pw.BoxDecoration(
              color: PdfColor.fromHex('#103D32'),
              borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
            ),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'مسجد الريان - تريم دمون',
                      style: pw.TextStyle(font: ttf, color: PdfColors.white, fontSize: 13, fontWeight: pw.FontWeight.bold),
                    ),
                    pw.Text(
                      'منظومة الحلقات القرآنية النموذجية',
                      style: pw.TextStyle(font: ttf, color: PdfColor.fromHex('#C6A45C'), fontSize: 10),
                    ),
                  ],
                ),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Text(
                      'تقرير الحضور والإنجاز الشهري',
                      style: pw.TextStyle(font: ttf, color: PdfColors.white, fontSize: 12, fontWeight: pw.FontWeight.bold),
                    ),
                    pw.Text(
                      'شهر: $monthName $targetYear م',
                      style: pw.TextStyle(font: ttf, color: PdfColor.fromHex('#C6A45C'), fontSize: 10),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
        footer: (pw.Context ctx) {
          return pw.Container(
            padding: const pw.EdgeInsets.only(top: 8),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text('صفحة ${ctx.pageNumber} من ${ctx.pagesCount}', style: pw.TextStyle(font: ttf, fontSize: 9, color: PdfColors.grey700)),
                pw.Text('تاريخ الطباعة: ${DateTime.now().toLocal().toString().split(" ")[0]}', style: pw.TextStyle(font: ttf, fontSize: 9, color: PdfColors.grey700)),
              ],
            ),
          );
        },
        build: (pw.Context ctx) {
          return [
            // بطاقة بيانات الحلقة
            pw.Container(
              padding: const pw.EdgeInsets.all(10),
              margin: const pw.EdgeInsets.only(bottom: 14),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColor.fromHex('#C6A45C'), width: 1),
                borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
                color: PdfColor.fromHex('#F5F3ED'),
              ),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
                children: [
                  pw.Text('الحلقة: ${circle.name}', style: pw.TextStyle(font: ttf, fontSize: 11, fontWeight: pw.FontWeight.bold)),
                  pw.Text('المدرس: ${circle.teacherName}', style: pw.TextStyle(font: ttf, fontSize: 11)),
                  pw.Text('عدد الطلاب: ${students.length}', style: pw.TextStyle(font: ttf, fontSize: 11)),
                  pw.Text('الكود: ${circle.circleCode}', style: pw.TextStyle(font: ttf, fontSize: 11)),
                ],
              ),
            ),

            // جدول تفصيلي لكل طلاب الحلقة
            pw.TableHelper.fromTextArray(
              context: ctx,
              cellStyle: pw.TextStyle(font: ttf, fontSize: 9),
              headerStyle: pw.TextStyle(font: ttf, fontSize: 9, fontWeight: pw.FontWeight.bold, color: PdfColors.white),
              headerDecoration: pw.BoxDecoration(color: PdfColor.fromHex('#103D32')),
              cellAlignment: pw.Alignment.center,
              headerAlignment: pw.Alignment.center,
              headers: [
                'م',
                'اسم الطالب',
                'الرقم الدراسي',
                'حضور',
                'غياب',
                'عذر',
                'النسبة',
                'مستوى الحفظ الحالي',
              ],
              data: tableData.isEmpty
                  ? [
                      ['-', 'لا يوجد طلاب مسجلون في هذه الحلقة', '-', '-', '-', '-', '-', '-']
                    ]
                  : tableData,
            ),

            pw.SizedBox(height: 30),

            // اعتمادات وتوقيعات الإدارة والمدرس
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Column(
                  children: [
                    pw.Text('توقيع مدرس الحلقة', style: pw.TextStyle(font: ttf, fontSize: 10, fontWeight: pw.FontWeight.bold)),
                    pw.SizedBox(height: 4),
                    pw.Text(circle.teacherName, style: pw.TextStyle(font: ttf, fontSize: 9, color: PdfColors.grey700)),
                    pw.SizedBox(height: 25),
                    pw.Text('................................', style: const pw.TextStyle(fontSize: 10)),
                  ],
                ),
                pw.Column(
                  children: [
                    pw.Text('توقيع وختم المدير العام', style: pw.TextStyle(font: ttf, fontSize: 10, fontWeight: pw.FontWeight.bold)),
                    pw.SizedBox(height: 4),
                    pw.Text('إدارة مسجد الريان بتريم', style: pw.TextStyle(font: ttf, fontSize: 9, color: PdfColors.grey700)),
                    pw.SizedBox(height: 25),
                    pw.Text('................................', style: const pw.TextStyle(fontSize: 10)),
                  ],
                ),
              ],
            ),
          ];
        },
      ),
    );

    final bytes = await pdf.save();
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => bytes,
      name: 'سجل_حلقة_${circle.name}_${monthName}_$targetYear.pdf',
    );
  }

  Future<Uint8List> generateMonthlyReportPdf({
    required String circleName,
    required String teacherName,
    required String month,
    required String attendanceRate,
    required int studentCount,
  }) async {
    final pdf = pw.Document();

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
                    ['الحفظ الجديد', 'متابعة المقرر الشهري', 'ممتاز'],
                    ['المراجعة المقررة', 'الأجزاء المحفوظة', 'جيد جداً'],
                    ['الانضباط والحضور', attendanceRate, 'منتظم'],
                  ],
                ),
                pw.Spacer(),
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
