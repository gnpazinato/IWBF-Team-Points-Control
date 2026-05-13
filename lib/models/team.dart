import 'player.dart';

/// Equipe importada da planilha de referência.
class Team {
  Team({
    required this.id,
    required this.teamName,
    this.countryCode,
    this.flagAssetPath,
    List<Player>? players,
  }) : players = List<Player>.unmodifiable(players ?? const <Player>[]);

  final String id;
  final String teamName;
  final String? countryCode;
  final String? flagAssetPath;
  final List<Player> players;

  /// Nome exibido no padrão `"Brazil - BRA"` quando há código,
  /// caindo para apenas o nome quando não houver.
  String get displayName {
    if (countryCode == null || countryCode!.isEmpty) {
      return teamName;
    }
    return '$teamName - ${countryCode!.toUpperCase()}';
  }

  int get playerCount => players.length;

  Team copyWith({
    String? id,
    String? teamName,
    String? countryCode,
    String? flagAssetPath,
    List<Player>? players,
  }) {
    return Team(
      id: id ?? this.id,
      teamName: teamName ?? this.teamName,
      countryCode: countryCode ?? this.countryCode,
      flagAssetPath: flagAssetPath ?? this.flagAssetPath,
      players: players ?? this.players,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'teamName': teamName,
        'countryCode': countryCode,
        'flagAssetPath': flagAssetPath,
        'players': players.map((Player p) => p.toJson()).toList(),
      };

  factory Team.fromJson(Map<String, dynamic> json) {
    final List<dynamic> rawPlayers =
        (json['players'] as List<dynamic>?) ?? const <dynamic>[];
    return Team(
      id: json['id'] as String,
      teamName: json['teamName'] as String,
      countryCode: json['countryCode'] as String?,
      flagAssetPath: json['flagAssetPath'] as String?,
      players: rawPlayers
          .map((dynamic p) => Player.fromJson(p as Map<String, dynamic>))
          .toList(),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Team && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'Team(id: $id, $displayName, players: ${players.length})';
}
