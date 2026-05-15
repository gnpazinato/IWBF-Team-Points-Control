import 'package:flutter_test/flutter_test.dart';
import 'package:iwbf_team_points_control/constants/player_classes.dart';

void main() {
  group('isAcceptedPlayerClass', () {
    test('aceita todos os valores oficiais da IWBF', () {
      for (final double v in kAcceptedPlayerClasses) {
        expect(isAcceptedPlayerClass(v), isTrue, reason: 'falhou para $v');
      }
    });

    test('rejeita valores fora do padrão', () {
      expect(isAcceptedPlayerClass(0.5), isFalse);
      expect(isAcceptedPlayerClass(2.3), isFalse);
      expect(isAcceptedPlayerClass(5.0), isFalse);
    });
  });

  group('parsePlayerClass', () {
    test('aceita ponto como separador decimal', () {
      expect(parsePlayerClass('2.5'), equals(2.5));
    });

    test('aceita vírgula e normaliza para ponto', () {
      expect(parsePlayerClass('2,5'), equals(2.5));
    });

    test('aceita inteiro escrito sem decimal', () {
      expect(parsePlayerClass('3'), equals(3.0));
    });

    test('retorna null para valor fora da tabela', () {
      expect(parsePlayerClass('2.3'), isNull);
      expect(parsePlayerClass('5.0'), isNull);
    });

    test('retorna null para texto vazio ou nulo', () {
      expect(parsePlayerClass(null), isNull);
      expect(parsePlayerClass(''), isNull);
      expect(parsePlayerClass('   '), isNull);
    });

    test('retorna null para texto inválido', () {
      expect(parsePlayerClass('abc'), isNull);
    });
  });
}
