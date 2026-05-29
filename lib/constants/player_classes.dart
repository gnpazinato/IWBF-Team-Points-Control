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

/// Recupera uma classe funcional que o Excel autoformatou como data.
///
/// Ao digitar `2.5`, o Excel costuma converter para uma data (ex.:
/// `2026-05-02` ou `2026-02-05`, conforme o locale). Como o leitor de
/// células normaliza datas para `YYYY-MM-DD`, aqui extraímos mês/dia e
/// testamos as duas ordens possíveis (`dia + mês/10` e `mês + dia/10`),
/// aceitando a primeira que resultar numa classe válida.
///
/// Retorna `null` quando o texto não é uma data nem reconstrói uma classe
/// aceita — deixando o fluxo normal reportar a classe inválida.
double? classFromDateLikeString(String? raw) {
  if (raw == null) return null;
  final RegExp iso = RegExp(r'^\d{4}-(\d{1,2})-(\d{1,2})$');
  final RegExpMatch? m = iso.firstMatch(raw.trim());
  if (m == null) return null;
  final int month = int.parse(m.group(1)!);
  final int day = int.parse(m.group(2)!);
  for (final double candidate in <double>[day + month / 10, month + day / 10]) {
    if (isAcceptedPlayerClass(candidate)) return candidate;
  }
  return null;
}
