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

/// Lê o nome do JSON aceitando o formato novo (`name`) e o legado
/// (`surname` + `firstName`) gravado em caches antigos.
String _nameFromJson(Map<String, dynamic> json) {
  final String? name = (json['name'] as String?)?.trim();
  if (name != null && name.isNotEmpty) return name;
  final String surname = (json['surname'] as String?)?.trim() ?? '';
  final String firstName = (json['firstName'] as String?)?.trim() ?? '';
  return '$firstName $surname'.trim();
}

/// Atleta importado da planilha de referência.
class Player {
  Player({
    required this.id,
    required this.teamName,
    required this.shirtNumber,
    required this.name,
    required this.playerClass,
    this.dateOfBirth,
    this.gender = PlayerGender.unspecified,
  }) : assert(playerClass > 0, 'playerClass deve ser positivo');

  final String id;
  final String teamName;
  final int shirtNumber;

  /// Nome completo do atleta (campo único; substitui surname + firstName).
  final String name;
  final double playerClass;
  final DateTime? dateOfBirth;
  final PlayerGender gender;

  /// Nome exibido (igual ao campo único `name`).
  String get displayName => name;

  bool get hasValidClass => isAcceptedPlayerClass(playerClass);

  Player copyWith({
    String? id,
    String? teamName,
    int? shirtNumber,
    String? name,
    double? playerClass,
    DateTime? dateOfBirth,
    PlayerGender? gender,
  }) {
    return Player(
      id: id ?? this.id,
      teamName: teamName ?? this.teamName,
      shirtNumber: shirtNumber ?? this.shirtNumber,
      name: name ?? this.name,
      playerClass: playerClass ?? this.playerClass,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      gender: gender ?? this.gender,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'teamName': teamName,
        'shirtNumber': shirtNumber,
        'name': name,
        'playerClass': playerClass,
        'dateOfBirth': dateOfBirth?.toIso8601String(),
        'gender': _genderToString(gender),
      };

  factory Player.fromJson(Map<String, dynamic> json) {
    return Player(
      id: json['id'] as String,
      teamName: json['teamName'] as String,
      shirtNumber: json['shirtNumber'] as int,
      name: _nameFromJson(json),
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
      'Player(id: $id, $name, #$shirtNumber, class $playerClass)';
}
