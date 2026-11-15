import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import '../../data/models/circle_model.dart';
import '../../data/models/student_model.dart';
import '../../data/models/attendance_model.dart';
import '../../data/models/fee_model.dart';
import '../../data/models/announcement_model.dart';
import 'app_data_store.dart';

/// خدمة المزامنة السحابية الفورية مع Firebase Cloud Firestore
/// تتيح التحديث اللحظي للبيانات بين تطبيق المدير وهواتف المعلمين وأولياء الأمور
class FirebaseSyncService {
  static final FirebaseSyncService instance = FirebaseSyncService._internal();
  FirebaseSyncService._internal();

  FirebaseFirestore? _firestore;
  bool _isInitialized = false;

  bool get isAvailable => _isInitialized && _firestore != null;

  /// تهيئة المزامنة السحابية
  Future<void> init() async {
    try {
      if (Firebase.apps.isNotEmpty) {
        _firestore = FirebaseFirestore.instance;
        // تفعيل الكاش المحلي للعمل دون إنترنت
        _firestore?.settings = const Settings(
          persistenceEnabled: true,
          cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
        );
        _isInitialized = true;
        _startListening();
        debugPrint('Firebase Firestore Realtime Sync Initialized.');
      }
    } catch (e) {
      debugPrint('Firebase Sync Fallback: $e');
    }
  }

  /// الاستماع للتحديثات اللحظية من السحابة وتطبيقها في المنظومة فوراً
  void _startListening() {
    if (!isAvailable) return;

    final store = AppDataStore.instance;

    // 1. مزامنة الحلقات
    _firestore?.collection('circles').snapshots().listen((snapshot) {
      for (final change in snapshot.docChanges) {
        final data = change.doc.data();
        if (data != null) {
          final circle = CircleModel.fromMap(data, change.doc.id);
          if (change.type == DocumentChangeType.added || change.type == DocumentChangeType.modified) {
            final idx = store.circles.indexWhere((c) => c.id == circle.id);
            if (idx != -1) {
              store.circles[idx] = circle;
            } else {
              store.circles.add(circle);
            }
          } else if (change.type == DocumentChangeType.removed) {
            store.circles.removeWhere((c) => c.id == circle.id);
          }
        }
      }
      store.notifyListeners();
    }, onError: (e) => debugPrint('Circles sync error: $e'));

    // 2. مزامنة الطلاب
    _firestore?.collection('students').snapshots().listen((snapshot) {
      for (final change in snapshot.docChanges) {
        final data = change.doc.data();
        if (data != null) {
          final student = StudentModel.fromMap(data, change.doc.id);
          if (change.type == DocumentChangeType.added || change.type == DocumentChangeType.modified) {
            final idx = store.students.indexWhere((s) => s.id == student.id);
            if (idx != -1) {
              store.students[idx] = student;
            } else {
              store.students.add(student);
            }
          } else if (change.type == DocumentChangeType.removed) {
            store.students.removeWhere((s) => s.id == student.id);
          }
        }
      }
      store.notifyListeners();
    }, onError: (e) => debugPrint('Students sync error: $e'));

    // 3. مزامنة المعاملات المالية والرسوم
    _firestore?.collection('fees').snapshots().listen((snapshot) {
      for (final change in snapshot.docChanges) {
        final data = change.doc.data();
        if (data != null) {
          final fee = FeeModel.fromMap(data, change.doc.id);
          if (change.type == DocumentChangeType.added || change.type == DocumentChangeType.modified) {
            final idx = store.fees.indexWhere((f) => f.id == fee.id);
            if (idx != -1) {
              store.fees[idx] = fee;
            } else {
              store.fees.add(fee);
            }
          } else if (change.type == DocumentChangeType.removed) {
            store.fees.removeWhere((f) => f.id == fee.id);
          }
        }
      }
      store.notifyListeners();
    }, onError: (e) => debugPrint('Fees sync error: $e'));
  }

  /// رفع حلقة جديدة أو تحديثها في Firebase
  Future<void> syncCircle(CircleModel circle) async {
    if (!isAvailable) return;
    try {
      await _firestore?.collection('circles').doc(circle.id).set(circle.toMap(), SetOptions(merge: true));
    } catch (e) {
      debugPrint('Sync circle error: $e');
    }
  }

  /// رفع طالب جديد أو تحديثه في Firebase
  Future<void> syncStudent(StudentModel student) async {
    if (!isAvailable) return;
    try {
      await _firestore?.collection('students').doc(student.id).set(student.toMap(), SetOptions(merge: true));
    } catch (e) {
      debugPrint('Sync student error: $e');
    }
  }

  /// رفع سجل حضور إلى Firebase
  Future<void> syncAttendance(AttendanceModel attendance) async {
    if (!isAvailable) return;
    try {
      await _firestore?.collection('attendance').doc(attendance.id).set(attendance.toMap(), SetOptions(merge: true));
    } catch (e) {
      debugPrint('Sync attendance error: $e');
    }
  }

  /// رفع معاملة مالية أو رسوم رحلة إلى Firebase
  Future<void> syncFee(FeeModel fee) async {
    if (!isAvailable) return;
    try {
      await _firestore?.collection('fees').doc(fee.id).set(fee.toMap(), SetOptions(merge: true));
    } catch (e) {
      debugPrint('Sync fee error: $e');
    }
  }
}
