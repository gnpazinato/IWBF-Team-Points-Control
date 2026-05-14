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
}
