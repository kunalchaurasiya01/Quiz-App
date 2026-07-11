import 'package:flutter_test/flutter_test.dart';
import 'package:quiz_app/main.dart';

void main() {
  testWidgets('Quiz App smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(QuizApp());

    // Verify that the title / welcome text is displayed.
    expect(find.textContaining('Welcome to the Delhi University Quiz'), findsOneWidget);
    expect(find.text('Start Quiz'), findsOneWidget);
  });
}
