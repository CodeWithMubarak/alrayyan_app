import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import '../constants/app_colors.dart';

/// خدمة التحديث التلقائي والفحص الدوري للإصدارات من GitHub و Firebase
class UpdateService {
  static final UpdateService instance = UpdateService._internal();
  UpdateService._internal();

  static const String currentVersion = '1.0.0';
  static const String currentBuildNumber = '1';

  // مستودع المشروع الرسمي على GitHub
  static const String githubOwner = 'CodeWithMubarak';
  static const String githubRepo = 'alrayyan_app';

  bool _hasCheckedThisSession = false;

  /// فحص توفر تحديث جديد تلقائياً عند بدء التشغيل
  Future<void> checkOnStartup(BuildContext context) async {
    if (_hasCheckedThisSession) return;
    _hasCheckedThisSession = true;

    // تشغيل الفحص في الخلفية دون تعطيل واجهة المستخدم
    await Future.delayed(const Duration(seconds: 4));
    if (!context.mounted) return;
    await checkForUpdates(context, isSilentIfLatest: true);
  }

  /// فحص التحديثات يدوياً أو تلقائياً
  Future<void> checkForUpdates(BuildContext context, {bool isSilentIfLatest = false}) async {
    try {
      final url = Uri.parse('https://api.github.com/repos/$githubOwner/$githubRepo/releases/latest');
      final response = await http.get(url, headers: {
        'Accept': 'application/vnd.github.v3+json',
      }).timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final latestTag = (data['tag_name'] as String? ?? '').replaceAll('v', '').trim();
        final releaseNotes = data['body'] as String? ?? 'تحسينات وإصلاحات عامة في المنظومة';
        final assets = (data['assets'] as List?) ?? [];

        // البحث عن رابط APK في أصول الإصدار
        String? downloadUrl;
        for (final asset in assets) {
          final name = (asset['name'] as String? ?? '').toLowerCase();
          if (name.endsWith('.apk')) {
            downloadUrl = asset['browser_download_url'];
            break;
          }
        }

        final rawHtmlUrl = data['html_url'] as String?;
        final String finalDownloadUrl = downloadUrl ?? rawHtmlUrl ?? 'https://github.com/$githubOwner/$githubRepo/releases/latest';

        if (_isNewerVersion(latestTag, currentVersion)) {
          if (!context.mounted) return;
          _showUpdateDialog(context, latestTag, releaseNotes, finalDownloadUrl);
          return;
        }
      }

      if (!isSilentIfLatest && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'أنت تستخدم أحدث إصدار من المنظومة (v$currentVersion)',
              style: TextStyle(fontFamily: 'Cairo'),
            ),
            backgroundColor: Color(AppColors.primaryGreen),
          ),
        );
      }
    } catch (e) {
      debugPrint('Check update error (safe fallback): $e');
      if (!isSilentIfLatest && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'تعذر الاتصال بخادم التحديثات حالياً، يرجى المحاولة لاحقاً',
              style: TextStyle(fontFamily: 'Cairo'),
            ),
          ),
        );
      }
    }
  }

  bool _isNewerVersion(String latest, String current) {
    if (latest.isEmpty) return false;
    try {
      final latestParts = latest.split('.').map((p) => int.tryParse(p) ?? 0).toList();
      final currentParts = current.split('.').map((p) => int.tryParse(p) ?? 0).toList();

      for (var i = 0; i < latestParts.length && i < currentParts.length; i++) {
        if (latestParts[i] > currentParts[i]) return true;
        if (latestParts[i] < currentParts[i]) return false;
      }
      return latestParts.length > currentParts.length;
    } catch (_) {
      return false;
    }
  }

  void _showUpdateDialog(BuildContext context, String version, String notes, String downloadUrl) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Row(
            children: [
              Icon(Icons.system_update, color: Color(AppColors.primaryGreen), size: 28),
              SizedBox(width: 10),
              Text(
                'تحديث جديد متاح للمنظومة',
                style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(AppColors.goldAccent).withAlpha(30),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'الإصدار الجديد: v$version  (الإصدار الحالي: v$currentVersion)',
                  style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold, fontSize: 12),
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'يتوفر تحديث جديد لحلقات مسجد الريان يشمل تحسينات أمنية وتطويرات مهمة:',
                style: TextStyle(fontFamily: 'Cairo', fontSize: 12, height: 1.4),
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  notes.isNotEmpty ? notes : '• تحسين الأداء وسرعة النظام\n• ميزات إضافية للمالية والتقارير',
                  style: const TextStyle(fontFamily: 'Cairo', fontSize: 11, color: Colors.black87),
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('لاحقاً', style: TextStyle(fontFamily: 'Cairo', color: Colors.grey)),
            ),
            ElevatedButton.icon(
              onPressed: () async {
                Navigator.pop(ctx);
                final uri = Uri.parse(downloadUrl);
                if (await canLaunchUrl(uri)) {
                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(AppColors.primaryGreen),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              icon: const Icon(Icons.download, size: 18),
              label: const Text('تنزيل وتحديث الآن', style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }
}
