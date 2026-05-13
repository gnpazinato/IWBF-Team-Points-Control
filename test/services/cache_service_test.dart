import 'package:flutter_test/flutter_test.dart';
import 'package:iwbf_team_points_control/models/match_state.dart';
import 'package:iwbf_team_points_control/models/player.dart';
import 'package:iwbf_team_points_control/models/team.dart';
import 'package:iwbf_team_points_control/services/cache_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

Player _player(String id, double cls, {int number = 1}) => Player(
      id: id,
      teamName: 'Brazil',
      shirtNumber: number,
      surname: 'P$id',
      firstName: 'First',
      playerClass: cls,
    );

MatchState _seed() {
  final MatchState m = MatchState(
    teamA: Team(
      id: 'team-brazil',
      teamName: 'Brazil',
      players: <Player>[
        _player('a1', 2.5, number: 7),
        _player('a2', 4.0, number: 9),
      ],
    ),
    teamB: Team(
      id: 'team-argentina',
      teamName: 'Argentina',
      players: <Player>[_player('b1', 1.5, number: 4)],
    ),
    pointLimit: 15.0,
    competitionName: 'Americas Championship',
  );
  m.selectPlayer(m.teamA.players.first);
  m.selectPlayer(m.teamB.players.first);
  return m;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  group('CacheService', () {
    test('hasMatchState e falso quando nada foi salvo', () async {
      final CacheService cache = CacheService();
      expect(await cache.hasMatchState(), isFalse);
      expect(await cache.loadMatchState(), isNull);
    });

    test('save -> load preserva estado completo', () async {
      final CacheService cache = CacheService();
      final MatchState original = _seed();
      await cache.saveMatchState(original);
      expect(await cache.hasMatchState(), isTrue);

      final MatchState? restored = await cache.loadMatchState();
      expect(restored, isNotNull);
      expect(restored!.competitionName, equals('Americas Championship'));
      expect(restored.pointLimit, equals(15.0));
      expect(restored.selectedTeamAIds, equals(<String>{'a1'}));
      expect(restored.selectedTeamBIds, equals(<String>{'b1'}));
      expect(restored.totalPointsTeamA, equals(2.5));
      expect(restored.totalPointsTeamB, equals(1.5));
    });

    test('clear remove o estado salvo', () async {
      final CacheService cache = CacheService();
      await cache.saveMatchState(_seed());
      expect(await cache.hasMatchState(), isTrue);
      await cache.clear();
      expect(await cache.hasMatchState(), isFalse);
      expect(await cache.loadMatchState(), isNull);
    });

    test('load tolera JSON corrompido sem lancar', () async {
      SharedPreferences.setMockInitialValues(<String, Object>{
        'iwbf.match_state.v1': 'isto-nao-e-json-{}{}{',
      });
      final CacheService cache = CacheService();
      expect(await cache.loadMatchState(), isNull);
    });

    test('save sobrescreve o estado anterior', () async {
      final CacheService cache = CacheService();
      await cache.saveMatchState(_seed());

      final MatchState other = MatchState(
        teamA: Team(id: 'team-canada', teamName: 'Canada'),
        teamB: Team(id: 'team-mexico', teamName: 'Mexico'),
        pointLimit: 13.0,
      );
      await cache.saveMatchState(other);

      final MatchState? restored = await cache.loadMatchState();
      expect(restored, isNotNull);
      expect(restored!.teamA.teamName, equals('Canada'));
      expect(restored.teamB.teamName, equals('Mexico'));
      expect(restored.pointLimit, equals(13.0));
      expect(restored.selectedTeamAIds, isEmpty);
    });

    test('aceita prefs injetado no construtor', () async {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      final SharedPreferences instance =
          await SharedPreferences.getInstance();
      final CacheService cache = CacheService(prefs: instance);
      await cache.saveMatchState(_seed());
      expect(instance.getString('iwbf.match_state.v1'), isNotNull);
    });
  });
}
