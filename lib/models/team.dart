import 'player.dart';

/// Equipe importada da planilha de referência.
///
/// O nome completo do país é a única forma de identificação visível ao
/// usuário; a resolução para uma bandeira local fica a cargo do
/// `CountryResolverService` (Fase 2), que preenche [flagAssetPath].
class Team {
  Team({
    required this.id,
    required this.teamName,
    this.flagAssetPath,
    List<Player>? players,
  }) : players = List<Player>.unmodifiable(players ?? const <Player>[]);

  final String id;
  final String teamName;
  final String? flagAssetPath;
  final List<Player> players;

  String get displayName => teamName;

  int get playerCount => players.length;

  Team copyWith({
    String? id,
    String? teamName,
    String? flagAssetPath,
    List<Player>? players,
  }) {
    return Team(
      id: id ?? this.id,
      teamName: teamName ?? this.teamName,
      flagAssetPath: flagAssetPath ?? this.flagAssetPath,
      players: players ?? this.players,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'teamName': teamName,
        'flagAssetPath': flagAssetPath,
        'players': players.map((Player p) => p.toJson()).toList(),
      };

  factory Team.fromJson(Map<String, dynamic> json) {
    final List<dynamic> rawPlayers =
        (json['players'] as List<dynamic>?) ?? const <dynamic>[];
    return Team(
      id: json['id'] as String,
      teamName: json['teamName'] as String,
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
