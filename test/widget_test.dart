import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kooyoh_app/core/blacklight_app.dart';

void main() {
  testWidgets('KOO-YOH app renders', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: KooyohApp()),
    );
    expect(find.byType(KooyohApp), findsOneWidget);
  });
}
