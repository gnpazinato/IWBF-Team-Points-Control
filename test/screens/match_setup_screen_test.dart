import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:iwbf_team_points_control/constants/point_limits.dart';
import 'package:iwbf_team_points_control/models/match_state.dart';
import 'package:iwbf_team_points_control/models/player.dart';
import 'package:iwbf_team_points_control/models/team.dart';
import 'package:iwbf_team_points_control/screens/match_setup_screen.dart';

Player _player(String teamId, int shirt, double cls) => Player(
      id: '$teamId::$shirt',
      teamName: teamId,
      shirtNumber: shirt,
      name: 'Surname$shirt',
      playerClass: cls,
    );

Team _team(String id, String name,
        {int playerCount = 1, TeamGender gender = TeamGender.unspecified}) =>
    Team(
      id: id,
      teamName: name,
      gender: gender,
      players: <Player>[
        for (int i = 0; i < playerCount; i++) _player(id, i + 1, 2.5),
      ],
    );

Future<void> _selectFromDropdown(
  WidgetTester tester, {
  required Key dropdownKey,
  required String optionText,
}) async {
  await tester.ensureVisible(find.byKey(dropdownKey));
  await tester.pumpAndSettle();
  await tester.tap(find.byKey(dropdownKey));
  await tester.pumpAndSettle();
  await tester.tap(find.text(optionText).last);
  await tester.pumpAndSettle();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('MatchSetupScreen — initial render', () {
    testWidgets('renderiza dropdowns e default Point Limit 14.0',
        (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        home: MatchSetupScreen(
          teams: <Team>[
            _team('team-brazil', 'Brazil'),
            _team('team-argentina', 'Argentina'),
          ],
          competitionName: 'Americas Championship',
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Match Setup'), findsOneWidget);
      expect(find.text('Competition: Americas Championship'), findsOneWidget);
      expect(find.text('Select Team A'), findsOneWidget);
      expect(find.text('Select Team B'), findsOneWidget);
      expect(find.text('Point Limit'), findsOneWidget);
      expect(find.text('14.0'), findsOneWidget);
    });

    testWidgets('Start Match começa desabilitado quando nada foi escolhido',
        (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        home: MatchSetupScreen(teams: <Team>[
          _team('team-brazil', 'Brazil'),
          _team('team-argentina', 'Argentina'),
        ]),
      ));
      await tester.pumpAndSettle();

      final FilledButton button = tester.widget<FilledButton>(
        find.byKey(const Key('start-match-button')),
      );
      expect(button.onPressed, isNull);
    });

    testWidgets('mensagem de fallback aparece quando não há teams',
        (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: MatchSetupScreen(teams: <Team>[]),
      ));
      await tester.pumpAndSettle();

      expect(
        find.text('No teams loaded. Go back and import a spreadsheet.'),
        findsOneWidget,
      );
      final FilledButton button = tester.widget<FilledButton>(
        find.byKey(const Key('start-match-button')),
      );
      expect(button.onPressed, isNull);
    });
  });

  group('MatchSetupScreen — Team A vs Team B selection', () {
    testWidgets('seleção válida habilita Start Match',
        (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        home: MatchSetupScreen(teams: <Team>[
          _team('team-brazil', 'Brazil'),
          _team('team-argentina', 'Argentina'),
        ]),
      ));
      await tester.pumpAndSettle();

      await _selectFromDropdown(
        tester,
        dropdownKey: const Key('team-a-dropdown'),
        optionText: 'Brazil',
      );
      await _selectFromDropdown(
        tester,
        dropdownKey: const Key('team-b-dropdown'),
        optionText: 'Argentina',
      );

      final FilledButton button = tester.widget<FilledButton>(
        find.byKey(const Key('start-match-button')),
      );
      expect(button.onPressed, isNotNull);
      expect(find.byKey(const Key('teams-equal-error')), findsNothing);
    });

    testWidgets(
        'escolher mesma equipe em ambos exibe erro e mantém Start desabilitado',
        (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        home: MatchSetupScreen(teams: <Team>[
          _team('team-brazil', 'Brazil'),
          _team('team-argentina', 'Argentina'),
        ]),
      ));
      await tester.pumpAndSettle();

      await _selectFromDropdown(
        tester,
        dropdownKey: const Key('team-a-dropdown'),
        optionText: 'Brazil',
      );
      await _selectFromDropdown(
        tester,
        dropdownKey: const Key('team-b-dropdown'),
        optionText: 'Brazil',
      );

      expect(find.byKey(const Key('teams-equal-error')), findsOneWidget);
      final FilledButton button = tester.widget<FilledButton>(
        find.byKey(const Key('start-match-button')),
      );
      expect(button.onPressed, isNull);
    });
  });

  group('MatchSetupScreen — Point Limit dropdown', () {
    testWidgets('lista todos os limites aceitos no dropdown',
        (WidgetTester tester) async {
      // Viewport alta para que o overlay do dropdown caiba os 19
      // items (7.0..16.0 em 0.5) sem precisar de scroll lazy — em
      // viewport baixa, items fora da regiao visivel nao chegam a ser
      // buildados e `find.text(...)` retorna 0 widgets.
      tester.view.physicalSize = const Size(1200, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(MaterialApp(
        home: MatchSetupScreen(teams: <Team>[_team('t', 'T')]),
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('point-limit-dropdown')));
      await tester.pumpAndSettle();

      for (final double limit in kAcceptedPointLimits) {
        expect(find.text(limit.toStringAsFixed(1)), findsWidgets);
      }
    });

    testWidgets('mudança de Point Limit é refletida no Start payload',
        (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        home: MatchSetupScreen(teams: <Team>[
          _team('team-brazil', 'Brazil'),
          _team('team-argentina', 'Argentina'),
        ]),
      ));
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.byKey(const Key('point-limit-dropdown')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('point-limit-dropdown')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('15.5').last);
      await tester.pumpAndSettle();

      expect(find.text('15.5'), findsOneWidget);
    });
  });

  group('MatchSetupScreen — restored session', () {
    testWidgets('pré-preenche teams, point limit e competition do cache',
        (WidgetTester tester) async {
      final MatchState restored = MatchState(
        teamA: _team('team-brazil', 'Brazil'),
        teamB: _team('team-argentina', 'Argentina'),
        pointLimit: 15.0,
        competitionName: 'Cached Cup',
      );
      await tester.pumpWidget(MaterialApp(
        home: MatchSetupScreen(restored: restored),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Competition: Cached Cup'), findsOneWidget);
      expect(find.text('Brazil'), findsOneWidget);
      expect(find.text('Argentina'), findsOneWidget);
      expect(find.text('15.0'), findsOneWidget);
      final FilledButton button = tester.widget<FilledButton>(
        find.byKey(const Key('start-match-button')),
      );
      expect(button.onPressed, isNotNull);
    });
  });

  group('MatchSetupScreen — Start Match navigation', () {
    testWidgets('Start Match navega para LineupControlScreen',
        (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        home: MatchSetupScreen(teams: <Team>[
          _team('team-brazil', 'Brazil'),
          _team('team-argentina', 'Argentina'),
        ]),
      ));
      await tester.pumpAndSettle();

      await _selectFromDropdown(
        tester,
        dropdownKey: const Key('team-a-dropdown'),
        optionText: 'Brazil',
      );
      await _selectFromDropdown(
        tester,
        dropdownKey: const Key('team-b-dropdown'),
        optionText: 'Argentina',
      );

      await tester.tap(find.byKey(const Key('start-match-button')));
      await tester.pumpAndSettle();

      expect(find.text('Lineup Control'), findsOneWidget);
      // Header agora monta Brazil + vs + Argentina em widgets separados
      // para intercalar a bandeira de cada pais.
      expect(find.text('Brazil'), findsWidgets);
      expect(find.text('Argentina'), findsWidgets);
      expect(find.text('  vs  '), findsOneWidget);
      // Point Limit migrou para um menu na AppBar do Lineup.
      expect(find.byKey(const Key('lineup-point-limit-dropdown')),
          findsOneWidget);
    });
  });

  group('MatchSetupScreen — gender mismatch', () {
    testWidgets('Men vs Women mostra aviso inline e pede confirmação',
        (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        home: MatchSetupScreen(teams: <Team>[
          _team('team-brazil-men', 'Brazil', gender: TeamGender.men),
          _team('team-argentina-women', 'Argentina',
              gender: TeamGender.women),
        ]),
      ));
      await tester.pumpAndSettle();

      await _selectFromDropdown(
        tester,
        dropdownKey: const Key('team-a-dropdown'),
        optionText: 'Brazil - Men',
      );
      await _selectFromDropdown(
        tester,
        dropdownKey: const Key('team-b-dropdown'),
        optionText: 'Argentina - Women',
      );

      expect(find.byKey(const Key('gender-mismatch-warning')), findsOneWidget);

      await tester.tap(find.byKey(const Key('start-match-button')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('gender-mismatch-dialog')), findsOneWidget);
      expect(find.byKey(const Key('gender-mismatch-cancel')), findsOneWidget);
      expect(
          find.byKey(const Key('gender-mismatch-continue')), findsOneWidget);
    });

    testWidgets('Cancel no diálogo mantém o usuário na tela de setup',
        (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        home: MatchSetupScreen(teams: <Team>[
          _team('team-brazil-men', 'Brazil', gender: TeamGender.men),
          _team('team-argentina-women', 'Argentina',
              gender: TeamGender.women),
        ]),
      ));
      await tester.pumpAndSettle();

      await _selectFromDropdown(
        tester,
        dropdownKey: const Key('team-a-dropdown'),
        optionText: 'Brazil - Men',
      );
      await _selectFromDropdown(
        tester,
        dropdownKey: const Key('team-b-dropdown'),
        optionText: 'Argentina - Women',
      );

      await tester.tap(find.byKey(const Key('start-match-button')));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('gender-mismatch-cancel')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('gender-mismatch-dialog')), findsNothing);
      expect(find.text('Match Setup'), findsOneWidget);
      expect(find.text('Lineup Control'), findsNothing);
    });

    testWidgets('Continue anyway segue para a partida',
        (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        home: MatchSetupScreen(teams: <Team>[
          _team('team-brazil-men', 'Brazil', gender: TeamGender.men),
          _team('team-argentina-women', 'Argentina',
              gender: TeamGender.women),
        ]),
      ));
      await tester.pumpAndSettle();

      await _selectFromDropdown(
        tester,
        dropdownKey: const Key('team-a-dropdown'),
        optionText: 'Brazil - Men',
      );
      await _selectFromDropdown(
        tester,
        dropdownKey: const Key('team-b-dropdown'),
        optionText: 'Argentina - Women',
      );

      await tester.tap(find.byKey(const Key('start-match-button')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('gender-mismatch-continue')));
      await tester.pumpAndSettle();

      expect(find.text('Lineup Control'), findsOneWidget);
    });

    testWidgets('Men vs Men não dispara aviso nem diálogo',
        (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        home: MatchSetupScreen(teams: <Team>[
          _team('team-brazil-men', 'Brazil', gender: TeamGender.men),
          _team('team-argentina-men', 'Argentina', gender: TeamGender.men),
        ]),
      ));
      await tester.pumpAndSettle();

      await _selectFromDropdown(
        tester,
        dropdownKey: const Key('team-a-dropdown'),
        optionText: 'Brazil - Men',
      );
      await _selectFromDropdown(
        tester,
        dropdownKey: const Key('team-b-dropdown'),
        optionText: 'Argentina - Men',
      );

      expect(find.byKey(const Key('gender-mismatch-warning')), findsNothing);

      await tester.tap(find.byKey(const Key('start-match-button')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('gender-mismatch-dialog')), findsNothing);
      expect(find.text('Lineup Control'), findsOneWidget);
    });
  });
}
