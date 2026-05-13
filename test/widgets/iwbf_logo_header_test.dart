import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:iwbf_team_points_control/widgets/iwbf_logo_header.dart';

void main() {
  group('IwbfBrandHeader', () {
    testWidgets('renderiza logo + título padrão', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: IwbfBrandHeader()),
        ),
      );

      expect(find.byKey(const Key('iwbf-brand-logo')), findsOneWidget);
      expect(find.text('IWBF Team Points Control'), findsOneWidget);
    });

    testWidgets('mostra subtitle quando fornecido', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: IwbfBrandHeader(
              subtitle: 'Wheelchair basketball — team points control',
            ),
          ),
        ),
      );

      expect(
        find.text('Wheelchair basketball — team points control'),
        findsOneWidget,
      );
    });

    testWidgets('aceita título customizado', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: IwbfBrandHeader(title: 'Custom Title')),
        ),
      );

      expect(find.text('Custom Title'), findsOneWidget);
      expect(find.text('IWBF Team Points Control'), findsNothing);
    });
  });

  group('IwbfAppBarTitle', () {
    testWidgets('renderiza logo pequeno + texto', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            appBar: AppBar(title: const IwbfAppBarTitle(text: 'My Screen')),
          ),
        ),
      );

      expect(find.byKey(const Key('iwbf-appbar-logo')), findsOneWidget);
      expect(find.text('My Screen'), findsOneWidget);
    });
  });
}
