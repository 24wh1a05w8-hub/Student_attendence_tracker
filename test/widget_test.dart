import 'package:flutter_test/flutter_test.dart';
import 'package:attend_ease/main.dart';

void main() {
  testWidgets('Home screen shows the app title', (WidgetTester tester) async {
    await tester.pumpWidget(const AttendEaseApp());
    expect(find.text('AttendEase'), findsOneWidget);
    expect(find.text('Student Attendance Tracker'), findsOneWidget);
  });
}
