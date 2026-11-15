import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'app.dart';
import 'firebase_options.dart';
import 'core/services/local_database_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // إعداد اتجاه الشاشة
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  // نمط شريط الحالة
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );

  // تهيئة Firebase الآمنة (لا توقف تشغيل التطبيق في حال عدم توفر الاتصال السحابي)
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint('Firebase safe fallback: $e');
  }

  // تهيئة قاعدة البيانات المحلية
  try {
    await LocalDatabaseService.instance.init();
  } catch (e) {
    debugPrint('LocalDatabase safe fallback: $e');
  }

  runApp(
    const ProviderScope(
      child: AlRayyanApp(),
    ),
  );
}
