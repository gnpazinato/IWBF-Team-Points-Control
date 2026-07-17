import 'package:flutter_test/flutter_test.dart';
import 'package:iwbf_team_points_control/constants/point_limits.dart';

void main() {
  group('point limits', () {
    test('limite padrão é 14.0', () {
      expect(kDefaultPointLimit, equals(14.0));
    });

    test('aceita os 19 valores da faixa expandida (7.0–16.0 em 0.5)', () {
      expect(kAcceptedPointLimits, hasLength(19));
      for (final double v in kAcceptedPointLimits) {
        expect(isAcceptedPointLimit(v), isTrue, reason: '$v deveria ser aceito');
      }
    });

    test('limite máximo é 16.0 e mínimo é 7.0', () {
      expect(kAcceptedPointLimits.first, equals(7.0));
      expect(kAcceptedPointLimits.last, equals(16.0));
    });

    test('todos os valores oficiais IWBF (13.0–16.0) seguem aceitos', () {
      for (final double v in <double>[13.0, 13.5, 14.0, 14.5, 15.0, 15.5, 16.0]) {
        expect(isAcceptedPointLimit(v), isTrue, reason: '$v deveria ser aceito');
      }
    });

    test('valores fora da escala são rejeitados', () {
      expect(isAcceptedPointLimit(6.5), isFalse);
      expect(isAcceptedPointLimit(16.5), isFalse);
      expect(isAcceptedPointLimit(14.2), isFalse);
    });

    test('máximo de 5 atletas por equipe', () {
      expect(kMaxPlayersPerTeam, equals(5));
    });
  });

  group('MatchFormat (entrada 0047)', () {
    test('5x5: limite padrão 14.0 e 5 em quadra', () {
      expect(MatchFormat.fiveOnFive.defaultPointLimit, equals(14.0));
      expect(MatchFormat.fiveOnFive.maxOnCourt, equals(5));
      expect(MatchFormat.fiveOnFive.label, equals('5x5'));
    });

    test('3x3: limite padrão 8.5 e 3 em quadra', () {
      expect(MatchFormat.threeOnThree.defaultPointLimit, equals(8.5));
      expect(MatchFormat.threeOnThree.maxOnCourt, equals(3));
      expect(MatchFormat.threeOnThree.label, equals('3x3'));
    });

    test('limites padrão dos dois formatos estão na faixa aceita', () {
      for (final MatchFormat f in MatchFormat.values) {
        expect(isAcceptedPointLimit(f.defaultPointLimit), isTrue,
            reason: '${f.defaultPointLimit} deveria ser aceito');
      }
    });

    test('fromName faz round-trip e cai no 5x5 para valor desconhecido', () {
      for (final MatchFormat f in MatchFormat.values) {
        expect(MatchFormat.fromName(f.name), equals(f));
      }
      expect(MatchFormat.fromName(null), equals(MatchFormat.fiveOnFive));
      expect(MatchFormat.fromName('7x7'), equals(MatchFormat.fiveOnFive));
    });
  });

  group('suggestMatchFormat (heurística da entrada 0047)', () {
    test('duas equipes com até 5 inscritos → 3x3', () {
      expect(suggestMatchFormat(5, 5), equals(MatchFormat.threeOnThree));
      expect(suggestMatchFormat(3, 4), equals(MatchFormat.threeOnThree));
    });

    test('qualquer equipe com 6+ inscritos → 5x5', () {
      expect(suggestMatchFormat(6, 6), equals(MatchFormat.fiveOnFive));
      expect(suggestMatchFormat(12, 12), equals(MatchFormat.fiveOnFive));
    });

    test('caso misto (uma pequena, outra grande) → 5x5', () {
      expect(suggestMatchFormat(4, 8), equals(MatchFormat.fiveOnFive));
      expect(suggestMatchFormat(8, 4), equals(MatchFormat.fiveOnFive));
      expect(suggestMatchFormat(5, 6), equals(MatchFormat.fiveOnFive));
    });
  });
}
