import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:barcode_widget/barcode_widget.dart';
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../data/models/circle_model.dart';

/// نافذة وبطاقة باركود الحلقة الحقيقية القياسية القابلة للمسح والطباعة
class CircleBarcodeDialog extends StatefulWidget {
  final CircleModel circle;

  const CircleBarcodeDialog({super.key, required this.circle});

  static void show(BuildContext context, CircleModel circle) {
    showDialog(
      context: context,
      builder: (ctx) => CircleBarcodeDialog(circle: circle),
    );
  }

  @override
  State<CircleBarcodeDialog> createState() => _CircleBarcodeDialogState();
}

class _CircleBarcodeDialogState extends State<CircleBarcodeDialog> {
  int _selectedView = 0; // 0 = كود QR، 1 = باركود خطي، 2 = كلاهما

  @override
  Widget build(BuildContext context) {
    final circle = widget.circle;
    final qrData = 'مسجد الريان بتريم | حلقة: ${circle.name} | كود الدخول: ${circle.circleCode} | كلمة المرور: ${circle.accessPassword}';

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 420),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ترويسة بطاقة الحلقة الرسمية
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(AppColors.primaryGreen).withOpacity(0.12),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.mosque, color: Color(AppColors.primaryGreenDark), size: 24),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'مسجد الريان - تريم دمون',
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Color(AppColors.primaryGreenDark),
                          ),
                        ),
                        Text(
                          'بطاقة الاعتماد والباركود الرسمي للحلقة',
                          style: TextStyle(fontFamily: 'Cairo', fontSize: 11, color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 20, color: Colors.grey),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // بطاقة اسم الحلقة والمدرس المنسقة
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(AppColors.primaryGreen).withOpacity(0.08),
                      const Color(AppColors.gold).withOpacity(0.12),
                    ],
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                  ),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(AppColors.gold).withOpacity(0.4)),
                ),
                child: Column(
                  children: [
                    Text(
                      circle.name,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(AppColors.primaryGreenDark),
                      ),
                    ),
                    const SizedBox(height: 3),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.person, size: 14, color: Color(AppColors.goldDark)),
                        const SizedBox(width: 4),
                        Text(
                          'أستاذ الحلقة: ${circle.teacherName}',
                          style: const TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Color(AppColors.goldDark),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // تبديل العرض (QR Code / باركود / كلاهما)
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.all(3),
                child: Row(
                  children: [
                    _buildTabButton('كود QR السريع', 0),
                    _buildTabButton('الباركود الخطي', 1),
                    _buildTabButton('البطاقة الكاملة', 2),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // حاوية الباركود المتناسقة والمرسومة بالمكتبة الحقيقية
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: Colors.grey.shade300, width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // عرض QR Code الحقيقي
                    if (_selectedView == 0 || _selectedView == 2) ...[
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: QrImageView(
                          data: qrData,
                          version: QrVersions.auto,
                          size: 175.0,
                          eyeStyle: const QrEyeStyle(
                            eyeShape: QrEyeShape.square,
                            color: Color(AppColors.primaryGreenDark),
                          ),
                          dataModuleStyle: const QrDataModuleStyle(
                            dataModuleShape: QrDataModuleShape.square,
                            color: Color(AppColors.primaryGreenDark),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'امسح الرمز بكاميرا الجوال للدخول الفوري',
                        style: TextStyle(fontFamily: 'Cairo', fontSize: 11, color: Colors.grey.shade600),
                      ),
                    ],

                    if (_selectedView == 2) const SizedBox(height: 16),

                    // عرض الباركود الخطي الحقيقي Code 128
                    if (_selectedView == 1 || _selectedView == 2) ...[
                      BarcodeWidget(
                        barcode: Barcode.code128(),
                        data: circle.circleCode,
                        width: 240,
                        height: 60,
                        drawText: true,
                        style: const TextStyle(
                          fontFamily: 'Courier',
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'رمز الحلقة المعتمد لأجهزة قارئ الباركود',
                        style: TextStyle(fontFamily: 'Cairo', fontSize: 10, color: Colors.grey.shade500),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // بطاقة تفاصيل بيانات الدخول
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFBFBF9),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('كود الحلقة الموحد:', style: TextStyle(fontFamily: 'Cairo', fontSize: 11, color: Colors.black54)),
                          Text(
                            circle.circleCode,
                            style: const TextStyle(
                              fontFamily: 'Courier',
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: Color(AppColors.primaryGreenDark),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(width: 1, height: 32, color: Colors.grey.shade300),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('كلمة مرور الدخول:', style: TextStyle(fontFamily: 'Cairo', fontSize: 11, color: Colors.black54)),
                          Text(
                            circle.accessPassword,
                            style: const TextStyle(
                              fontFamily: 'Courier',
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: Color(AppColors.goldDark),
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.copy, size: 18, color: Color(AppColors.primaryGreen)),
                      tooltip: 'نسخ الكود وكلمة المرور',
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: 'كود: ${circle.circleCode} | كلمة المرور: ${circle.accessPassword}'));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('تم نسخ بيانات الدخول للحافظة بنجاح', style: TextStyle(fontFamily: 'Cairo')),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // أزرار العمليات (طباعة - واتساب - نسخ)
              Row(
                children: [
                  // زر الطباعة
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(AppColors.primaryGreen),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                      icon: const Icon(Icons.print_outlined, size: 17),
                      label: const Text('طباعة البطاقة', style: TextStyle(fontFamily: 'Cairo', fontSize: 11, fontWeight: FontWeight.bold)),
                      onPressed: () => _printBarcode(circle, qrData),
                    ),
                  ),
                  const SizedBox(width: 8),

                  // زر إرسال واتساب
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF25D366),
                        side: const BorderSide(color: Color(0xFF25D366), width: 1.2),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      icon: const Icon(Icons.share, size: 17),
                      label: const Text('إرسال واتساب', style: TextStyle(fontFamily: 'Cairo', fontSize: 11, fontWeight: FontWeight.bold)),
                      onPressed: () => _shareViaWhatsApp(circle),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabButton(String label, int index) {
    final isSelected = _selectedView == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedView = index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 6),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            boxShadow: isSelected
                ? [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 4, offset: const Offset(0, 1))]
                : null,
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 11,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? const Color(AppColors.primaryGreenDark) : Colors.black54,
            ),
          ),
        ),
      ),
    );
  }

  // =================== طباعة بطاقة الباركود الرسمية عبر PDF ===================
  void _printBarcode(CircleModel circle, String qrData) async {
    final doc = pw.Document();

    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a5,
        textDirection: pw.TextDirection.rtl,
        build: (pw.Context context) {
          return pw.Container(
            padding: const pw.EdgeInsets.all(24),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColors.grey700, width: 2),
              borderRadius: pw.BorderRadius.circular(16),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.center,
              children: [
                pw.Text(
                  'مسجد الريان - تريم دمون',
                  style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
                ),
                pw.SizedBox(height: 4),
                pw.Text(
                  'بطاقة الدخول الرسمية للحلقة القرآنية',
                  style: const pw.TextStyle(fontSize: 12, color: PdfColors.grey700),
                ),
                pw.Divider(thickness: 1, height: 20),
                pw.SizedBox(height: 8),

                pw.Text(
                  circle.name,
                  style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
                ),
                pw.SizedBox(height: 4),
                pw.Text(
                  'الأستاذ المشرف: ${circle.teacherName}',
                  style: const pw.TextStyle(fontSize: 12),
                ),
                pw.SizedBox(height: 16),

                // باركود QR Code للطباعة
                pw.BarcodeWidget(
                  barcode: pw.Barcode.qrCode(),
                  data: qrData,
                  width: 140,
                  height: 140,
                ),
                pw.SizedBox(height: 12),

                // باركود خطي للطباعة
                pw.BarcodeWidget(
                  barcode: pw.Barcode.code128(),
                  data: circle.circleCode,
                  width: 200,
                  height: 45,
                  drawText: true,
                ),
                pw.SizedBox(height: 16),

                pw.Container(
                  padding: const pw.EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: pw.BoxDecoration(
                    color: PdfColors.grey100,
                    borderRadius: pw.BorderRadius.circular(8),
                  ),
                  child: pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
                    children: [
                      pw.Text('كود الحلقة: ${circle.circleCode}', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      pw.Text('كلمة المرور: ${circle.accessPassword}', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                    ],
                  ),
                ),
                pw.Spacer(),
                pw.Text(
                  'منظومة حلقات مسجد الريان لتعليم القرآن الكريم • تريم - حضرموت',
                  style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey600),
                ),
              ],
            ),
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => doc.save(),
      name: 'باركود_${circle.name}_${circle.circleCode}',
    );
  }

  // =================== مشاركة بيانات الباركود عبر واتساب ===================
  void _shareViaWhatsApp(CircleModel circle) async {
    final text = '🌿 *حلقات مسجد الريان - تريم دمون* 🌿\n\n'
        'بطاقة اعتماد وبيانات الدخول لحلقة: *${circle.name}*\n'
        '• أستاذ الحلقة: ${circle.teacherName}\n'
        '• كود الحلقة الموحد: *${circle.circleCode}*\n'
        '• كلمة مرور الدخول: *${circle.accessPassword}*\n'
        '• أيام الدراسة: ${circle.studyDays.join(" - ")}\n\n'
        'يمكنكم مسح الباركود أو إدخال الكود وكلمة المرور لتسجيل الدخول ومتابعة الحفظ والحضور.';

    final uri = Uri.parse('https://wa.me/?text=${Uri.encodeComponent(text)}');
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      if (mounted) {
        Clipboard.setData(ClipboardData(text: text));
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم نسخ بيانات الحلقة لمشاركتها', style: TextStyle(fontFamily: 'Cairo'))),
        );
      }
    }
  }
}
