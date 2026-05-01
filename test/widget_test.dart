import 'package:flutter_test/flutter_test.dart';

import 'package:drivingguide/main.dart';

void main() {
  testWidgets('Driving guide home renders', (WidgetTester tester) async {
    await tester.pumpWidget(const DrivingGuideApp());

    expect(find.text('Real-Time Roadside Audio Guide'), findsOneWidget);
    expect(find.text('Current Area'), findsOneWidget);
  });
}
