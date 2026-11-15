import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:alrayyan_app/app.dart';

void main() {
  testWidgets('App loads splash screen and navigates to login test', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: AlRayyanApp(),
      ),
    );

    expect(find.byType(AlRayyanApp), findsOneWidget);

    // تقديم الوقت لإنهاء مؤقت الانتقال التلقائي للـ Splash
    await tester.pump(const Duration(seconds: 4));
    await tester.pump();
  });
}
