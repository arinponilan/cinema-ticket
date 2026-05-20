import 'package:cinema_mobile/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Cinema app opens the login page', (WidgetTester tester) async {
    await tester.pumpWidget(const CinemaApp());

    expect(find.text('TIXTIX PREMIERE'), findsOneWidget);
    expect(find.text('SIGN IN'), findsOneWidget);
  });
}
