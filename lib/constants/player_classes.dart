/// Classes funcionais aceitas pela IWBF para basquetebol em cadeira de rodas.
///
/// Valores em pontos exatos (0.5 em 0.5) usados para somar a pontuação
/// dos cinco atletas em quadra. Qualquer valor fora desta lista deve
/// bloquear a importação da planilha.
const List<double> kAcceptedPlayerClasses = <double>[
  1.0,
  1.5,
  2.0,
  2.5,
  3.0,
  3.5,
  4.0,
  4.5,
];

const double kMinPlayerClass = 1.0;
const double kMaxPlayerClass = 4.5;

/// Verdadeiro se [value] é uma classe funcional aceita pela IWBF.
bool isAcceptedPlayerClass(double value) {
  for (final double accepted in kAcceptedPlayerClasses) {
    if ((accepted - value).abs() < 0.0001) {
      return true;
    }
  }
  return false;
}

/// Converte representação textual (`"2.5"` ou `"2,5"`) para [double].
///
/// Retorna `null` quando o texto não puder ser interpretado ou quando
/// o número não estiver entre as classes aceitas.
double? parsePlayerClass(String? raw) {
  if (raw == null) return null;
  final String trimmed = raw.trim();
  if (trimmed.isEmpty) return null;
  final String normalized = trimmed.replaceAll(',', '.');
  final double? parsed = double.tryParse(normalized);
  if (parsed == null) return null;
  if (!isAcceptedPlayerClass(parsed)) return null;
  return parsed;
}
