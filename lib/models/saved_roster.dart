import 'team.dart';

/// Planilha completa persistida localmente — **todas** as equipes/atletas
/// da última planilha usada pelo app.
///
/// Diferente do `MatchState` (que guarda apenas as duas equipes em jogo),
/// o `SavedRoster` permite restaurar a planilha inteira na tela inicial,
/// para que o usuário escolha qualquer par de equipes no dia seguinte sem
/// precisar reimportar o arquivo.
///
/// Quando a planilha veio de um **link online** ([sourceUrl] não nulo), o
/// app pode retomar a sincronização ao restaurar: [sourceHash] guarda a
/// versão já aplicada, evitando re-disparar o aviso de "atualização
/// disponível" para uma versão que o usuário já tem.
class SavedRoster {
  const SavedRoster({
    required this.teams,
    this.competitionName,
    this.sourceUrl,
    this.sourceHash,
  });

  final List<Team> teams;
  final String? competitionName;

  /// Link online de origem (SharePoint/OneDrive/Google), quando a planilha
  /// foi carregada por link. Nulo para planilhas carregadas por upload.
  final String? sourceUrl;

  /// Hash de conteúdo da versão já aplicada do link (para detecção de
  /// mudança ao retomar a sincronização).
  final String? sourceHash;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'competitionName': competitionName,
        'sourceUrl': sourceUrl,
        'sourceHash': sourceHash,
        'teams': teams.map((Team t) => t.toJson()).toList(),
      };

  factory SavedRoster.fromJson(Map<String, dynamic> json) {
    final List<dynamic> rawTeams =
        (json['teams'] as List<dynamic>?) ?? const <dynamic>[];
    return SavedRoster(
      competitionName: json['competitionName'] as String?,
      sourceUrl: json['sourceUrl'] as String?,
      sourceHash: json['sourceHash'] as String?,
      teams: rawTeams
          .map((dynamic t) => Team.fromJson(t as Map<String, dynamic>))
          .toList(),
    );
  }
}
