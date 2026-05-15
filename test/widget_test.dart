import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:iwbf_team_points_control/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  testWidgets('App boots into LoadSpreadsheetScreen', (WidgetTester tester) async {
    await tester.pumpWidget(const IwbfApp());
    expect(find.byType(MaterialApp), findsOneWidget);
    expect(find.text('IWBF Team Points Control'), findsOneWidget);
    expect(find.text('Load Reference Spreadsheet'), findsOneWidget);
  });
}
