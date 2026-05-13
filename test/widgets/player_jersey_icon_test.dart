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
  group('resolveJerseyAsset', () {
    test('Team A masculino', () {
      expect(
        resolveJerseyAsset(isTeamA: true, gender: PlayerGender.male),
        kTeamAMenAsset,
      );
    });
    test('Team A feminino', () {
      expect(
        resolveJerseyAsset(isTeamA: true, gender: PlayerGender.female),
        kTeamAWomenAsset,
      );
    });
    test('Team B masculino', () {
      expect(
        resolveJerseyAsset(isTeamA: false, gender: PlayerGender.male),
        kTeamBMenAsset,
      );
    });
    test('Team B feminino', () {
      expect(
        resolveJerseyAsset(isTeamA: false, gender: PlayerGender.female),
        kTeamBWomenAsset,
      );
    });
    test('gender unspecified cai no masculino (default da equipe)', () {
      expect(
        resolveJerseyAsset(isTeamA: true, gender: PlayerGender.unspecified),
        kTeamAMenAsset,
      );
      expect(
        resolveJerseyAsset(isTeamA: false, gender: PlayerGender.unspecified),
        kTeamBMenAsset,
      );
    });
  });

  group('PlayerJerseyIcon', () {
    testWidgets('exibe número da camiseta sobre o ícone',
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
      expect(find.byType(Image), findsOneWidget);
    });

    testWidgets('usa asset masculino para gender unspecified',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PlayerJerseyIcon(
              player: _player(),
              isTeamA: false,
            ),
          ),
        ),
      );

      final Image image = tester.widget(find.byType(Image));
      expect(
        (image.image as AssetImage).assetName,
        kTeamBMenAsset,
      );
    });

    testWidgets('usa asset feminino quando gender = female',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PlayerJerseyIcon(
              player: _player(gender: PlayerGender.female),
              isTeamA: true,
            ),
          ),
        ),
      );

      final Image image = tester.widget(find.byType(Image));
      expect(
        (image.image as AssetImage).assetName,
        kTeamAWomenAsset,
      );
    });
  });
}
