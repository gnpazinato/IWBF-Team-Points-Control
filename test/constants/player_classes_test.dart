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

  group('classFromDateLikeString (anti-autoformatação do Excel)', () {
    test('recupera classe quando o mês carrega o decimal (.5)', () {
      // 1.5 -> 2026-05-01, 2.5 -> 2026-05-02, etc. (mês 5 = ".5").
      expect(classFromDateLikeString('2026-05-01'), equals(1.5));
      expect(classFromDateLikeString('2026-05-02'), equals(2.5));
      expect(classFromDateLikeString('2026-05-03'), equals(3.5));
      expect(classFromDateLikeString('2026-05-04'), equals(4.5));
    });

    test('recupera classe quando o dia carrega o decimal (locale invertido)',
        () {
      // 2.5 -> 2026-02-05 (mês 2, dia 5): testa a ordem alternativa.
      expect(classFromDateLikeString('2026-02-05'), equals(2.5));
    });

    test('retorna null para datas que não reconstroem classe válida', () {
      expect(classFromDateLikeString('2026-07-09'), isNull);
      expect(classFromDateLikeString('2026-12-12'), isNull);
    });

    test('retorna null para texto que não é data', () {
      expect(classFromDateLikeString('2.5'), isNull);
      expect(classFromDateLikeString('abc'), isNull);
      expect(classFromDateLikeString(null), isNull);
    });
  });
}
