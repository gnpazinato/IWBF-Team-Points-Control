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

/// Quantidade máxima de atletas selecionáveis simultaneamente por equipe.
const int kMaxPlayersPerTeam = 5;

bool isAcceptedPointLimit(double value) {
  for (final double accepted in kAcceptedPointLimits) {
    if ((accepted - value).abs() < 0.0001) {
      return true;
    }
  }
  return false;
}
