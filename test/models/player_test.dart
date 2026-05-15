import 'package:flutter_test/flutter_test.dart';
import 'package:iwbf_team_points_control/models/player.dart';

Player _build({
  String id = 'p1',
  String teamName = 'Brazil',
  int shirtNumber = 7,
  String surname = 'Silva',
  String firstName = 'João',
  double playerClass = 2.5,
  DateTime? dateOfBirth,
  PlayerGender gender = PlayerGender.unspecified,
}) {
  return Player(
    id: id,
    teamName: teamName,
    shirtNumber: shirtNumber,
    surname: surname,
    firstName: firstName,
    playerClass: playerClass,
    dateOfBirth: dateOfBirth,
    gender: gender,
  );
}

void main() {
  group('Player', () {
    test('displayName usa SURNAME, First Name', () {
      final Player p = _build();
      expect(p.displayName, equals('SILVA, João'));
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
      expect(restored.surname, equals(original.surname));
      expect(restored.firstName, equals(original.firstName));
      expect(restored.playerClass, equals(original.playerClass));
      expect(restored.dateOfBirth, equals(original.dateOfBirth));
      expect(restored.gender, equals(PlayerGender.male));
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
      final Player updated = p.copyWith(shirtNumber: 11);
      expect(updated.shirtNumber, equals(11));
      expect(updated.surname, equals(p.surname));
      expect(updated.id, equals(p.id));
    });

    test('igualdade é definida pelo id', () {
      final Player a = _build(id: 'x');
      final Player b = _build(id: 'x', shirtNumber: 99, surname: 'Outro');
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });
  });
}
