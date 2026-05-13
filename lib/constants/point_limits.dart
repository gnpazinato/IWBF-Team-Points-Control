/// Limites de pontuação selecionáveis no dropdown da tela de setup.
const List<double> kAcceptedPointLimits = <double>[
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
