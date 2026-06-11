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

/// Lê o número da camisa aceitando tanto o formato novo (`String`, que
/// preserva zeros à esquerda — "0" e "00" são valores distintos) quanto o
/// legado (`int`, gravado em caches/rosters de versões anteriores).
String _shirtNumberFromJson(Object? raw) {
  if (raw is String) return raw;
  if (raw is int) return raw.toString();
  if (raw is num) return raw.toInt().toString();
  return raw?.toString() ?? '';
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

  /// Número da camisa como **texto**, preservando zeros à esquerda. "0" e
  /// "00" são rótulos distintos (jogadores diferentes). Para ordenar use
  /// [compareShirtLabels], que ordena pelo valor numérico mas mantém a
  /// distinção entre "0" e "00".
  final String shirtNumber;

  /// Nome completo do atleta (campo único; substitui surname + firstName).
  final String name;
  final double playerClass;
  final DateTime? dateOfBirth;
  final PlayerGender gender;

  /// Nome exibido (igual ao campo único `name`).
  String get displayName => name;

  bool get hasValidClass => isAcceptedPlayerClass(playerClass);

  /// Ordena rótulos de camisa numericamente (1, 2, …, 10) — não
  /// lexicograficamente —, mas mantendo "0" e "00" como valores distintos:
  /// quando o valor numérico empata, o rótulo mais curto vem primeiro
  /// ("0" antes de "00"). Rótulos não numéricos caem no compareTo padrão.
  static int compareShirtLabels(String a, String b) {
    final int? na = int.tryParse(a);
    final int? nb = int.tryParse(b);
    if (na != null && nb != null) {
      final int byValue = na.compareTo(nb);
      if (byValue != 0) return byValue;
      return a.length.compareTo(b.length);
    }
    return a.compareTo(b);
  }

  Player copyWith({
    String? id,
    String? teamName,
    String? shirtNumber,
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
      shirtNumber: _shirtNumberFromJson(json['shirtNumber']),
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
