import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:limye_app/core/blacklight_app.dart';

void main() {
  testWidgets('LIMYÈ app renders', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: LimyeApp()),
    );
    expect(find.byType(LimyeApp), findsOneWidget);
  });
}
