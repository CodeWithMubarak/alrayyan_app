import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// خدمة قاعدة البيانات المحلية
/// هذه نسخة أولية تستخدم SharedPreferences مؤقتاً
/// سيتم استبدالها بـ Drift/SQLite في المرحلة التاسعة
class LocalDatabaseService {
  LocalDatabaseService._();
  static final LocalDatabaseService instance = LocalDatabaseService._();

  SharedPreferences? _prefs;

  Future<void> init() async {
    try {
      _prefs = await SharedPreferences.getInstance();
    } catch (e) {
      debugPrint('LocalDatabaseService init error: $e');
    }
  }

  SharedPreferences? get prefs => _prefs;

  // ===== عمليات التخزين الأساسية =====
  Future<bool> setString(String key, String value) async {
    return await _prefs?.setString(key, value) ?? false;
  }

  String? getString(String key) => _prefs?.getString(key);

  Future<bool> setBool(String key, bool value) async {
    return await _prefs?.setBool(key, value) ?? false;
  }

  bool? getBool(String key) => _prefs?.getBool(key);

  Future<bool> remove(String key) async {
    return await _prefs?.remove(key) ?? false;
  }

  Future<bool> clear() async {
    return await _prefs?.clear() ?? false;
  }

  // ===== قائمة انتظار المزامنة =====
  Future<void> addPendingSync(Map<String, dynamic> operation) async {
    final existing = _prefs?.getStringList('pending_sync') ?? [];
    // TODO: تحويل operation إلى JSON string وإضافته
    await _prefs?.setStringList('pending_sync', existing);
  }

  List<String> getPendingSync() {
    return _prefs?.getStringList('pending_sync') ?? [];
  }

  Future<void> clearPendingSync() async {
    await _prefs?.remove('pending_sync');
  }
}
