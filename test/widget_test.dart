import 'package:flutter_test/flutter_test.dart';
import 'package:aura_glide/app.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const AuraGlideApp());
    await tester.pump();
  });
}