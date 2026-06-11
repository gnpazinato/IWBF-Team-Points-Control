import 'package:flutter_test/flutter_test.dart';
import 'package:iwbf_team_points_control/models/player.dart';

Player _build({
  String id = 'p1',
  String teamName = 'Brazil',
  String shirtNumber = '7',
  String name = 'João Silva',
  double playerClass = 2.5,
  DateTime? dateOfBirth,
  PlayerGender gender = PlayerGender.unspecified,
}) {
  return Player(
    id: id,
    teamName: teamName,
    shirtNumber: shirtNumber,
    name: name,
    playerClass: playerClass,
    dateOfBirth: dateOfBirth,
    gender: gender,
  );
}

void main() {
  group('Player', () {
    test('displayName retorna o nome completo (campo único)', () {
      final Player p = _build(name: 'João Silva');
      expect(p.displayName, equals('João Silva'));
    });

    test('hasValidClass aceita classes IWBF', () {
      expect(_build(playerClass: 1.0).hasValidClass, isTrue);
      expect(_build(playerClass: 4.5).hasValidClass, isTrue);
    });

    test('hasValidClass rejeita classes fora da tabela', () {
      expect(_build(playerClass: 2.3).hasValidClass, isFalse);
    });

    test('roundtrip JSON preserva campos obrigatórios e opcionais', () {
      final Player original = _build(
        dateOfBirth: DateTime.utc(1998, 1, 2),
        gender: PlayerGender.male,
      );
      final Player restored = Player.fromJson(original.toJson());

      expect(restored.id, equals(original.id));
      expect(restored.teamName, equals(original.teamName));
      expect(restored.shirtNumber, equals(original.shirtNumber));
      expect(restored.name, equals(original.name));
      expect(restored.playerClass, equals(original.playerClass));
      expect(restored.dateOfBirth, equals(original.dateOfBirth));
      expect(restored.gender, equals(PlayerGender.male));
    });

    test('roundtrip JSON sem dob mantém dateOfBirth nulo', () {
      final Player p = _build();
      final Player restored = Player.fromJson(p.toJson());
      expect(restored.dateOfBirth, isNull);
    });

    test('fromJson aceita formato legado surname + firstName', () {
      // shirtNumber legado gravado como int (caches/rosters antigos).
      final Player restored = Player.fromJson(<String, dynamic>{
        'id': 'p1',
        'teamName': 'Brazil',
        'shirtNumber': 7,
        'surname': 'Silva',
        'firstName': 'João',
        'playerClass': 2.5,
        'dateOfBirth': null,
        'gender': 'male',
      });
      expect(restored.name, equals('João Silva'));
      // Migração int → String preserva o rótulo da camisa.
      expect(restored.shirtNumber, equals('7'));
    });

    test('roundtrip JSON com gender ausente vira unspecified', () {
      final Player p = _build();
      final Map<String, dynamic> json = p.toJson();
      json.remove('gender');
      final Player restored = Player.fromJson(json);
      expect(restored.gender, equals(PlayerGender.unspecified));
    });

    test('copyWith muda apenas o campo especificado', () {
      final Player p = _build();
      final Player updated = p.copyWith(shirtNumber: '11');
      expect(updated.shirtNumber, equals('11'));
      expect(updated.name, equals(p.name));
      expect(updated.id, equals(p.id));
    });

    test('igualdade é definida pelo id', () {
      final Player a = _build(id: 'x');
      final Player b = _build(id: 'x', shirtNumber: '99', name: 'Outro');
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });
  });

  group('shirtNumber como texto', () {
    test('fromJson migra int legado 0 para "0"', () {
      final Player restored = Player.fromJson(<String, dynamic>{
        'id': 'p1',
        'teamName': 'Brazil',
        'shirtNumber': 0,
        'name': 'João Silva',
        'playerClass': 2.5,
        'dateOfBirth': null,
        'gender': 'male',
      });
      expect(restored.shirtNumber, equals('0'));
    });

    test('fromJson migra int legado 7 para "7"', () {
      final Player restored = Player.fromJson(<String, dynamic>{
        'id': 'p1',
        'teamName': 'Brazil',
        'shirtNumber': 7,
        'name': 'João Silva',
        'playerClass': 2.5,
        'dateOfBirth': null,
        'gender': 'male',
      });
      expect(restored.shirtNumber, equals('7'));
    });

    test('"0" e "00" são rótulos distintos', () {
      final Player zero = _build(id: 'a', shirtNumber: '0');
      final Player doubleZero = _build(id: 'b', shirtNumber: '00');
      expect(zero.shirtNumber, equals('0'));
      expect(doubleZero.shirtNumber, equals('00'));
      expect(zero.shirtNumber, isNot(equals(doubleZero.shirtNumber)));
    });
  });

  group('compareShirtLabels', () {
    test('ordena pelo valor numérico, não lexicograficamente', () {
      expect(Player.compareShirtLabels('2', '10'), lessThan(0));
      expect(Player.compareShirtLabels('10', '2'), greaterThan(0));
    });

    test('em empate numérico, o rótulo mais curto vem primeiro', () {
      expect(Player.compareShirtLabels('0', '00'), lessThan(0));
      expect(Player.compareShirtLabels('00', '0'), greaterThan(0));
    });
  });
}
