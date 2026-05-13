import 'package:flutter_test/flutter_test.dart';
import 'package:iwbf_team_points_control/models/player.dart';
import 'package:iwbf_team_points_control/models/team.dart';

Player _player(String id, int number, double cls) => Player(
      id: id,
      teamName: 'Brazil',
      shirtNumber: number,
      surname: 'Silva',
      firstName: 'João',
      playerClass: cls,
    );

void main() {
  group('Team', () {
    test('displayName retorna apenas o teamName', () {
      final Team t = Team(id: 't1', teamName: 'Brazil');
      expect(t.displayName, equals('Brazil'));
    });

    test('displayName preserva nomes com múltiplas palavras', () {
      final Team t =
          Team(id: 't1', teamName: 'United States of America');
      expect(t.displayName, equals('United States of America'));
    });

    test('lista de players é imutável', () {
      final Team t = Team(
        id: 't1',
        teamName: 'Brazil',
        players: <Player>[_player('p1', 1, 1.0)],
      );
      expect(() => t.players.add(_player('p2', 2, 2.0)),
          throwsUnsupportedError);
    });

    test('roundtrip JSON preserva equipe e atletas', () {
      final Team original = Team(
        id: 't1',
        teamName: 'Brazil',
        flagAssetPath: 'assets/flags/bra.png',
        players: <Player>[
          _player('p1', 7, 2.5),
          _player('p2', 9, 4.0),
        ],
      );
      final Team restored = Team.fromJson(original.toJson());

      expect(restored.id, equals(original.id));
      expect(restored.teamName, equals(original.teamName));
      expect(restored.flagAssetPath, equals(original.flagAssetPath));
      expect(restored.players, hasLength(2));
      expect(restored.players.first.shirtNumber, equals(7));
    });
  });
}
