import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:blacklight_app/core/blacklight_app.dart';

void main() {
  testWidgets('Black Light app renders', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: BlackLightApp()),
    );
    expect(find.byType(BlackLightApp), findsOneWidget);
  });
}
