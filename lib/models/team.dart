import 'player.dart';

/// Gênero da equipe, deduzido do gênero dos atletas ou explicitado no
/// nome da aba/coluna. Times oficiais da IWBF são single-gender (Men ou
/// Women); `mixed` cobre planilhas exibicionais e `unspecified` cobre
/// planilhas sem a coluna `gender`.
enum TeamGender { men, women, mixed, unspecified }

TeamGender _parseTeamGender(String? raw) {
  if (raw == null) return TeamGender.unspecified;
  switch (raw.trim().toLowerCase()) {
    case 'men':
      return TeamGender.men;
    case 'women':
      return TeamGender.women;
    case 'mixed':
      return TeamGender.mixed;
    case 'unspecified':
    case '':
      return TeamGender.unspecified;
  }
  return TeamGender.unspecified;
}

String _teamGenderToString(TeamGender gender) {
  switch (gender) {
    case TeamGender.men:
      return 'men';
    case TeamGender.women:
      return 'women';
    case TeamGender.mixed:
      return 'mixed';
    case TeamGender.unspecified:
      return 'unspecified';
  }
}

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
    this.gender = TeamGender.unspecified,
    List<Player>? players,
  }) : players = List<Player>.unmodifiable(players ?? const <Player>[]);

  final String id;
  final String teamName;
  final String? flagAssetPath;
  final TeamGender gender;
  final List<Player> players;

  /// Nome exibido ao usuário: `"<País> - Men"`, `"<País> - Women"` ou
  /// apenas `"<País>"` quando o gênero é desconhecido. `mixed` recebe o
  /// sufixo `"- Mixed"` para deixar claro que a equipe não é single-gender.
  /// O hífen separa visualmente país e gênero para nomes longos
  /// (`United States of America - Men`).
  String get displayName {
    switch (gender) {
      case TeamGender.men:
        return '$teamName - Men';
      case TeamGender.women:
        return '$teamName - Women';
      case TeamGender.mixed:
        return '$teamName - Mixed';
      case TeamGender.unspecified:
        return teamName;
    }
  }

  int get playerCount => players.length;

  Team copyWith({
    String? id,
    String? teamName,
    String? flagAssetPath,
    TeamGender? gender,
    List<Player>? players,
  }) {
    return Team(
      id: id ?? this.id,
      teamName: teamName ?? this.teamName,
      flagAssetPath: flagAssetPath ?? this.flagAssetPath,
      gender: gender ?? this.gender,
      players: players ?? this.players,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'teamName': teamName,
        'flagAssetPath': flagAssetPath,
        'gender': _teamGenderToString(gender),
        'players': players.map((Player p) => p.toJson()).toList(),
      };

  factory Team.fromJson(Map<String, dynamic> json) {
    final List<dynamic> rawPlayers =
        (json['players'] as List<dynamic>?) ?? const <dynamic>[];
    return Team(
      id: json['id'] as String,
      teamName: json['teamName'] as String,
      flagAssetPath: json['flagAssetPath'] as String?,
      gender: _parseTeamGender(json['gender'] as String?),
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
