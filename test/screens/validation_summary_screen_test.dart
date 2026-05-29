import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:iwbf_team_points_control/models/player.dart';
import 'package:iwbf_team_points_control/models/team.dart';
import 'package:iwbf_team_points_control/screens/validation_summary_screen.dart';
import 'package:iwbf_team_points_control/services/spreadsheet_parser_service.dart';

Future<void> _pump(WidgetTester tester, SpreadsheetParseResult result) async {
  await tester.pumpWidget(MaterialApp(
    home: ValidationSummaryScreen(result: result),
  ));
}

Player _p(String id, int n, double cls) => Player(
      id: id,
      teamName: 'Brazil',
      shirtNumber: n,
      name: 'First P$id',
      playerClass: cls,
    );

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('cabeçalho mostra competition e contagens',
      (WidgetTester tester) async {
    final SpreadsheetParseResult result = SpreadsheetParseResult(
      teams: <Team>[
        Team(
          id: 'team-brazil',
          teamName: 'Brazil',
          players: <Player>[_p('p1', 7, 2.5), _p('p2', 9, 4.0)],
        ),
      ],
      issues: const <ParseIssue>[],
      competitionName: 'Americas Championship',
    );
    await _pump(tester, result);
    await tester.pumpAndSettle();

    expect(find.textContaining('Americas Championship'), findsOneWidget);
    expect(find.text('1 Teams'), findsOneWidget);
    expect(find.text('2 Players'), findsOneWidget);
    expect(find.textContaining('loaded successfully'), findsOneWidget);
  });

  testWidgets('botão Continue habilitado quando não há erros',
      (WidgetTester tester) async {
    final SpreadsheetParseResult result = SpreadsheetParseResult(
      teams: <Team>[
        Team(id: 'team-brazil', teamName: 'Brazil', players: <Player>[_p('p1', 7, 2.5)]),
      ],
      issues: const <ParseIssue>[],
    );
    await _pump(tester, result);
    await tester.pumpAndSettle();

    final Finder cont = find.byKey(const Key('continue-button'));
    expect(cont, findsOneWidget);
    final FilledButton button = tester.widget<FilledButton>(cont);
    expect(button.onPressed, isNotNull);
  });

  testWidgets('botão Continue desabilitado quando há erros bloqueantes',
      (WidgetTester tester) async {
    const SpreadsheetParseResult result = SpreadsheetParseResult(
      teams: <Team>[],
      issues: <ParseIssue>[
        ParseIssue(
          category: ParseIssueCategory.missingShirtNumber,
          severity: ParseIssueSeverity.error,
          message: 'Player is missing shirt number',
        ),
      ],
    );
    await _pump(tester, result);
    await tester.pumpAndSettle();

    final FilledButton button =
        tester.widget<FilledButton>(find.byKey(const Key('continue-button')));
    expect(button.onPressed, isNull);
    expect(find.textContaining('fix before continuing'), findsOneWidget);
  });

  testWidgets('mostra warnings em bloco separado quando existem',
      (WidgetTester tester) async {
    final SpreadsheetParseResult result = SpreadsheetParseResult(
      teams: <Team>[
        Team(id: 'team-atlantis', teamName: 'Atlantis', players: <Player>[_p('p1', 7, 2.5)]),
      ],
      issues: const <ParseIssue>[
        ParseIssue(
          category: ParseIssueCategory.unknownTeam,
          severity: ParseIssueSeverity.warning,
          message: 'Unknown team: "Atlantis"',
        ),
      ],
    );
    await _pump(tester, result);
    await tester.pumpAndSettle();

    expect(find.textContaining('Warnings'), findsOneWidget);
    expect(find.textContaining('Atlantis'), findsWidgets);
  });

  testWidgets('botão View Issues abre MissingDataScreen',
      (WidgetTester tester) async {
    const SpreadsheetParseResult result = SpreadsheetParseResult(
      teams: <Team>[],
      issues: <ParseIssue>[
        ParseIssue(
          category: ParseIssueCategory.missingShirtNumber,
          severity: ParseIssueSeverity.error,
          message: 'Player is missing shirt number',
          playerLabel: 'SILVA, João',
        ),
      ],
    );
    await _pump(tester, result);
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('view-issues-button')));
    await tester.pumpAndSettle();

    expect(find.text('Missing Data'), findsOneWidget);
  });

  testWidgets('excluir atleta remove a linha e atualiza a contagem',
      (WidgetTester tester) async {
    final SpreadsheetParseResult result = SpreadsheetParseResult(
      teams: <Team>[
        Team(
          id: 'team-brazil',
          teamName: 'Brazil',
          players: <Player>[_p('p1', 7, 2.5), _p('p2', 9, 4.0)],
        ),
      ],
      issues: const <ParseIssue>[],
    );
    await _pump(tester, result);
    await tester.pumpAndSettle();

    expect(find.text('2 Players'), findsOneWidget);

    await tester.tap(find.byKey(const Key('team-tile-team-brazil')));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('delete-player-p1')));
    await tester.pumpAndSettle();

    expect(find.text('Remove player?'), findsOneWidget);
    await tester.tap(find.widgetWithText(FilledButton, 'Remove'));
    await tester.pumpAndSettle();

    expect(find.text('1 Players'), findsOneWidget);
  });

  testWidgets('excluir equipe remove o card e desabilita Continue',
      (WidgetTester tester) async {
    final SpreadsheetParseResult result = SpreadsheetParseResult(
      teams: <Team>[
        Team(
          id: 'team-brazil',
          teamName: 'Brazil',
          players: <Player>[_p('p1', 7, 2.5)],
        ),
      ],
      issues: const <ParseIssue>[],
    );
    await _pump(tester, result);
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('team-tile-team-brazil')));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('delete-team-team-brazil')));
    await tester.pumpAndSettle();

    expect(find.text('Delete team?'), findsOneWidget);
    await tester.tap(find.widgetWithText(FilledButton, 'Delete'));
    await tester.pumpAndSettle();

    expect(find.text('0 Teams'), findsOneWidget);
    final FilledButton button = tester
        .widget<FilledButton>(find.byKey(const Key('continue-button')));
    expect(button.onPressed, isNull);
  });
}
