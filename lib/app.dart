import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'core/theme/app_theme.dart';
import 'core/routing/app_router.dart';
import 'core/constants/app_strings.dart';

/// سلوك التمرير المحسن لتمكين التمرير باللمس والماوس ولوحة التتبع في كل الشاشات والويب
class AppScrollBehavior extends MaterialScrollBehavior {
  const AppScrollBehavior();

  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
        PointerDeviceKind.trackpad,
        PointerDeviceKind.stylus,
        PointerDeviceKind.unknown,
      };
}

class AlRayyanApp extends ConsumerWidget {
  const AlRayyanApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp.router(
      title: AppStrings.appName,
      debugShowCheckedModeBanner: false,
      scrollBehavior: const AppScrollBehavior(),

      // RTL & Arabic Support
      locale: const Locale('ar', 'SA'),
      supportedLocales: const [
        Locale('ar', 'SA'),
        Locale('en', 'US'),
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],

      // Theme
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,

      // Router
      routerConfig: router,

      // Responsive Framework
      builder: (context, child) {
        return ResponsiveBreakpoints.builder(
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: child ?? const SizedBox.shrink(),
          ),
          breakpoints: [
            const Breakpoint(start: 0, end: 450, name: MOBILE),
            const Breakpoint(start: 451, end: 800, name: TABLET),
            const Breakpoint(start: 801, end: 1920, name: DESKTOP),
            const Breakpoint(start: 1921, end: double.infinity, name: '4K'),
          ],
        );
      },
    );
  }
}

// Theme mode provider
final themeModeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.light);
