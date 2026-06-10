/// Resolve nomes de equipes para um nome canonico em ingles.
///
/// A planilha pode trazer variacoes (`USA`, `U.S.A.`, `United States`,
/// `Estados Unidos`) que devem ser tratadas como a mesma equipe quando
/// possivel. Este servico nao bloqueia nomes desconhecidos: ele apenas
/// indica se um nome foi reconhecido e devolve o nome canonico.
///
/// Bandeiras: usamos o emoji nacional Unicode (par de Regional Indicator
/// Symbols) derivado do ISO 3166-1 alpha-2 do pais. Para paises desconhecidos
/// retornamos `null` e o widget cai num icone generico.
class CountryResolverService {
  CountryResolverService({Map<String, String>? aliasOverrides})
      : _normalizedAliases = _buildNormalizedAliases(aliasOverrides);

  /// Tabela inicial de aliases. Chave = alias (qualquer forma);
  /// valor = nome canonico em ingles.
  ///
  /// Aliases sao normalizados internamente para comparar sem distincao de
  /// caixa, acentos ou pontuacao. A cobertura busca incluir todos os paises
  /// membros das quatro zonas da IWBF (Americas, Europa, Asia/Oceania,
  /// Africa) para evitar o warning "Unknown team" em planilhas oficiais.
  static const Map<String, String> _defaultAliases = <String, String>{
    // ---------------- Americas ----------------
    'argentina': 'Argentina',
    'arg': 'Argentina',
    'bolivia': 'Bolivia',
    'bol': 'Bolivia',
    'brasil': 'Brazil',
    'brazil': 'Brazil',
    'bra': 'Brazil',
    'canada': 'Canada',
    'can': 'Canada',
    'chile': 'Chile',
    'chi': 'Chile',
    'chl': 'Chile',
    'colombia': 'Colombia',
    'col': 'Colombia',
    'costa rica': 'Costa Rica',
    'crc': 'Costa Rica',
    'cuba': 'Cuba',
    'cub': 'Cuba',
    'dominican republic': 'Dominican Republic',
    'republica dominicana': 'Dominican Republic',
    'dom': 'Dominican Republic',
    'ecuador': 'Ecuador',
    'ecu': 'Ecuador',
    'el salvador': 'El Salvador',
    'esa': 'El Salvador',
    'guatemala': 'Guatemala',
    'gua': 'Guatemala',
    'haiti': 'Haiti',
    'hai': 'Haiti',
    'honduras': 'Honduras',
    'hon': 'Honduras',
    'mexico': 'Mexico',
    'mex': 'Mexico',
    'nicaragua': 'Nicaragua',
    'nca': 'Nicaragua',
    'nic': 'Nicaragua',
    'panama': 'Panama',
    'pan': 'Panama',
    'paraguay': 'Paraguay',
    'par': 'Paraguay',
    'peru': 'Peru',
    'per': 'Peru',
    'puerto rico': 'Puerto Rico',
    'pur': 'Puerto Rico',
    'united states': 'United States of America',
    'united states of america': 'United States of America',
    'united states america': 'United States of America',
    'usa': 'United States of America',
    'us': 'United States of America',
    'estados unidos': 'United States of America',
    'estados unidos de america': 'United States of America',
    'eua': 'United States of America',
    'uruguay': 'Uruguay',
    'uru': 'Uruguay',
    'venezuela': 'Venezuela',
    'ven': 'Venezuela',

    // ---------------- Europa ----------------
    'austria': 'Austria',
    'aut': 'Austria',
    'belgium': 'Belgium',
    'belgique': 'Belgium',
    'bel': 'Belgium',
    'bosnia and herzegovina': 'Bosnia and Herzegovina',
    'bosnia herzegovina': 'Bosnia and Herzegovina',
    'bosnia': 'Bosnia and Herzegovina',
    'bih': 'Bosnia and Herzegovina',
    'croatia': 'Croatia',
    'hrvatska': 'Croatia',
    'cro': 'Croatia',
    'czech republic': 'Czech Republic',
    'czechia': 'Czech Republic',
    'cze': 'Czech Republic',
    'denmark': 'Denmark',
    'danmark': 'Denmark',
    'den': 'Denmark',
    'estonia': 'Estonia',
    'est': 'Estonia',
    'finland': 'Finland',
    'suomi': 'Finland',
    'fin': 'Finland',
    'france': 'France',
    'fra': 'France',
    'germany': 'Germany',
    'deutschland': 'Germany',
    'ger': 'Germany',
    'great britain': 'Great Britain',
    'united kingdom': 'Great Britain',
    'uk': 'Great Britain',
    'gb': 'Great Britain',
    'gbr': 'Great Britain',
    'britain': 'Great Britain',
    'greece': 'Greece',
    'hellas': 'Greece',
    'gre': 'Greece',
    'hungary': 'Hungary',
    'magyarorszag': 'Hungary',
    'hun': 'Hungary',
    'iceland': 'Iceland',
    'island': 'Iceland',
    'isl': 'Iceland',
    'ireland': 'Ireland',
    'irl': 'Ireland',
    'israel': 'Israel',
    'isr': 'Israel',
    'italy': 'Italy',
    'italia': 'Italy',
    'ita': 'Italy',
    'latvia': 'Latvia',
    'latvija': 'Latvia',
    'lat': 'Latvia',
    'lva': 'Latvia',
    'lithuania': 'Lithuania',
    'lietuva': 'Lithuania',
    'ltu': 'Lithuania',
    'luxembourg': 'Luxembourg',
    'lux': 'Luxembourg',
    'netherlands': 'Netherlands',
    'holland': 'Netherlands',
    'ned': 'Netherlands',
    'norway': 'Norway',
    'norge': 'Norway',
    'nor': 'Norway',
    'poland': 'Poland',
    'polska': 'Poland',
    'pol': 'Poland',
    'portugal': 'Portugal',
    'por': 'Portugal',
    'prt': 'Portugal',
    'romania': 'Romania',
    'rou': 'Romania',
    'russia': 'Russia',
    'russian federation': 'Russia',
    'rus': 'Russia',
    'serbia': 'Serbia',
    'srbija': 'Serbia',
    'srb': 'Serbia',
    'slovakia': 'Slovakia',
    'svk': 'Slovakia',
    'slovenia': 'Slovenia',
    'slovenija': 'Slovenia',
    'slo': 'Slovenia',
    'svn': 'Slovenia',
    'spain': 'Spain',
    'espana': 'Spain',
    'esp': 'Spain',
    'sweden': 'Sweden',
    'sverige': 'Sweden',
    'swe': 'Sweden',
    'switzerland': 'Switzerland',
    'suisse': 'Switzerland',
    'schweiz': 'Switzerland',
    'sui': 'Switzerland',
    'turkey': 'Turkey',
    'turkiye': 'Turkey',
    'tur': 'Turkey',
    'ukraine': 'Ukraine',
    'ukr': 'Ukraine',

    // ---------------- Asia / Oceania ----------------
    'afghanistan': 'Afghanistan',
    'afg': 'Afghanistan',
    'australia': 'Australia',
    'aus': 'Australia',
    'cambodia': 'Cambodia',
    'cam': 'Cambodia',
    'china': 'China',
    'chn': 'China',
    'peoples republic of china': 'China',
    'pr china': 'China',
    'prc': 'China',
    'chinese taipei': 'Chinese Taipei',
    'taiwan': 'Chinese Taipei',
    'tpe': 'Chinese Taipei',
    'hong kong': 'Hong Kong',
    'hkg': 'Hong Kong',
    'india': 'India',
    'ind': 'India',
    'indonesia': 'Indonesia',
    'ina': 'Indonesia',
    'idn': 'Indonesia',
    'iran': 'Iran',
    'irn': 'Iran',
    'iri': 'Iran',
    'islamic republic of iran': 'Iran',
    'iraq': 'Iraq',
    'irq': 'Iraq',
    'japan': 'Japan',
    'jpn': 'Japan',
    'jordan': 'Jordan',
    'jor': 'Jordan',
    'kazakhstan': 'Kazakhstan',
    'kaz': 'Kazakhstan',
    'lebanon': 'Lebanon',
    'lbn': 'Lebanon',
    'malaysia': 'Malaysia',
    'mas': 'Malaysia',
    'mongolia': 'Mongolia',
    'mgl': 'Mongolia',
    'new zealand': 'New Zealand',
    'nzl': 'New Zealand',
    'pakistan': 'Pakistan',
    'pak': 'Pakistan',
    'philippines': 'Philippines',
    'phi': 'Philippines',
    'qatar': 'Qatar',
    'qat': 'Qatar',
    'saudi arabia': 'Saudi Arabia',
    'ksa': 'Saudi Arabia',
    'singapore': 'Singapore',
    'sgp': 'Singapore',
    'south korea': 'South Korea',
    'republic of korea': 'South Korea',
    'korea republic': 'South Korea',
    'korea': 'South Korea',
    'kor': 'South Korea',
    'sri lanka': 'Sri Lanka',
    'sri': 'Sri Lanka',
    'syria': 'Syria',
    'syrian arab republic': 'Syria',
    'syr': 'Syria',
    'thailand': 'Thailand',
    'tha': 'Thailand',
    'uzbekistan': 'Uzbekistan',
    'uzb': 'Uzbekistan',
    'vietnam': 'Vietnam',
    'viet nam': 'Vietnam',
    'vie': 'Vietnam',
    'vnm': 'Vietnam',

    // ---------------- Africa ----------------
    'algeria': 'Algeria',
    'algerie': 'Algeria',
    'alg': 'Algeria',
    'angola': 'Angola',
    'ang': 'Angola',
    'ago': 'Angola',
    'botswana': 'Botswana',
    'bot': 'Botswana',
    'bwa': 'Botswana',
    'cameroon': 'Cameroon',
    'cameroun': 'Cameroon',
    'cmr': 'Cameroon',
    // O `_normalize` derruba a apostrofe sem inserir espaco, entao
    // "Cote d'Ivoire" vira "cote divoire". Mantemos as duas formas
    // (com e sem espaco) para cobrir variacoes manuais.
    'cote divoire': "Côte d'Ivoire",
    'cote d ivoire': "Côte d'Ivoire",
    'ivory coast': "Côte d'Ivoire",
    'civ': "Côte d'Ivoire",
    'congo': 'Congo',
    'republic of the congo': 'Congo',
    'cgo': 'Congo',
    'cog': 'Congo',
    'dr congo': 'DR Congo',
    'democratic republic of the congo': 'DR Congo',
    'congo dr': 'DR Congo',
    'cod': 'DR Congo',
    'egypt': 'Egypt',
    'egy': 'Egypt',
    'ethiopia': 'Ethiopia',
    'eth': 'Ethiopia',
    'ghana': 'Ghana',
    'gha': 'Ghana',
    'kenya': 'Kenya',
    'ken': 'Kenya',
    'libya': 'Libya',
    'lba': 'Libya',
    'lby': 'Libya',
    'madagascar': 'Madagascar',
    'mad': 'Madagascar',
    'mdg': 'Madagascar',
    'mali': 'Mali',
    'mli': 'Mali',
    'morocco': 'Morocco',
    'maroc': 'Morocco',
    'mar': 'Morocco',
    'mozambique': 'Mozambique',
    'mocambique': 'Mozambique',
    'moz': 'Mozambique',
    'namibia': 'Namibia',
    'nam': 'Namibia',
    'nigeria': 'Nigeria',
    'ngr': 'Nigeria',
    'nga': 'Nigeria',
    'rwanda': 'Rwanda',
    'rwa': 'Rwanda',
    'senegal': 'Senegal',
    'sen': 'Senegal',
    'south africa': 'South Africa',
    'rsa': 'South Africa',
    'zaf': 'South Africa',
    'sudan': 'Sudan',
    'sdn': 'Sudan',
    'tanzania': 'Tanzania',
    'tan': 'Tanzania',
    'tza': 'Tanzania',
    'tunisia': 'Tunisia',
    'tunisie': 'Tunisia',
    'tun': 'Tunisia',
    'uganda': 'Uganda',
    'uga': 'Uganda',
    'zambia': 'Zambia',
    'zam': 'Zambia',
    'zmb': 'Zambia',
    'zimbabwe': 'Zimbabwe',
    'zim': 'Zimbabwe',
    'zwe': 'Zimbabwe',
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

  /// Codigo ISO 3166-1 alpha-2 (`BR`, `AR`, `US`...) para o nome canonico.
  /// Retorna `null` quando o pais nao for reconhecido.
  String? countryCodeFor(String rawName) {
    final String? canonical = resolveCanonical(rawName);
    if (canonical == null) return null;
    return _countryCodes[canonical];
  }

  /// Bandeira Unicode (par de Regional Indicator Symbols) para o pais.
  /// Retorna `null` quando o pais nao for reconhecido.
  String? flagEmojiFor(String rawName) {
    final String? code = countryCodeFor(rawName);
    if (code == null || code.length != 2) return null;
    return countryFlagEmoji(code);
  }

  /// Mapa canonico -> ISO 3166-1 alpha-2.
  static const Map<String, String> _countryCodes = <String, String>{
    // Americas
    'Argentina': 'AR',
    'Bolivia': 'BO',
    'Brazil': 'BR',
    'Canada': 'CA',
    'Chile': 'CL',
    'Colombia': 'CO',
    'Costa Rica': 'CR',
    'Cuba': 'CU',
    'Dominican Republic': 'DO',
    'Ecuador': 'EC',
    'El Salvador': 'SV',
    'Guatemala': 'GT',
    'Haiti': 'HT',
    'Honduras': 'HN',
    'Mexico': 'MX',
    'Nicaragua': 'NI',
    'Panama': 'PA',
    'Paraguay': 'PY',
    'Peru': 'PE',
    'Puerto Rico': 'PR',
    'United States of America': 'US',
    'Uruguay': 'UY',
    'Venezuela': 'VE',
    // Europa
    'Austria': 'AT',
    'Belgium': 'BE',
    'Bosnia and Herzegovina': 'BA',
    'Croatia': 'HR',
    'Czech Republic': 'CZ',
    'Denmark': 'DK',
    'Estonia': 'EE',
    'Finland': 'FI',
    'France': 'FR',
    'Germany': 'DE',
    'Great Britain': 'GB',
    'Greece': 'GR',
    'Hungary': 'HU',
    'Iceland': 'IS',
    'Ireland': 'IE',
    'Israel': 'IL',
    'Italy': 'IT',
    'Latvia': 'LV',
    'Lithuania': 'LT',
    'Luxembourg': 'LU',
    'Netherlands': 'NL',
    'Norway': 'NO',
    'Poland': 'PL',
    'Portugal': 'PT',
    'Romania': 'RO',
    'Russia': 'RU',
    'Serbia': 'RS',
    'Slovakia': 'SK',
    'Slovenia': 'SI',
    'Spain': 'ES',
    'Sweden': 'SE',
    'Switzerland': 'CH',
    'Turkey': 'TR',
    'Ukraine': 'UA',
    // Asia / Oceania
    'Afghanistan': 'AF',
    'Australia': 'AU',
    'Cambodia': 'KH',
    'China': 'CN',
    'Chinese Taipei': 'TW',
    'Hong Kong': 'HK',
    'India': 'IN',
    'Indonesia': 'ID',
    'Iran': 'IR',
    'Iraq': 'IQ',
    'Japan': 'JP',
    'Jordan': 'JO',
    'Kazakhstan': 'KZ',
    'Lebanon': 'LB',
    'Malaysia': 'MY',
    'Mongolia': 'MN',
    'New Zealand': 'NZ',
    'Pakistan': 'PK',
    'Philippines': 'PH',
    'Qatar': 'QA',
    'Saudi Arabia': 'SA',
    'Singapore': 'SG',
    'South Korea': 'KR',
    'Sri Lanka': 'LK',
    'Syria': 'SY',
    'Thailand': 'TH',
    'Uzbekistan': 'UZ',
    'Vietnam': 'VN',
    // Africa
    'Algeria': 'DZ',
    'Angola': 'AO',
    'Botswana': 'BW',
    'Cameroon': 'CM',
    'Congo': 'CG',
    'DR Congo': 'CD',
    "Côte d'Ivoire": 'CI',
    'Egypt': 'EG',
    'Ethiopia': 'ET',
    'Ghana': 'GH',
    'Kenya': 'KE',
    'Libya': 'LY',
    'Madagascar': 'MG',
    'Mali': 'ML',
    'Morocco': 'MA',
    'Mozambique': 'MZ',
    'Namibia': 'NA',
    'Nigeria': 'NG',
    'Rwanda': 'RW',
    'Senegal': 'SN',
    'South Africa': 'ZA',
    'Sudan': 'SD',
    'Tanzania': 'TZ',
    'Tunisia': 'TN',
    'Uganda': 'UG',
    'Zambia': 'ZM',
    'Zimbabwe': 'ZW',
  };
}

/// Converte um codigo alpha-2 (`BR`) no par de Regional Indicator Symbols
/// que renderiza a bandeira (`🇧🇷`). A maioria das plataformas Web/Android
/// usa a fonte do sistema para renderizar; em Web e tablet/celular Android
/// modernos o suporte e confiavel.
String countryFlagEmoji(String alpha2) {
  if (alpha2.length != 2) return '';
  final String code = alpha2.toUpperCase();
  const int base = 0x1F1E6; // Regional Indicator Symbol Letter A
  const int aChar = 0x41; // 'A'
  final int first = base + (code.codeUnitAt(0) - aChar);
  final int second = base + (code.codeUnitAt(1) - aChar);
  return String.fromCharCodes(<int>[first, second]);
}
