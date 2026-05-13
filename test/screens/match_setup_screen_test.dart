import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:iwbf_team_points_control/models/match_state.dart';
import 'package:iwbf_team_points_control/models/player.dart';
import 'package:iwbf_team_points_control/models/team.dart';
import 'package:iwbf_team_points_control/screens/match_setup_screen.dart';

Player _p(String id, int n, double cls) => Player(
      id: id,
      teamName: 'Brazil',
      shirtNumber: n,
      surname: 'P$id',
      firstName: 'First',
      playerClass: cls,
    );

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('mostra teams e nome da competição quando recebe lista',
      (WidgetTester tester) async {
    final List<Team> teams = <Team>[
      Team(id: 'team-brazil', teamName: 'Brazil', players: <Player>[_p('p1', 7, 2.5)]),
      Team(id: 'team-argentina', teamName: 'Argentina'),
    ];
    await tester.pumpWidget(MaterialApp(
      home: MatchSetupScreen(
        teams: teams,
        competitionName: 'Americas Championship',
      ),
    ));
    await tester.pumpAndSettle();

    expect(find.text('Match Setup'), findsOneWidget);
    expect(find.textContaining('Americas Championship'), findsOneWidget);
    expect(find.text('Teams available: 2'), findsOneWidget);
    expect(find.text('Brazil'), findsOneWidget);
    expect(find.text('Argentina'), findsOneWidget);
  });

  testWidgets('mostra teams quando recebe MatchState restaurado',
      (WidgetTester tester) async {
    final MatchState restored = MatchState(
      teamA: Team(id: 'team-brazil', teamName: 'Brazil'),
      teamB: Team(id: 'team-argentina', teamName: 'Argentina'),
      competitionName: 'Cached Match',
    );
    await tester.pumpWidget(MaterialApp(
      home: MatchSetupScreen(restored: restored),
    ));
    await tester.pumpAndSettle();

    expect(find.textContaining('Cached Match'), findsOneWidget);
    expect(find.text('Teams available: 2'), findsOneWidget);
  });

  testWidgets('mostra aviso de placeholder da Fase 3',
      (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
      home: MatchSetupScreen(teams: <Team>[
        Team(id: 'team-brazil', teamName: 'Brazil'),
      ]),
    ));
    await tester.pumpAndSettle();

    expect(find.textContaining('Phase 3'), findsOneWidget);
  });
}
