import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:iwbf_team_points_control/models/team.dart';
import 'package:iwbf_team_points_control/screens/missing_data_screen.dart';
import 'package:iwbf_team_points_control/services/spreadsheet_parser_service.dart';

Future<void> _pump(WidgetTester tester, SpreadsheetParseResult result) async {
  await tester.pumpWidget(MaterialApp(
    home: MissingDataScreen(result: result),
  ));
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('agrupa issues por categoria com hint apropriada',
      (WidgetTester tester) async {
    const SpreadsheetParseResult result = SpreadsheetParseResult(
      teams: <Team>[],
      issues: <ParseIssue>[
        ParseIssue(
          category: ParseIssueCategory.missingShirtNumber,
          severity: ParseIssueSeverity.error,
          message: 'Atleta sem número de camiseta',
          playerLabel: 'SILVA, João',
          teamName: 'Brazil',
          rowNumber: 2,
        ),
        ParseIssue(
          category: ParseIssueCategory.invalidPlayerClass,
          severity: ParseIssueSeverity.error,
          message: 'Classe funcional inválida para SOUZA, Pedro',
          playerLabel: 'SOUZA, Pedro',
          teamName: 'Brazil',
          rowNumber: 3,
        ),
      ],
    );
    await _pump(tester, result);
    await tester.pumpAndSettle();

    expect(find.text('Players missing shirt number (1)'), findsOneWidget);
    expect(find.text('Invalid player classes (1)'), findsOneWidget);
    expect(find.textContaining('Add a shirt number for each player'),
        findsOneWidget);
    expect(find.textContaining('Use only the IWBF values'), findsOneWidget);
    expect(find.textContaining('SILVA, João'), findsWidgets);
    expect(find.textContaining('Row: 2'), findsOneWidget);
  });

  testWidgets('mostra empty state quando não há issues bloqueantes',
      (WidgetTester tester) async {
    const SpreadsheetParseResult result = SpreadsheetParseResult(
      teams: <Team>[],
      issues: <ParseIssue>[
        ParseIssue(
          category: ParseIssueCategory.unknownTeam,
          severity: ParseIssueSeverity.warning,
          message: 'Equipe não reconhecida',
        ),
      ],
    );
    await _pump(tester, result);
    await tester.pumpAndSettle();

    expect(find.textContaining('No blocking issues to fix'), findsOneWidget);
  });

  testWidgets('mostra botão de voltar para o load', (WidgetTester tester) async {
    const SpreadsheetParseResult result = SpreadsheetParseResult(
      teams: <Team>[],
      issues: <ParseIssue>[
        ParseIssue(
          category: ParseIssueCategory.missingShirtNumber,
          severity: ParseIssueSeverity.error,
          message: 'Atleta sem número',
        ),
      ],
    );
    await _pump(tester, result);
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('back-to-load-button')), findsOneWidget);
    expect(find.text('Load Different Spreadsheet'), findsOneWidget);
  });
}
