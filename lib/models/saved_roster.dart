import 'team.dart';

/// Planilha completa persistida localmente — **todas** as equipes/atletas
/// da última planilha usada pelo app.
///
/// Diferente do `MatchState` (que guarda apenas as duas equipes em jogo),
/// o `SavedRoster` permite restaurar a planilha inteira na tela inicial,
/// para que o usuário escolha qualquer par de equipes no dia seguinte sem
/// precisar reimportar o arquivo.
class SavedRoster {
  const SavedRoster({required this.teams, this.competitionName});

  final List<Team> teams;
  final String? competitionName;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'competitionName': competitionName,
        'teams': teams.map((Team t) => t.toJson()).toList(),
      };

  factory SavedRoster.fromJson(Map<String, dynamic> json) {
    final List<dynamic> rawTeams =
        (json['teams'] as List<dynamic>?) ?? const <dynamic>[];
    return SavedRoster(
      competitionName: json['competitionName'] as String?,
      teams: rawTeams
          .map((dynamic t) => Team.fromJson(t as Map<String, dynamic>))
          .toList(),
    );
  }
}
