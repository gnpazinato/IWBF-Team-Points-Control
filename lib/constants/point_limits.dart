/// Limites de pontuação selecionáveis no dropdown da tela de setup.
///
/// Faixa expandida de 7.0 a 16.0 em incrementos de 0.5 para cobrir
/// categorias com regras menos restritivas (júnior, escolar, mistas
/// recreativas) além das oficiais IWBF (que geralmente caem entre 13.0
/// e 16.0).
const List<double> kAcceptedPointLimits = <double>[
  7.0,
  7.5,
  8.0,
  8.5,
  9.0,
  9.5,
  10.0,
  10.5,
  11.0,
  11.5,
  12.0,
  12.5,
  13.0,
  13.5,
  14.0,
  14.5,
  15.0,
  15.5,
  16.0,
];

/// Valor padrão exibido na tela de configuração da partida.
const double kDefaultPointLimit = 14.0;

/// Quantidade de slots de seleção por equipe (tamanho fixo do array de
/// slots do `MatchState`, igual ao máximo em quadra do 5x5). No 3x3 o
/// array continua com 5 posições, mas só as 3 primeiras são preenchíveis
/// (ver [MatchFormat.maxOnCourt]).
const int kMaxPlayersPerTeam = 5;

/// Formato da partida (entrada 0047). Define o limite de pontos padrão e
/// o máximo de atletas simultâneos em quadra por equipe.
enum MatchFormat {
  fiveOnFive(label: '5x5', maxOnCourt: 5, defaultPointLimit: 14.0),
  threeOnThree(label: '3x3', maxOnCourt: 3, defaultPointLimit: 8.5);

  const MatchFormat({
    required this.label,
    required this.maxOnCourt,
    required this.defaultPointLimit,
  });

  final String label;
  final int maxOnCourt;
  final double defaultPointLimit;

  /// Lê o valor gravado por `MatchState.toJson` (`name` do enum). JSON de
  /// versões antigas (sem o campo) ou valor desconhecido caem no 5x5 —
  /// o formato que não bloqueia ninguém.
  static MatchFormat fromName(String? name) {
    for (final MatchFormat format in MatchFormat.values) {
      if (format.name == name) return format;
    }
    return MatchFormat.fiveOnFive;
  }
}

/// Elenco máximo (inscritos na planilha) para uma equipe contar como 3x3
/// na sugestão automática de formato.
const int kThreeOnThreeRosterCutoff = 5;

/// Sugere o formato da partida a partir do tamanho dos elencos inscritos:
/// 3x3 apenas quando AS DUAS equipes têm até [kThreeOnThreeRosterCutoff]
/// atletas; qualquer elenco com 6+ sugere 5x5. O caso misto (ex.: 4 vs 8)
/// cai de propósito no 5x5, o formato que não trava nenhuma equipe.
MatchFormat suggestMatchFormat(int teamARosterSize, int teamBRosterSize) {
  final bool bothSmall = teamARosterSize <= kThreeOnThreeRosterCutoff &&
      teamBRosterSize <= kThreeOnThreeRosterCutoff;
  return bothSmall ? MatchFormat.threeOnThree : MatchFormat.fiveOnFive;
}

bool isAcceptedPointLimit(double value) {
  for (final double accepted in kAcceptedPointLimits) {
    if ((accepted - value).abs() < 0.0001) {
      return true;
    }
  }
  return false;
}
