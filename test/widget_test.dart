import 'package:flutter_test/flutter_test.dart';
import 'package:vitalis_appointments/main.dart';

void main() {
  testWidgets('App renders smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const VitalisApp());
    // Verify the app renders without errors
    expect(find.text('Vitalis Appointments'), findsAny);
  });
}
