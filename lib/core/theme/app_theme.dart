import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

/// ثيم التطبيق - الهوية البصرية لحلقات مسجد الريان
class AppTheme {
  AppTheme._();

  // ===== الثيم الفاتح =====
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: const ColorScheme.light(
        primary: Color(AppColors.primaryGreen),
        primaryContainer: Color(AppColors.primaryGreenLight),
        secondary: Color(AppColors.gold),
        secondaryContainer: Color(AppColors.goldSoft),
        surface: Color(AppColors.white),
        error: Color(AppColors.error),
        onPrimary: Color(AppColors.white),
        onSecondary: Color(AppColors.white),
        onSurface: Color(AppColors.grey900),
        onError: Color(AppColors.white),
        outline: Color(AppColors.grey300),
      ),

      textTheme: _buildTextTheme(const Color(AppColors.grey900)),
      fontFamily: 'Cairo',

      appBarTheme: const AppBarTheme(
        backgroundColor: Color(AppColors.primaryGreen),
        foregroundColor: Color(AppColors.white),
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontFamily: 'Cairo',
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: Color(AppColors.white),
        ),
        iconTheme: IconThemeData(color: Color(AppColors.white)),
      ),

      drawerTheme: const DrawerThemeData(
        backgroundColor: Color(AppColors.white),
        elevation: 2,
      ),

      cardTheme: CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        color: const Color(AppColors.white),
        shadowColor: const Color(AppColors.primaryGreen).withAlpha(25),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(AppColors.primaryGreen),
          foregroundColor: const Color(AppColors.white),
          elevation: 2,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          textStyle: const TextStyle(
            fontFamily: 'Cairo',
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(AppColors.primaryGreen),
          side: const BorderSide(color: Color(AppColors.primaryGreen), width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          textStyle: const TextStyle(
            fontFamily: 'Cairo',
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: const Color(AppColors.primaryGreen),
          textStyle: const TextStyle(
            fontFamily: 'Cairo',
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(AppColors.grey100),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(AppColors.grey300)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(AppColors.grey300)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(AppColors.primaryGreen), width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(AppColors.error), width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(AppColors.error), width: 2),
        ),
        labelStyle: const TextStyle(
          fontFamily: 'Cairo',
          color: Color(AppColors.grey600),
          fontSize: 14,
        ),
        hintStyle: const TextStyle(
          fontFamily: 'Cairo',
          color: Color(AppColors.grey400),
          fontSize: 14,
        ),
        errorStyle: const TextStyle(
          fontFamily: 'Cairo',
          color: Color(AppColors.error),
          fontSize: 12,
        ),
        prefixIconColor: const Color(AppColors.primaryGreen),
        suffixIconColor: const Color(AppColors.grey500),
      ),

      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Color(AppColors.white),
        selectedItemColor: Color(AppColors.primaryGreen),
        unselectedItemColor: Color(AppColors.grey500),
        type: BottomNavigationBarType.fixed,
        elevation: 8,
        selectedLabelStyle: TextStyle(fontFamily: 'Cairo', fontSize: 11, fontWeight: FontWeight.w600),
        unselectedLabelStyle: TextStyle(fontFamily: 'Cairo', fontSize: 11),
      ),

      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: const Color(AppColors.white),
        indicatorColor: const Color(AppColors.primaryGreenSoft).withAlpha(75),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: Color(AppColors.primaryGreen));
          }
          return const IconThemeData(color: Color(AppColors.grey500));
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const TextStyle(fontFamily: 'Cairo', fontSize: 11, fontWeight: FontWeight.w700, color: Color(AppColors.primaryGreen));
          }
          return const TextStyle(fontFamily: 'Cairo', fontSize: 11, color: Color(AppColors.grey500));
        }),
      ),

      dialogTheme: DialogThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        titleTextStyle: const TextStyle(fontFamily: 'Cairo', fontSize: 18, fontWeight: FontWeight.w700, color: Color(AppColors.grey900)),
        contentTextStyle: const TextStyle(fontFamily: 'Cairo', fontSize: 14, color: Color(AppColors.grey700)),
        elevation: 8,
      ),

      tabBarTheme: const TabBarThemeData(
        labelColor: Color(AppColors.primaryGreen),
        unselectedLabelColor: Color(AppColors.grey500),
        indicatorColor: Color(AppColors.primaryGreen),
        indicatorSize: TabBarIndicatorSize.tab,
        labelStyle: TextStyle(fontFamily: 'Cairo', fontSize: 13, fontWeight: FontWeight.w700),
        unselectedLabelStyle: TextStyle(fontFamily: 'Cairo', fontSize: 13),
      ),

      scaffoldBackgroundColor: const Color(AppColors.offWhite),
    );
  }

  // ===== الثيم الداكن =====
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: Color(AppColors.primaryGreenLight),
        primaryContainer: Color(AppColors.primaryGreen),
        secondary: Color(AppColors.goldLight),
        secondaryContainer: Color(AppColors.goldDark),
        surface: Color(AppColors.darkSurface),
        error: Color(0xFFEF9A9A),
        onPrimary: Color(AppColors.white),
        onSecondary: Color(AppColors.black),
        onSurface: Color(AppColors.grey100),
        onError: Color(AppColors.black),
        outline: Color(AppColors.grey700),
      ),
      textTheme: _buildTextTheme(const Color(AppColors.grey100)),
      fontFamily: 'Cairo',
      scaffoldBackgroundColor: const Color(AppColors.darkBackground),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(AppColors.darkSurface),
        foregroundColor: Color(AppColors.white),
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(fontFamily: 'Cairo', fontSize: 18, fontWeight: FontWeight.w700, color: Color(AppColors.white)),
      ),
      cardTheme: CardThemeData(
        color: const Color(AppColors.darkCard),
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      drawerTheme: const DrawerThemeData(backgroundColor: Color(AppColors.darkSurface)),
    );
  }

  static TextTheme _buildTextTheme(Color textColor) {
    return TextTheme(
      displayLarge: TextStyle(fontFamily: 'Cairo', fontSize: 57, fontWeight: FontWeight.w400, color: textColor),
      displayMedium: TextStyle(fontFamily: 'Cairo', fontSize: 45, fontWeight: FontWeight.w400, color: textColor),
      displaySmall: TextStyle(fontFamily: 'Cairo', fontSize: 36, fontWeight: FontWeight.w400, color: textColor),
      headlineLarge: TextStyle(fontFamily: 'Cairo', fontSize: 32, fontWeight: FontWeight.w700, color: textColor),
      headlineMedium: TextStyle(fontFamily: 'Cairo', fontSize: 28, fontWeight: FontWeight.w700, color: textColor),
      headlineSmall: TextStyle(fontFamily: 'Cairo', fontSize: 24, fontWeight: FontWeight.w600, color: textColor),
      titleLarge: TextStyle(fontFamily: 'Cairo', fontSize: 22, fontWeight: FontWeight.w600, color: textColor),
      titleMedium: TextStyle(fontFamily: 'Cairo', fontSize: 16, fontWeight: FontWeight.w600, color: textColor),
      titleSmall: TextStyle(fontFamily: 'Cairo', fontSize: 14, fontWeight: FontWeight.w600, color: textColor),
      bodyLarge: TextStyle(fontFamily: 'Cairo', fontSize: 16, fontWeight: FontWeight.w400, color: textColor),
      bodyMedium: TextStyle(fontFamily: 'Cairo', fontSize: 14, fontWeight: FontWeight.w400, color: textColor),
      bodySmall: TextStyle(fontFamily: 'Cairo', fontSize: 12, fontWeight: FontWeight.w400, color: textColor),
      labelLarge: TextStyle(fontFamily: 'Cairo', fontSize: 14, fontWeight: FontWeight.w600, color: textColor),
      labelMedium: TextStyle(fontFamily: 'Cairo', fontSize: 12, fontWeight: FontWeight.w600, color: textColor),
      labelSmall: TextStyle(fontFamily: 'Cairo', fontSize: 11, fontWeight: FontWeight.w500, color: textColor),
    );
  }
}
