import '../constants/player_classes.dart';

enum PlayerGender { male, female, unspecified }

PlayerGender _parseGender(String? raw) {
  if (raw == null) return PlayerGender.unspecified;
  final String value = raw.trim().toLowerCase();
  if (value.isEmpty) return PlayerGender.unspecified;
  if (value == 'm' || value == 'male' || value == 'masculino') {
    return PlayerGender.male;
  }
  if (value == 'f' || value == 'female' || value == 'feminino') {
    return PlayerGender.female;
  }
  return PlayerGender.unspecified;
}

String _genderToString(PlayerGender gender) {
  switch (gender) {
    case PlayerGender.male:
      return 'male';
    case PlayerGender.female:
      return 'female';
    case PlayerGender.unspecified:
      return 'unspecified';
  }
}

/// Atleta importado da planilha de referência.
class Player {
  Player({
    required this.id,
    required this.teamName,
    required this.shirtNumber,
    required this.surname,
    required this.firstName,
    required this.playerClass,
    this.dateOfBirth,
    this.gender = PlayerGender.unspecified,
  }) : assert(playerClass > 0, 'playerClass deve ser positivo');

  final String id;
  final String teamName;
  final int shirtNumber;
  final String surname;
  final String firstName;
  final double playerClass;
  final DateTime? dateOfBirth;
  final PlayerGender gender;

  /// Sobrenome em caixa alta + primeiro nome, conforme padrão IWBF.
  String get displayName => '${surname.toUpperCase()}, $firstName';

  bool get hasValidClass => isAcceptedPlayerClass(playerClass);

  Player copyWith({
    String? id,
    String? teamName,
    int? shirtNumber,
    String? surname,
    String? firstName,
    double? playerClass,
    DateTime? dateOfBirth,
    PlayerGender? gender,
  }) {
    return Player(
      id: id ?? this.id,
      teamName: teamName ?? this.teamName,
      shirtNumber: shirtNumber ?? this.shirtNumber,
      surname: surname ?? this.surname,
      firstName: firstName ?? this.firstName,
      playerClass: playerClass ?? this.playerClass,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      gender: gender ?? this.gender,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'teamName': teamName,
        'shirtNumber': shirtNumber,
        'surname': surname,
        'firstName': firstName,
        'playerClass': playerClass,
        'dateOfBirth': dateOfBirth?.toIso8601String(),
        'gender': _genderToString(gender),
      };

  factory Player.fromJson(Map<String, dynamic> json) {
    return Player(
      id: json['id'] as String,
      teamName: json['teamName'] as String,
      shirtNumber: json['shirtNumber'] as int,
      surname: json['surname'] as String,
      firstName: json['firstName'] as String,
      playerClass: (json['playerClass'] as num).toDouble(),
      dateOfBirth: (json['dateOfBirth'] as String?) == null
          ? null
          : DateTime.parse(json['dateOfBirth'] as String),
      gender: _parseGender(json['gender'] as String?),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Player && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'Player(id: $id, $displayName, #$shirtNumber, class $playerClass)';
}
