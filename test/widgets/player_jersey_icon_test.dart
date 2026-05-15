import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:iwbf_team_points_control/models/player.dart';
import 'package:iwbf_team_points_control/widgets/player_jersey_icon.dart';

Player _player({
  PlayerGender gender = PlayerGender.unspecified,
  int shirt = 7,
}) =>
    Player(
      id: 'team-x::$shirt',
      teamName: 'Team X',
      shirtNumber: shirt,
      surname: 'Silva',
      firstName: 'João',
      playerClass: 2.5,
      gender: gender,
    );

void main() {
  group('PlayerJerseyIcon (vetor)', () {
    testWidgets('exibe o numero da camiseta sobre o desenho',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: PlayerJerseyIcon(
                player: _player(shirt: 12),
                isTeamA: true,
              ),
            ),
          ),
        ),
      );

      expect(find.text('12'), findsOneWidget);
      expect(find.byType(CustomPaint), findsWidgets);
    });

    testWidgets('renderiza numero diferente quando o shirtNumber muda',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Row(
              children: <Widget>[
                PlayerJerseyIcon(player: _player(shirt: 4), isTeamA: true),
                PlayerJerseyIcon(player: _player(shirt: 23), isTeamA: false),
              ],
            ),
          ),
        ),
      );

      expect(find.text('4'), findsOneWidget);
      expect(find.text('23'), findsOneWidget);
    });

    testWidgets('numero usa cor escura no Team A (camiseta clara)',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PlayerJerseyIcon(player: _player(shirt: 9), isTeamA: true),
          ),
        ),
      );

      final Text text = tester.widget(find.text('9'));
      // No Team A o texto deve ser escuro (preto/textPrimary).
      expect(text.style?.color, isNot(equals(Colors.white)));
    });

    testWidgets('numero usa cor branca no Team B (camiseta escura)',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PlayerJerseyIcon(player: _player(shirt: 9), isTeamA: false),
          ),
        ),
      );

      final Text text = tester.widget(find.text('9'));
      expect(text.style?.color, equals(Colors.white));
    });

    testWidgets('o desenho nao depende de PNG (zero Image widgets)',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PlayerJerseyIcon(
              player: _player(),
              isTeamA: true,
            ),
          ),
        ),
      );

      expect(find.byType(Image), findsNothing);
    });
  });
}
