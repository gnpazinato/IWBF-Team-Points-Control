import 'package:flutter_test/flutter_test.dart';
import 'package:iwbf_team_points_control/constants/point_limits.dart';
import 'package:iwbf_team_points_control/models/match_state.dart';
import 'package:iwbf_team_points_control/models/player.dart';
import 'package:iwbf_team_points_control/models/team.dart';

Player _player(String id, String team, double cls, {String number = '1'}) => Player(
      id: id,
      teamName: team,
      shirtNumber: number,
      name: 'First P$id',
      playerClass: cls,
    );

Team _teamWith(String name, List<Player> players) =>
    Team(id: name, teamName: name, players: players);

MatchState _matchOf({
  required List<Player> teamAPlayers,
  required List<Player> teamBPlayers,
  double limit = kDefaultPointLimit,
}) {
  return MatchState(
    teamA: _teamWith('Brazil', teamAPlayers),
    teamB: _teamWith('Argentina', teamBPlayers),
    pointLimit: limit,
  );
}

void main() {
  group('MatchState - seleção', () {
    test('selectPlayer adiciona até 5 e bloqueia o 6º', () {
      final List<Player> roster = <Player>[
        for (int i = 0; i < 6; i++) _player('a$i', 'Brazil', 1.0, number: '$i'),
      ];
      final MatchState match = _matchOf(teamAPlayers: roster, teamBPlayers: <Player>[]);

      for (int i = 0; i < 5; i++) {
        expect(match.selectPlayer(roster[i]), isTrue, reason: 'i=$i');
      }
      expect(match.selectPlayer(roster[5]), isFalse,
          reason: '6º atleta deve ser bloqueado');
      expect(match.selectedTeamAIds, hasLength(5));
    });

    test('deselectPlayer libera vaga para outro atleta', () {
      final List<Player> roster = <Player>[
        for (int i = 0; i < 6; i++) _player('a$i', 'Brazil', 1.0, number: '$i'),
      ];
      final MatchState match = _matchOf(teamAPlayers: roster, teamBPlayers: <Player>[]);

      for (int i = 0; i < 5; i++) {
        match.selectPlayer(roster[i]);
      }
      match.deselectPlayer(roster[0]);
      expect(match.selectPlayer(roster[5]), isTrue);
    });

    test('togglePlayer alterna seleção', () {
      final Player p = _player('a1', 'Brazil', 1.0);
      final MatchState match =
          _matchOf(teamAPlayers: <Player>[p], teamBPlayers: <Player>[]);

      expect(match.togglePlayer(p), isTrue);
      expect(match.selectedTeamAIds, contains('a1'));
      expect(match.togglePlayer(p), isFalse);
      expect(match.selectedTeamAIds, isEmpty);
    });

    test('selecionar jogador fora das equipes lança erro', () {
      final MatchState match = _matchOf(
        teamAPlayers: <Player>[_player('a1', 'Brazil', 1.0)],
        teamBPlayers: <Player>[_player('b1', 'Argentina', 1.0)],
      );
      expect(
        () => match.selectPlayer(_player('x', 'Unknown', 1.0)),
        throwsArgumentError,
      );
    });

    test('selectPlayer é idempotente para o mesmo atleta', () {
      final Player p = _player('a1', 'Brazil', 2.0);
      final MatchState match =
          _matchOf(teamAPlayers: <Player>[p], teamBPlayers: <Player>[]);
      expect(match.selectPlayer(p), isTrue);
      expect(match.selectPlayer(p), isTrue);
      expect(match.selectedTeamAIds, hasLength(1));
    });
  });

  group('MatchState - pontuação', () {
    test('soma classes dos atletas selecionados', () {
      final List<Player> roster = <Player>[
        _player('a1', 'Brazil', 1.0, number: '1'),
        _player('a2', 'Brazil', 2.0, number: '2'),
        _player('a3', 'Brazil', 3.0, number: '3'),
        _player('a4', 'Brazil', 3.5, number: '4'),
        _player('a5', 'Brazil', 4.0, number: '5'),
      ];
      final MatchState match =
          _matchOf(teamAPlayers: roster, teamBPlayers: <Player>[]);
      for (final Player p in roster) {
        match.selectPlayer(p);
      }
      expect(match.totalPointsTeamA, equals(13.5));
    });

    test('isTeamAOverLimit dispara quando soma supera o limite', () {
      final List<Player> roster = <Player>[
        _player('a1', 'Brazil', 4.0, number: '1'),
        _player('a2', 'Brazil', 4.0, number: '2'),
        _player('a3', 'Brazil', 4.0, number: '3'),
        _player('a4', 'Brazil', 4.0, number: '4'),
      ];
      final MatchState match =
          _matchOf(teamAPlayers: roster, teamBPlayers: <Player>[], limit: 14.0);
      for (final Player p in roster) {
        match.selectPlayer(p);
      }
      expect(match.totalPointsTeamA, equals(16.0));
      expect(match.isTeamAOverLimit, isTrue);
    });

    test('isTeamAOverLimit é falso quando igual ao limite', () {
      final List<Player> roster = <Player>[
        _player('a1', 'Brazil', 3.5, number: '1'),
        _player('a2', 'Brazil', 3.5, number: '2'),
        _player('a3', 'Brazil', 3.5, number: '3'),
        _player('a4', 'Brazil', 3.5, number: '4'),
      ];
      final MatchState match =
          _matchOf(teamAPlayers: roster, teamBPlayers: <Player>[], limit: 14.0);
      for (final Player p in roster) {
        match.selectPlayer(p);
      }
      expect(match.totalPointsTeamA, equals(14.0));
      expect(match.isTeamAOverLimit, isFalse);
    });
  });

  group('MatchState - limpeza', () {
    MatchState seeded() {
      final MatchState match = _matchOf(
        teamAPlayers: <Player>[_player('a1', 'Brazil', 2.0)],
        teamBPlayers: <Player>[_player('b1', 'Argentina', 2.0)],
      );
      match.selectPlayer(match.teamA.players.first);
      match.selectPlayer(match.teamB.players.first);
      return match;
    }

    test('clearTeamA não afeta team B', () {
      final MatchState m = seeded();
      m.clearTeamA();
      expect(m.selectedTeamAIds, isEmpty);
      expect(m.selectedTeamBIds, hasLength(1));
    });

    test('clearTeamB não afeta team A', () {
      final MatchState m = seeded();
      m.clearTeamB();
      expect(m.selectedTeamBIds, isEmpty);
      expect(m.selectedTeamAIds, hasLength(1));
    });

    test('clearAll esvazia ambos', () {
      final MatchState m = seeded();
      m.clearAll();
      expect(m.selectedTeamAIds, isEmpty);
      expect(m.selectedTeamBIds, isEmpty);
    });
  });

  group('MatchState - pointLimit', () {
    test('setPointLimit aceita valores oficiais', () {
      final MatchState m =
          _matchOf(teamAPlayers: <Player>[], teamBPlayers: <Player>[]);
      m.setPointLimit(15.5);
      expect(m.pointLimit, equals(15.5));
    });

    test('setPointLimit rejeita valores não oficiais', () {
      final MatchState m =
          _matchOf(teamAPlayers: <Player>[], teamBPlayers: <Player>[]);
      expect(() => m.setPointLimit(14.2), throwsArgumentError);
    });
  });

  group('MatchState - serialização', () {
    test('roundtrip preserva equipes, seleções e limite', () {
      final List<Player> rosterA = <Player>[
        _player('a1', 'Brazil', 2.5, number: '7'),
        _player('a2', 'Brazil', 3.0, number: '9'),
      ];
      final List<Player> rosterB = <Player>[
        _player('b1', 'Argentina', 1.5, number: '4'),
      ];
      final MatchState original = MatchState(
        teamA: _teamWith('Brazil', rosterA),
        teamB: _teamWith('Argentina', rosterB),
        pointLimit: 15.0,
        competitionName: 'Americas Championship',
      );
      original.selectPlayer(rosterA[0]);
      original.selectPlayer(rosterB[0]);

      final MatchState restored = MatchState.fromJson(original.toJson());

      expect(restored.competitionName, equals('Americas Championship'));
      expect(restored.pointLimit, equals(15.0));
      expect(restored.selectedTeamAIds, equals(<String>{'a1'}));
      expect(restored.selectedTeamBIds, equals(<String>{'b1'}));
      expect(restored.totalPointsTeamA, equals(2.5));
      expect(restored.totalPointsTeamB, equals(1.5));
    });
  });
}
