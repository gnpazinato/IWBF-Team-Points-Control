import 'package:flutter_test/flutter_test.dart';
import 'package:iwbf_team_points_control/models/player.dart';
import 'package:iwbf_team_points_control/models/team.dart';

Player _player(String id, String number, double cls) => Player(
      id: id,
      teamName: 'Brazil',
      shirtNumber: number,
      name: 'João Silva',
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
        players: <Player>[_player('p1', '1', 1.0)],
      );
      expect(() => t.players.add(_player('p2', '2', 2.0)),
          throwsUnsupportedError);
    });

    test('roundtrip JSON preserva equipe e atletas', () {
      final Team original = Team(
        id: 't1',
        teamName: 'Brazil',
        flagAssetPath: 'assets/flags/bra.png',
        players: <Player>[
          _player('p1', '7', 2.5),
          _player('p2', '9', 4.0),
        ],
      );
      final Team restored = Team.fromJson(original.toJson());

      expect(restored.id, equals(original.id));
      expect(restored.teamName, equals(original.teamName));
      expect(restored.flagAssetPath, equals(original.flagAssetPath));
      expect(restored.players, hasLength(2));
      expect(restored.players.first.shirtNumber, equals('7'));
    });

    test('displayName ganha sufixo "- Men"/"- Women" conforme o gênero', () {
      final Team men = Team(id: 't1', teamName: 'Brazil', gender: TeamGender.men);
      final Team women = Team(id: 't2', teamName: 'Brazil', gender: TeamGender.women);
      final Team mixed = Team(id: 't3', teamName: 'Brazil', gender: TeamGender.mixed);
      final Team neutral = Team(id: 't4', teamName: 'Brazil');
      expect(men.displayName, equals('Brazil - Men'));
      expect(women.displayName, equals('Brazil - Women'));
      expect(mixed.displayName, equals('Brazil - Mixed'));
      expect(neutral.displayName, equals('Brazil'));
    });

    test('displayName preserva separador hífen para nomes longos', () {
      final Team usa = Team(
        id: 't1',
        teamName: 'United States of America',
        gender: TeamGender.men,
      );
      expect(usa.displayName, equals('United States of America - Men'));
    });

    test('gender persiste no roundtrip JSON', () {
      final Team original =
          Team(id: 't1', teamName: 'Brazil', gender: TeamGender.women);
      final Team restored = Team.fromJson(original.toJson());
      expect(restored.gender, equals(TeamGender.women));
      expect(restored.displayName, equals('Brazil - Women'));
    });

    test('JSON sem campo gender retorna unspecified (compat)', () {
      final Map<String, dynamic> json = <String, dynamic>{
        'id': 't1',
        'teamName': 'Brazil',
        'players': <dynamic>[],
      };
      final Team restored = Team.fromJson(json);
      expect(restored.gender, equals(TeamGender.unspecified));
      expect(restored.displayName, equals('Brazil'));
    });
  });
}
