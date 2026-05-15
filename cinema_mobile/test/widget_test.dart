// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.



void main() {
<<<<<<< HEAD
  testWidgets('Cinema app opens the login page', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const CinemaApp());

    expect(find.text('CINEMA TICKET'), findsOneWidget);
    expect(find.text('SIGN IN'), findsOneWidget);
=======
  testWidgets('App loads without crashing', (WidgetTester tester) async {
    // Build the application and trigger a frame.
    await tester.pumpWidget(const CinemaApp());
    await tester.pumpAndSettle();

    // Verify the app widget tree loads correctly.
    expect(find.byType(CinemaApp), findsOneWidget);
>>>>>>> 3033a92229b4c4e5e34d9bff2d3a12d403efb7ee
  });
}
