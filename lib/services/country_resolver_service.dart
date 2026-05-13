/// Resolve nomes de equipes para um nome canonico em ingles.
///
/// A planilha pode trazer variacoes (`USA`, `U.S.A.`, `United States`,
/// `Estados Unidos`) que devem ser tratadas como a mesma equipe quando
/// possivel. Este servico nao bloqueia nomes desconhecidos: ele apenas
/// indica se um nome foi reconhecido e devolve o nome canonico.
///
/// Bandeiras locais sao adicionadas na Fase 4; por enquanto o servico
/// expoe um placeholder `flagAssetPathFor` para uso futuro.
class CountryResolverService {
  CountryResolverService({Map<String, String>? aliasOverrides})
      : _normalizedAliases = _buildNormalizedAliases(aliasOverrides);

  /// Tabela inicial de aliases. Chave = alias (qualquer forma);
  /// valor = nome canonico em ingles.
  ///
  /// Aliases sao normalizados internamente para comparar sem distincao de
  /// caixa, acentos ou pontuacao.
  static const Map<String, String> _defaultAliases = <String, String>{
    'argentina': 'Argentina',
    'arg': 'Argentina',
    'australia': 'Australia',
    'aus': 'Australia',
    'brasil': 'Brazil',
    'brazil': 'Brazil',
    'bra': 'Brazil',
    'canada': 'Canada',
    'can': 'Canada',
    'china': 'China',
    'chn': 'China',
    'peoples republic of china': 'China',
    'pr china': 'China',
    'colombia': 'Colombia',
    'col': 'Colombia',
    'france': 'France',
    'fra': 'France',
    'germany': 'Germany',
    'deutschland': 'Germany',
    'ger': 'Germany',
    'great britain': 'Great Britain',
    'united kingdom': 'Great Britain',
    'uk': 'Great Britain',
    'gbr': 'Great Britain',
    'iran': 'Iran',
    'irn': 'Iran',
    'islamic republic of iran': 'Iran',
    'italy': 'Italy',
    'italia': 'Italy',
    'ita': 'Italy',
    'japan': 'Japan',
    'jpn': 'Japan',
    'mexico': 'Mexico',
    'mex': 'Mexico',
    'netherlands': 'Netherlands',
    'holland': 'Netherlands',
    'ned': 'Netherlands',
    'paraguay': 'Paraguay',
    'par': 'Paraguay',
    'peru': 'Peru',
    'per': 'Peru',
    'south korea': 'South Korea',
    'republic of korea': 'South Korea',
    'korea': 'South Korea',
    'kor': 'South Korea',
    'spain': 'Spain',
    'espana': 'Spain',
    'esp': 'Spain',
    'turkey': 'Turkey',
    'turkiye': 'Turkey',
    'tur': 'Turkey',
    'united states': 'United States of America',
    'united states of america': 'United States of America',
    'usa': 'United States of America',
    'us': 'United States of America',
    'estados unidos': 'United States of America',
    'uruguay': 'Uruguay',
    'uru': 'Uruguay',
    'venezuela': 'Venezuela',
    'ven': 'Venezuela',
  };

  final Map<String, String> _normalizedAliases;

  static Map<String, String> _buildNormalizedAliases(
      Map<String, String>? overrides) {
    final Map<String, String> table = <String, String>{};
    _defaultAliases.forEach((String alias, String canonical) {
      table[_normalize(alias)] = canonical;
    });
    if (overrides != null) {
      overrides.forEach((String alias, String canonical) {
        table[_normalize(alias)] = canonical;
      });
    }
    return table;
  }

  static String _normalize(String raw) {
    final String trimmed = raw.trim().toLowerCase();
    final StringBuffer buffer = StringBuffer();
    bool lastWasSpace = false;
    for (int i = 0; i < trimmed.length; i++) {
      final String c = trimmed[i];
      if (_isLetterOrDigit(c)) {
        buffer.write(_stripAccent(c));
        lastWasSpace = false;
      } else if (c == ' ' || c == '\t') {
        if (!lastWasSpace && buffer.isNotEmpty) {
          buffer.write(' ');
          lastWasSpace = true;
        }
      }
    }
    final String result = buffer.toString();
    return result.endsWith(' ') ? result.substring(0, result.length - 1) : result;
  }

  static bool _isLetterOrDigit(String c) {
    final int code = c.codeUnitAt(0);
    if (code >= 0x30 && code <= 0x39) return true; // 0-9
    if (code >= 0x61 && code <= 0x7A) return true; // a-z
    // Acentuados latinos
    if (code >= 0xC0 && code <= 0x024F) return true;
    return false;
  }

  static const Map<String, String> _accentMap = <String, String>{
    'a': 'a', 'á': 'a', 'à': 'a', 'â': 'a', 'ã': 'a', 'ä': 'a',
    'e': 'e', 'é': 'e', 'è': 'e', 'ê': 'e', 'ë': 'e',
    'i': 'i', 'í': 'i', 'ì': 'i', 'î': 'i', 'ï': 'i',
    'o': 'o', 'ó': 'o', 'ò': 'o', 'ô': 'o', 'õ': 'o', 'ö': 'o',
    'u': 'u', 'ú': 'u', 'ù': 'u', 'û': 'u', 'ü': 'u',
    'c': 'c', 'ç': 'c',
    'n': 'n', 'ñ': 'n',
  };

  static String _stripAccent(String c) => _accentMap[c] ?? c;

  /// Retorna o nome canonico quando o nome bruto e reconhecido.
  String? resolveCanonical(String rawName) {
    final String key = _normalize(rawName);
    if (key.isEmpty) return null;
    return _normalizedAliases[key];
  }

  /// True se o nome bruto pode ser mapeado para um nome canonico conhecido.
  bool isKnown(String rawName) => resolveCanonical(rawName) != null;

  /// Nome usado na UI. Cai para o proprio nome bruto (trim) quando o
  /// alias nao for conhecido, mantendo o app utilizavel mesmo sem
  /// reconhecer todos os paises.
  String displayNameFor(String rawName) {
    final String? canonical = resolveCanonical(rawName);
    if (canonical != null) return canonical;
    return rawName.trim();
  }

  /// Placeholder para a Fase 4: hoje retorna `null` para todo nome.
  /// Quando bandeiras locais forem adicionadas, este metodo passa a
  /// devolver `assets/flags/<arquivo>.png` para nomes conhecidos.
  String? flagAssetPathFor(String rawName) => null;
}
