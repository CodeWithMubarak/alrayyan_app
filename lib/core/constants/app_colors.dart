/// ثوابت الألوان والهوية البصرية لتطبيق حلقات مسجد الريان
class AppColors {
  AppColors._();

  // ===== الألوان الأساسية =====
  static const int primaryGreenDark = 0xFF103D32;    // أخضر زمردي داكن (الهوية الجديدة)
  static const int primaryGreen = 0xFF103D32;        // اللون الأساسي
  static const int primaryGreenLight = 0xFF2E7D32;   // أخضر فاتح
  static const int primaryGreenSoft = 0xFF81C784;    // أخضر هادئ
  static const int goldDark = 0xFFB8860B;            // ذهبي داكن
  static const int gold = 0xFFC6A45C;                // ذهبي هادئ للتميز والإنجاز
  static const int goldAccent = 0xFFC6A45C;          // لون التميز والإنجاز
  static const int goldLight = 0xFFD4A843;           // ذهبي فاتح
  static const int goldSoft = 0xFFF5D87E;            // ذهبي ناعم

  // ===== الألوان المحايدة =====
  static const int white = 0xFFFFFFFF;
  static const int offWhite = 0xFFF8F9FA;
  static const int lightGrey = 0xFFF5F5F5;
  static const int grey100 = 0xFFF5F5F5;
  static const int grey200 = 0xFFEEEEEE;
  static const int grey300 = 0xFFE0E0E0;
  static const int grey400 = 0xFFBDBDBD;
  static const int grey500 = 0xFF9E9E9E;
  static const int grey600 = 0xFF757575;
  static const int grey700 = 0xFF616161;
  static const int grey800 = 0xFF424242;
  static const int grey900 = 0xFF212121;
  static const int black = 0xFF000000;

  // ===== ألوان الحالات =====
  static const int success = 0xFF2E7D32;
  static const int successLight = 0xFFE8F5E9;
  static const int warning = 0xFFF57F17;
  static const int warningLight = 0xFFFFF8E1;
  static const int error = 0xFFC62828;
  static const int errorLight = 0xFFFFEBEE;
  static const int info = 0xFF01579B;
  static const int infoLight = 0xFFE1F5FE;

  // ===== ألوان الوضع الداكن =====
  static const int darkBackground = 0xFF121212;
  static const int darkSurface = 0xFF1E1E1E;
  static const int darkCard = 0xFF2C2C2C;
  static const int darkDivider = 0xFF3A3A3A;

  // ===== ألوان حالات الحضور =====
  static const int present = 0xFF2E7D32;        // حاضر - أخضر
  static const int absent = 0xFFC62828;         // غائب - أحمر
  static const int late = 0xFFF57F17;           // متأخر - برتقالي
  static const int excusedAbsent = 0xFF01579B;  // غياب بعذر - أزرق

  // ===== ألوان الرسوم =====
  static const int feePaid = 0xFF2E7D32;
  static const int feePartial = 0xFFF57F17;
  static const int feeUnpaid = 0xFFC62828;
  static const int feeExempt = 0xFF546E7A;
}
