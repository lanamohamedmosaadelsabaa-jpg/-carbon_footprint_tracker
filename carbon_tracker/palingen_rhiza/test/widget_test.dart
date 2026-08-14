import 'package:flutter_test/flutter_test.dart';
import 'package:palingen_rhiza/main.dart';

void main() {
  testWidgets('app loads without crashing', (WidgetTester tester) async {
    await tester.pumpWidget(const PalingenRhizaApp());

    expect(find.text('Palingen Rhiza'), findsWidgets);
  });
}
