import 'package:challenge_app/app/app.dart';
import 'package:challenge_app/app/di/locator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    await locator.reset();
    await setupLocator();
  });

  testWidgets('Home shell shows feature entries', (tester) async {
    await tester.pumpWidget(const ChallengeApp());
    expect(find.text('Challenge App'), findsOneWidget);
    expect(find.text('Notifications'), findsOneWidget);
    expect(find.text('Organisations'), findsOneWidget);
    expect(find.text('Users'), findsOneWidget);
  });
}
