// =====================================================================
// Firebase Options - PLACEHOLDER
// يجب استبدال هذا الملف بالملف المولد من Firebase CLI
// قم بتشغيل: flutterfire configure --project=YOUR_PROJECT_ID
// =====================================================================
//
// طريقة إعداد Firebase:
// 1. اذهب إلى https://console.firebase.google.com
// 2. أنشئ مشروعاً جديداً باسم alrayyan-app
// 3. فعّل Authentication (Email/Password)
// 4. أنشئ Firestore Database في وضع Production
// 5. شغّل: dart pub global activate flutterfire_cli
// 6. شغّل: flutterfire configure --project=YOUR_PROJECT_ID
// 7. سيتم استبدال هذا الملف تلقائياً
// =====================================================================

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        throw UnsupportedError('macOS غير مدعوم حالياً');
      case TargetPlatform.windows:
        throw UnsupportedError('Windows غير مدعوم حالياً');
      case TargetPlatform.linux:
        throw UnsupportedError('Linux غير مدعوم حالياً');
      default:
        throw UnsupportedError('المنصة غير مدعومة');
    }
  }

  // TODO: استبدل هذه القيم بقيم مشروع Firebase الخاص بك
  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'YOUR_WEB_API_KEY',
    appId: 'YOUR_WEB_APP_ID',
    messagingSenderId: 'YOUR_MESSAGING_SENDER_ID',
    projectId: 'YOUR_PROJECT_ID',
    authDomain: 'YOUR_PROJECT_ID.firebaseapp.com',
    storageBucket: 'YOUR_PROJECT_ID.appspot.com',
    measurementId: 'YOUR_MEASUREMENT_ID',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'YOUR_ANDROID_API_KEY',
    appId: 'YOUR_ANDROID_APP_ID',
    messagingSenderId: 'YOUR_MESSAGING_SENDER_ID',
    projectId: 'YOUR_PROJECT_ID',
    storageBucket: 'YOUR_PROJECT_ID.appspot.com',
  );
  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'YOUR_IOS_API_KEY',
    appId: 'YOUR_IOS_APP_ID',
    messagingSenderId: 'YOUR_MESSAGING_SENDER_ID',
    projectId: 'YOUR_PROJECT_ID',
    storageBucket: 'YOUR_PROJECT_ID.appspot.com',
    iosBundleId: 'com.alrayyan.alrayyonApp',
  );
}
