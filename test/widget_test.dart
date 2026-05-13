import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:iwbf_team_points_control/main.dart';

void main() {
  testWidgets('App boots and shows scaffold text', (WidgetTester tester) async {
    await tester.pumpWidget(const IwbfApp());
    expect(find.byType(MaterialApp), findsOneWidget);
    expect(find.textContaining('Scaffold inicial'), findsOneWidget);
  });
}
