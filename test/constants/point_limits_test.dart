import 'package:flutter_test/flutter_test.dart';
import 'package:iwbf_team_points_control/constants/point_limits.dart';

void main() {
  group('point limits', () {
    test('limite padrão é 14.0', () {
      expect(kDefaultPointLimit, equals(14.0));
    });

    test('aceita os sete valores oficiais', () {
      expect(kAcceptedPointLimits, hasLength(7));
      for (final double v in kAcceptedPointLimits) {
        expect(isAcceptedPointLimit(v), isTrue, reason: '$v deveria ser aceito');
      }
    });

    test('limite máximo é 16.0 e mínimo é 13.0', () {
      expect(kAcceptedPointLimits.first, equals(13.0));
      expect(kAcceptedPointLimits.last, equals(16.0));
    });

    test('valores fora da escala são rejeitados', () {
      expect(isAcceptedPointLimit(12.5), isFalse);
      expect(isAcceptedPointLimit(16.5), isFalse);
      expect(isAcceptedPointLimit(14.2), isFalse);
    });

    test('máximo de 5 atletas por equipe', () {
      expect(kMaxPlayersPerTeam, equals(5));
    });
  });
}
