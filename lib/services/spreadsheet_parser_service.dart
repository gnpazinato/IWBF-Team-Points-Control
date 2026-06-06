import 'dart:typed_data';

import 'package:excel/excel.dart' as xlsx;

import '../constants/player_classes.dart';
import '../models/player.dart';
import '../models/team.dart';
import 'country_resolver_service.dart';

enum ParseIssueSeverity { error, warning }

enum ParseIssueCategory {
  fileUnreadable,
  emptyFile,
  missingRequiredColumn,
  missingShirtNumber,
  missingPlayerName,
  invalidPlayerClass,
  missingPlayerClass,
  missingDateOfBirth,
  unknownTeam,
  duplicateShirtNumber,
}

class ParseIssue {
  const ParseIssue({
    required this.category,
    required this.severity,
    required this.message,
    this.sheetName,
    this.rowNumber,
    this.teamName,
    this.playerLabel,
  });

  final ParseIssueCategory category;
  final ParseIssueSeverity severity;
  final String message;
  final String? sheetName;
  final int? rowNumber;
  final String? teamName;
  final String? playerLabel;

  bool get isBlocking => severity == ParseIssueSeverity.error;

  @override
  String toString() => '[$severity:$category] $message'
      '${sheetName != null ? " (sheet: $sheetName)" : ""}'
      '${rowNumber != null ? " (row $rowNumber)" : ""}';
}

/// Estrutura intermediária independente do pacote `excel`.
///
/// Útil para testar a lógica de parsing sem depender de bytes binários.
class SheetData {
  const SheetData({required this.name, required this.rows});

  final String name;
  final List<List<String?>> rows;
}

class SpreadsheetParseResult {
  const SpreadsheetParseResult({
    required this.teams,
    required this.issues,
    this.competitionName,
  });

  factory SpreadsheetParseResult.error(
    String message,
    ParseIssueCategory category,
  ) {
    return SpreadsheetParseResult(
      teams: const <Team>[],
      issues: <ParseIssue>[
        ParseIssue(
          category: category,
          severity: ParseIssueSeverity.error,
          message: message,
        ),
      ],
    );
  }

  final List<Team> teams;
  final List<ParseIssue> issues;
  final String? competitionName;

  bool get hasBlockingIssues =>
      issues.any((ParseIssue i) => i.severity == ParseIssueSeverity.error);

  int get playerCount {
    int total = 0;
    for (final Team t in teams) {
      total += t.players.length;
    }
    return total;
  }
}

/// Colunas obrigatórias por linha; usadas tanto no modelo de aba única
/// quanto no modelo de uma aba por equipe (com `team_name` opcional aí).
/// Colunas *lógicas* obrigatórias. São resolvidas via aliases
/// (`number`↔`shirt_number`, `name`↔`surname`+`first_name`, `class`↔
/// `player_class`...). `dob` e `gender` são **opcionais** (não impeditivos).
class _RequiredColumns {
  static const List<String> singleSheet = <String>[
    'team_name',
    'number',
    'name',
    'class',
  ];
  static const List<String> perTeamSheet = <String>[
    'number',
    'name',
    'class',
  ];
}

class SpreadsheetParserService {
  SpreadsheetParserService({CountryResolverService? resolver})
      : resolver = resolver ?? CountryResolverService();

  final CountryResolverService resolver;

  /// Lê bytes `.xlsx` e produz o resultado completo.
  SpreadsheetParseResult parseBytes(Uint8List bytes) {
    final List<SheetData>? sheets = _readBytes(bytes);
    if (sheets == null) {
      return SpreadsheetParseResult.error(
        'Could not read .xlsx file',
        ParseIssueCategory.fileUnreadable,
      );
    }
    return parseSheets(sheets);
  }

  /// Entrada testável diretamente com dados em memória.
  SpreadsheetParseResult parseSheets(List<SheetData> sheets) {
    final List<SheetData> nonEmpty = sheets
        .where((SheetData s) => s.rows.any(_rowHasContent))
        .toList();

    if (nonEmpty.isEmpty) {
      return SpreadsheetParseResult.error(
        'Spreadsheet has no data',
        ParseIssueCategory.emptyFile,
      );
    }

    // O CONTEÚDO decide o modelo — o título da aba é irrelevante.
    //
    // Uma aba que tem coluna de equipe (`team_name`/`country`/...) lista
    // as equipes por linha: é uma planilha "todas as equipes". Se houver
    // ao menos uma assim, ela(s) é(são) a fonte de verdade — combinamos
    // todas e **ignoramos** as demais abas (resumos, instruções, etc.).
    // Como o nome da equipe vem da coluna, o título da aba não importa.
    //
    // Se NENHUMA aba tem coluna de equipe, caímos no modelo "uma aba por
    // equipe": cada aba é uma equipe e o nome vem do título da aba.
    final List<SheetData> allTeamsSheets =
        nonEmpty.where(_hasTeamColumn).toList();
    if (allTeamsSheets.isNotEmpty) {
      return _parseTeamColumnSheets(allTeamsSheets);
    }

    return _parseMultiSheet(nonEmpty);
  }

  // ---------------------------------------------------------------------------
  // Modelo "todas as equipes" (uma ou mais abas com coluna de equipe)
  // ---------------------------------------------------------------------------

  /// Se a aba tem uma coluna de equipe (`team_name`/`country`/...).
  bool _hasTeamColumn(SheetData sheet) {
    final _HeaderInfo? header = _readHeader(sheet);
    return header != null && _columnIndex(header, 'team_name') != null;
  }

  /// Combina uma ou mais abas que listam equipes por linha (cada uma com
  /// coluna de equipe) num único conjunto de equipes. Abas múltiplas são
  /// mescladas no mesmo mapa de buckets, então a mesma equipe espalhada
  /// por abas distintas (ex.: aba "Men" + aba "Women") é unificada por id.
  SpreadsheetParseResult _parseTeamColumnSheets(List<SheetData> sheets) {
    final List<ParseIssue> issues = <ParseIssue>[];
    final Map<String, _TeamBucket> buckets = <String, _TeamBucket>{};
    String? competitionName;

    for (final SheetData sheet in sheets) {
      final _HeaderInfo? header = _readHeader(sheet);
      if (header == null) {
        issues.add(ParseIssue(
          category: ParseIssueCategory.missingRequiredColumn,
          severity: ParseIssueSeverity.error,
          message: 'Sheet "${sheet.name}" has no valid header row',
          sheetName: sheet.name,
        ));
        continue;
      }

      final List<String> missing = <String>[];
      for (final String required in _RequiredColumns.singleSheet) {
        if (!_hasLogicalColumn(header, required)) {
          missing.add(required);
        }
      }
      if (missing.isNotEmpty) {
        issues.add(ParseIssue(
          category: ParseIssueCategory.missingRequiredColumn,
          severity: ParseIssueSeverity.error,
          message: 'Required columns missing: ${missing.join(", ")}',
          sheetName: sheet.name,
        ));
        continue;
      }

      for (int i = header.firstDataRow; i < sheet.rows.length; i++) {
        final List<String?> row = sheet.rows[i];
        if (!_rowHasContent(row)) continue;

        final String rawTeam =
            (_readLogical(row, header, 'team_name') ?? '').trim();
        if (rawTeam.isEmpty) {
          issues.add(ParseIssue(
            category: ParseIssueCategory.missingRequiredColumn,
            severity: ParseIssueSeverity.error,
            message: 'Row is missing team_name',
            sheetName: sheet.name,
            rowNumber: i + 1,
          ));
          continue;
        }

        competitionName ??= _readLogical(row, header, 'competition');

        // Quem decide o gênero do time é o gênero do atleta, não o nome
        // bruto. O "Brasil Men" do `team_name` é só uma dica — strippamos
        // pra usar o "Brasil" canônico.
        final String strippedTeam = _stripGenderKeyword(rawTeam);
        final String baseDisplay = resolver.displayNameFor(strippedTeam);
        final PlayerGender playerGender =
            _genderFromString(_readLogical(row, header, 'gender'));
        final TeamGender teamGender =
            _teamGenderFromPlayerGender(playerGender);
        final String teamId = _teamIdWithGender(baseDisplay, teamGender);

        if (!resolver.isKnown(strippedTeam)) {
          if (!issues.any((ParseIssue x) =>
              x.category == ParseIssueCategory.unknownTeam &&
              x.teamName == baseDisplay)) {
            issues.add(ParseIssue(
              category: ParseIssueCategory.unknownTeam,
              severity: ParseIssueSeverity.warning,
              message: 'Unknown team: "$rawTeam"',
              sheetName: sheet.name,
              teamName: baseDisplay,
            ));
          }
        }

        final Player? player = _buildPlayer(
          row: row,
          header: header,
          sheetName: sheet.name,
          rowNumber: i + 1,
          teamId: teamId,
          teamName: baseDisplay,
          issues: issues,
        );
        if (player != null) {
          final _TeamBucket bucket = buckets.putIfAbsent(
            teamId,
            () => _TeamBucket(
              id: teamId,
              displayName: baseDisplay,
              gender: teamGender,
            ),
          );
          bucket.players.add(player);
        }
      }
    }

    final List<Team> teams = buckets.values
        .map((_TeamBucket b) => Team(
              id: b.id,
              teamName: b.displayName,
              gender: b.gender,
              players: b.players,
            ))
        .toList();

    _detectDuplicateShirtNumbers(teams, issues, null);

    return SpreadsheetParseResult(
      teams: teams,
      issues: issues,
      competitionName: competitionName,
    );
  }

  // ---------------------------------------------------------------------------
  // Modelo uma aba por equipe
  // ---------------------------------------------------------------------------

  SpreadsheetParseResult _parseMultiSheet(List<SheetData> sheets) {
    final List<ParseIssue> issues = <ParseIssue>[];
    final List<Team> teams = <Team>[];
    String? competitionName;

    for (final SheetData sheet in sheets) {
      final _HeaderInfo? header = _readHeader(sheet);
      if (header == null) {
        issues.add(ParseIssue(
          category: ParseIssueCategory.missingRequiredColumn,
          severity: ParseIssueSeverity.error,
          message: 'Sheet "${sheet.name}" has no valid header row',
          sheetName: sheet.name,
        ));
        continue;
      }

      final List<String> missing = <String>[];
      for (final String required in _RequiredColumns.perTeamSheet) {
        if (!_hasLogicalColumn(header, required)) {
          missing.add(required);
        }
      }
      if (missing.isNotEmpty) {
        issues.add(ParseIssue(
          category: ParseIssueCategory.missingRequiredColumn,
          severity: ParseIssueSeverity.error,
          message: 'Required columns missing: ${missing.join(", ")}',
          sheetName: sheet.name,
        ));
        continue;
      }

      String teamName = sheet.name.trim();
      String? rawTeamFromColumn;
      if (_columnIndex(header, 'team_name') != null &&
          header.firstDataRow < sheet.rows.length) {
        rawTeamFromColumn = _readLogical(
          sheet.rows[header.firstDataRow],
          header,
          'team_name',
        );
      }
      if (rawTeamFromColumn != null && rawTeamFromColumn.isNotEmpty) {
        teamName = rawTeamFromColumn;
      }

      // Strip do "Men"/"Women" do nome da aba (caso a planilha esteja
      // explícita) — o gênero verdadeiro vem do gênero do atleta.
      final String strippedTeam = _stripGenderKeyword(teamName);
      final String baseDisplay = resolver.displayNameFor(strippedTeam);
      if (!resolver.isKnown(strippedTeam)) {
        issues.add(ParseIssue(
          category: ParseIssueCategory.unknownTeam,
          severity: ParseIssueSeverity.warning,
          message: 'Unknown team: "$teamName"',
          sheetName: sheet.name,
          teamName: baseDisplay,
        ));
      }

      // Players agrupados por gênero dentro da aba. Em planilhas oficiais
      // single-gender, todos caem no mesmo bucket. Em planilhas mistas,
      // a aba vira 2 (ou 3) equipes (Men/Women/Unspecified).
      final Map<String, _TeamBucket> buckets = <String, _TeamBucket>{};
      for (int i = header.firstDataRow; i < sheet.rows.length; i++) {
        final List<String?> row = sheet.rows[i];
        if (!_rowHasContent(row)) continue;

        competitionName ??= _readLogical(row, header, 'competition');

        final PlayerGender playerGender =
            _genderFromString(_readLogical(row, header, 'gender'));
        final TeamGender teamGender =
            _teamGenderFromPlayerGender(playerGender);
        final String teamId = _teamIdWithGender(baseDisplay, teamGender);

        final Player? player = _buildPlayer(
          row: row,
          header: header,
          sheetName: sheet.name,
          rowNumber: i + 1,
          teamId: teamId,
          teamName: baseDisplay,
          issues: issues,
        );
        if (player != null) {
          final _TeamBucket bucket = buckets.putIfAbsent(
            teamId,
            () => _TeamBucket(
              id: teamId,
              displayName: baseDisplay,
              gender: teamGender,
            ),
          );
          bucket.players.add(player);
        }
      }

      for (final _TeamBucket bucket in buckets.values) {
        teams.add(Team(
          id: bucket.id,
          teamName: bucket.displayName,
          gender: bucket.gender,
          players: bucket.players,
        ));
      }
    }

    _detectDuplicateShirtNumbers(teams, issues, null);

    return SpreadsheetParseResult(
      teams: teams,
      issues: issues,
      competitionName: competitionName,
    );
  }

  // ---------------------------------------------------------------------------
  // Helpers de leitura de célula
  // ---------------------------------------------------------------------------

  Player? _buildPlayer({
    required List<String?> row,
    required _HeaderInfo header,
    required String sheetName,
    required int rowNumber,
    required String teamId,
    required String teamName,
    required List<ParseIssue> issues,
  }) {
    final String? shirtRaw = _readLogical(row, header, 'number');
    String name = (_readLogical(row, header, 'name') ?? '').trim();
    if (name.isEmpty) {
      // Sem coluna de nome completo: juntamos sobrenome + nome no mesmo
      // formato dos templates ("SOBRENOME, Nome", ex.: "SILVA, João").
      // Cada parte é resolvida por aliases (`last_name`, `given_name`...).
      final String surname = (_readLogical(row, header, 'surname') ?? '').trim();
      final String firstName =
          (_readLogical(row, header, 'first_name') ?? '').trim();
      name = _composeName(surname, firstName);
    }
    final String classRaw = (_readLogical(row, header, 'class') ?? '').trim();
    final String dobRaw = (_readLogical(row, header, 'dob') ?? '').trim();
    final String? genderRaw = _readLogical(row, header, 'gender');

    final String playerLabel = name.isEmpty ? '(unnamed)' : name;

    bool valid = true;

    if (name.isEmpty) {
      issues.add(ParseIssue(
        category: ParseIssueCategory.missingPlayerName,
        severity: ParseIssueSeverity.error,
        message: 'Player is missing name',
        sheetName: sheetName,
        rowNumber: rowNumber,
        teamName: teamName,
        playerLabel: playerLabel,
      ));
      valid = false;
    }

    final int? shirtNumber = _parseShirtNumber(shirtRaw);
    if (shirtNumber == null) {
      issues.add(ParseIssue(
        category: ParseIssueCategory.missingShirtNumber,
        severity: ParseIssueSeverity.error,
        message: 'Player is missing shirt number',
        sheetName: sheetName,
        rowNumber: rowNumber,
        teamName: teamName,
        playerLabel: playerLabel,
      ));
      valid = false;
    }

    double? playerClass;
    if (classRaw.isEmpty) {
      issues.add(ParseIssue(
        category: ParseIssueCategory.missingPlayerClass,
        severity: ParseIssueSeverity.error,
        message: 'Player is missing functional class',
        sheetName: sheetName,
        rowNumber: rowNumber,
        teamName: teamName,
        playerLabel: playerLabel,
      ));
      valid = false;
    } else {
      playerClass =
          parsePlayerClass(classRaw) ?? classFromDateLikeString(classRaw);
      if (playerClass == null) {
        issues.add(ParseIssue(
          category: ParseIssueCategory.invalidPlayerClass,
          severity: ParseIssueSeverity.error,
          message:
              'Invalid functional class for $playerLabel (accepted values: ${kAcceptedPlayerClasses.join(", ")})',
          sheetName: sheetName,
          rowNumber: rowNumber,
          teamName: teamName,
          playerLabel: playerLabel,
        ));
        valid = false;
      }
    }

    // Data de nascimento é OPCIONAL: em branco não gera issue; um valor
    // presente mas inválido vira apenas warning (não bloqueia a importação).
    DateTime? dob;
    if (dobRaw.isNotEmpty) {
      dob = _parseDateOfBirth(dobRaw);
      if (dob == null) {
        issues.add(ParseIssue(
          category: ParseIssueCategory.missingDateOfBirth,
          severity: ParseIssueSeverity.warning,
          message: 'Date of birth "$dobRaw" is invalid and was ignored',
          sheetName: sheetName,
          rowNumber: rowNumber,
          teamName: teamName,
          playerLabel: playerLabel,
        ));
      }
    }

    if (!valid) return null;

    return Player(
      id: '$teamId::${shirtNumber!}',
      teamName: teamName,
      shirtNumber: shirtNumber,
      name: name,
      playerClass: playerClass!,
      dateOfBirth: dob,
      gender: _genderFromString(genderRaw),
    );
  }

  void _detectDuplicateShirtNumbers(
    List<Team> teams,
    List<ParseIssue> issues,
    String? sheetName,
  ) {
    for (final Team team in teams) {
      final Map<int, int> count = <int, int>{};
      for (final Player p in team.players) {
        count[p.shirtNumber] = (count[p.shirtNumber] ?? 0) + 1;
      }
      count.forEach((int number, int n) {
        if (n > 1) {
          issues.add(ParseIssue(
            category: ParseIssueCategory.duplicateShirtNumber,
            severity: ParseIssueSeverity.warning,
            message:
                'Shirt number #$number appears $n times in ${team.teamName}',
            sheetName: sheetName,
            teamName: team.teamName,
          ));
        }
      });
    }
  }

  String _teamIdFromName(String name) {
    final StringBuffer buffer = StringBuffer('team-');
    for (int i = 0; i < name.length; i++) {
      final String c = name[i].toLowerCase();
      final int code = c.codeUnitAt(0);
      final bool isLower = code >= 0x61 && code <= 0x7A;
      final bool isDigit = code >= 0x30 && code <= 0x39;
      if (isLower || isDigit) {
        buffer.write(c);
      } else if (c == ' ' || c == '-' || c == '_') {
        buffer.write('-');
      }
    }
    return buffer.toString();
  }

  /// ID determinístico do time considerando o sufixo de gênero (`-men`,
  /// `-women`, vazio quando unspecified, `-mixed` quando misto). Garante
  /// que `Brazil` masculino e `Brazil` feminino têm ids distintos.
  String _teamIdWithGender(String baseName, TeamGender gender) {
    final String base = _teamIdFromName(baseName);
    switch (gender) {
      case TeamGender.men:
        return '$base-men';
      case TeamGender.women:
        return '$base-women';
      case TeamGender.mixed:
        return '$base-mixed';
      case TeamGender.unspecified:
        return base;
    }
  }

  /// Conjunto de tokens reconhecidos como "indicador de gênero" no fim do
  /// nome da equipe ou no valor da coluna `gender`. Inclui:
  /// - inglês: `m`/`f`/`w`, `man`/`men`/`woman`/`women` com plural (`mens`),
  ///   possessivo (`men's`), `male`/`female` com plural (`males`),
  ///   `masculine`/`feminine`;
  /// - português: `masculino`/`masculina`/`feminino`/`feminina`;
  /// - espanhol: `masculino`/`masculina`/`femenino`/`femenina`;
  /// - abreviações: `masc`/`fem`/`mas`.
  ///
  /// `mas` cobre o caso "MAS" maiúsculo (alguns usuários abreviam masculino
  /// como "Mas"). Não confundir com o código IOC da Malásia, que é tratado
  /// pelo `CountryResolverService` antes de chegar aqui — o strip só roda
  /// quando há outro token antes do indicador.
  static const String _genderKeywordPattern =
      "m|f|w|"
      "men|mens|men's|man|mans|man's|"
      "women|womens|women's|woman|womans|woman's|"
      "male|males|female|females|"
      "masculine|feminine|"
      "masculino|masculina|"
      "feminino|feminina|"
      "femenino|femenina|"
      "masc|fem|mas";

  /// Remove sufixos comuns de gênero do nome bruto da equipe
  /// (`"Brazil Women"` → `"Brazil"`, `"Brazil - Men"` → `"Brazil"`,
  /// `"Arg M"` → `"Arg"`). O separador entre país e gênero pode ser
  /// espaço, hífen ou ambos. O gênero real do time vem da coluna `gender`
  /// dos atletas — o strip aqui é apenas para limpar o `team_name`.
  String _stripGenderKeyword(String raw) {
    final String trimmed = raw.trim();
    if (trimmed.isEmpty) return trimmed;
    final RegExp pattern = RegExp(
      "(?:\\s+|\\s*-+\\s*)(?:$_genderKeywordPattern)\$",
      caseSensitive: false,
    );
    return trimmed.replaceAll(pattern, '').trim();
  }

  TeamGender _teamGenderFromPlayerGender(PlayerGender gender) {
    switch (gender) {
      case PlayerGender.male:
        return TeamGender.men;
      case PlayerGender.female:
        return TeamGender.women;
      case PlayerGender.unspecified:
        return TeamGender.unspecified;
    }
  }

  // ---------------------------------------------------------------------------
  // Parsers de campos
  // ---------------------------------------------------------------------------

  int? _parseShirtNumber(String? raw) {
    if (raw == null) return null;
    final String trimmed = raw.trim();
    if (trimmed.isEmpty) return null;
    final double? asDouble = double.tryParse(trimmed.replaceAll(',', '.'));
    if (asDouble == null) return null;
    if (asDouble < 0) return null;
    final int asInt = asDouble.toInt();
    if (asInt != asDouble) return null;
    return asInt;
  }

  DateTime? _parseDateOfBirth(String raw) {
    final String trimmed = raw.trim();
    if (trimmed.isEmpty) return null;

    // ISO 8601 (yyyy-mm-dd...) — só quando começa com ano de 4 dígitos.
    // Restringimos para que "12-12-25" NÃO seja lido como ano 12 pelo
    // DateTime.tryParse; esse formato cai no parser dd/mm abaixo.
    if (RegExp(r'^\d{4}-\d{1,2}-\d{1,2}').hasMatch(trimmed)) {
      final DateTime? iso = DateTime.tryParse(trimmed);
      if (iso != null) return DateTime.utc(iso.year, iso.month, iso.day);
    }

    // dd[sep]mm[sep](yy|yyyy), com separador `/`, `-` ou `.`.
    // Aceita ano de 2 dígitos (12-12-25) ou 4 dígitos (12-12-2025).
    final RegExp dmy =
        RegExp(r'^(\d{1,2})[/\-.](\d{1,2})[/\-.](\d{2}|\d{4})$');
    final RegExpMatch? m = dmy.firstMatch(trimmed);
    if (m != null) {
      final int day = int.parse(m.group(1)!);
      final int month = int.parse(m.group(2)!);
      final String yearRaw = m.group(3)!;
      int year = int.parse(yearRaw);
      if (yearRaw.length == 2) year = _expandTwoDigitYear(year);
      if (month < 1 || month > 12 || day < 1 || day > 31) return null;
      try {
        final DateTime parsed = DateTime.utc(year, month, day);
        // Rejeita datas que estouraram (ex.: 31/02 vira 03/03).
        if (parsed.year != year ||
            parsed.month != month ||
            parsed.day != day) {
          return null;
        }
        return parsed;
      } catch (_) {
        return null;
      }
    }
    return null;
  }

  /// Expande ano de 2 dígitos para 4 dígitos (pivô estilo POSIX strptime):
  /// `00`–`68` → `2000`–`2068`; `69`–`99` → `1969`–`1999`. Cobre tanto
  /// atletas veteranos (anos 70/80/90) quanto recentes.
  int _expandTwoDigitYear(int yy) => yy <= 68 ? 2000 + yy : 1900 + yy;

  /// Conjunto de valores aceitos na coluna `gender` (case-insensitive).
  /// Cobre EN/PT/ES + abreviações para evitar que pequenas variações de
  /// digitação caiam em `unspecified`.
  static const Set<String> _maleGenderTokens = <String>{
    'm', 'male', 'males', 'man', 'men', 'mans', 'mens',
    "man's", "men's",
    'masculine', 'masculino', 'masculina',
    'masc', 'mas',
  };

  static const Set<String> _femaleGenderTokens = <String>{
    'f', 'w', 'female', 'females', 'woman', 'women', 'womans', 'womens',
    "woman's", "women's",
    'feminine', 'feminino', 'feminina', 'femenino', 'femenina',
    'fem',
  };

  PlayerGender _genderFromString(String? raw) {
    if (raw == null) return PlayerGender.unspecified;
    final String value = raw.trim().toLowerCase();
    if (value.isEmpty) return PlayerGender.unspecified;
    if (_maleGenderTokens.contains(value)) return PlayerGender.male;
    if (_femaleGenderTokens.contains(value)) return PlayerGender.female;
    return PlayerGender.unspecified;
  }

  String? _readCell(List<String?> row, int? index) {
    if (index == null) return null;
    if (index < 0 || index >= row.length) return null;
    return row[index];
  }

  String? _readOptionalString(List<String?> row, int? index) {
    final String? raw = _readCell(row, index);
    if (raw == null) return null;
    final String trimmed = raw.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  /// Aliases aceitos para cada coluna *lógica*. O importante é a
  /// informação que a coluna carrega, não o título exato — então cada
  /// coluna lógica reconhece várias grafias equivalentes (PT/EN/ES +
  /// variações comuns de exportação). O cabeçalho canônico é o primeiro
  /// de cada lista; os demais mantêm compatibilidade e cobrem planilhas
  /// de terceiros.
  ///
  /// Os tokens já vêm **normalizados** (minúsculas, espaços/hífens →
  /// `_`), no mesmo formato que `_normalizeHeaderToken` produz. Assim
  /// `"FULL NAME"`, `"Full-Name"` e `"full_name"` batem todos em `name`.
  ///
  /// Colunas não listadas aqui (ex.: `role`, `cs`/`class_status`,
  /// `first_name`/`last_name` quando já há `name`) são simplesmente
  /// ignoradas — nunca viram erro.
  static const Map<String, List<String>> _columnAliases =
      <String, List<String>>{
    'competition': <String>[
      'competition', 'competition_name', 'tournament', 'tournament_name',
      'event', 'event_name', 'championship', 'cup', 'competicao', 'torneio',
    ],
    'team_name': <String>[
      'team_name', 'team', 'country', 'country_name', 'nation', 'nationality',
      'national_team', 'pais', 'selecao', 'equipe', 'equipo',
    ],
    'class': <String>[
      'class', 'player_class', 'sport_class', 'sports_class',
      'classification', 'sport_classification', 'functional_class',
      'classe', 'classificacao',
    ],
    'name': <String>[
      'name', 'full_name', 'fullname', 'player_name', 'player', 'athlete',
      'athlete_name', 'nome', 'nome_completo', 'jogador', 'atleta',
    ],
    'number': <String>[
      'number', 'shirt_number', 'shirt', 'shirt_no', 'jersey',
      'jersey_number', 'jersey_no', 'bib', 'bib_number', 'no', 'num',
      'numero', 'numero_camisa',
    ],
    'dob': <String>[
      'dob', 'date_of_birth', 'birth_date', 'birthdate', 'birthday', 'born',
      'data_nascimento', 'data_de_nascimento', 'nascimento',
    ],
    'gender': <String>[
      'gender', 'sex', 'genero', 'sexo',
    ],
    // Pares legados de nome separado, usados só como fallback quando NÃO
    // existe uma coluna de nome completo. Reconhecem variações comuns
    // ("LAST NAME", "Given Name" etc.).
    'surname': <String>[
      'surname', 'last_name', 'lastname', 'family_name', 'familyname',
      'sobrenome', 'apellido',
    ],
    'first_name': <String>[
      'first_name', 'firstname', 'given_name', 'givenname', 'forename',
      'first', 'nome_proprio', 'primeiro_nome', 'nombre',
    ],
  };

  /// Índice da coluna lógica [logical], tentando cada alias na ordem.
  int? _columnIndex(_HeaderInfo header, String logical) {
    final List<String> aliases =
        _columnAliases[logical] ?? <String>[logical];
    for (final String alias in aliases) {
      final int? idx = header.columnIndex[alias];
      if (idx != null) return idx;
    }
    return null;
  }

  /// Se a planilha tem a coluna lógica [logical]. Para `name`, aceita o
  /// par legado `surname` + `first_name` (cada um resolvido por aliases,
  /// ex.: `last_name` + `first_name`).
  bool _hasLogicalColumn(_HeaderInfo header, String logical) {
    if (logical == 'name') {
      if (_columnIndex(header, 'name') != null) return true;
      return _columnIndex(header, 'surname') != null &&
          _columnIndex(header, 'first_name') != null;
    }
    return _columnIndex(header, logical) != null;
  }

  /// Lê o valor (trim/non-empty) da coluna lógica [logical].
  String? _readLogical(List<String?> row, _HeaderInfo header, String logical) {
    return _readOptionalString(row, _columnIndex(header, logical));
  }

  /// Junta sobrenome + nome no formato "SOBRENOME, Nome" (igual aos
  /// templates). Quando só um dos dois existe, devolve-o como está.
  String _composeName(String surname, String firstName) {
    if (surname.isEmpty) return firstName;
    if (firstName.isEmpty) return surname;
    return '${surname.toUpperCase()}, $firstName';
  }

  bool _rowHasContent(List<String?> row) {
    for (final String? cell in row) {
      if (cell != null && cell.trim().isNotEmpty) return true;
    }
    return false;
  }

  _HeaderInfo? _readHeader(SheetData sheet) {
    for (int i = 0; i < sheet.rows.length; i++) {
      final List<String?> row = sheet.rows[i];
      if (!_rowHasContent(row)) continue;
      final Map<String, int> map = <String, int>{};
      for (int c = 0; c < row.length; c++) {
        final String? raw = row[c];
        if (raw == null) continue;
        final String normalized = _normalizeHeaderToken(raw);
        if (normalized.isEmpty) continue;
        map.putIfAbsent(normalized, () => c);
      }
      if (map.isEmpty) continue;
      return _HeaderInfo(columnIndex: map, firstDataRow: i + 1);
    }
    return null;
  }

  String _normalizeHeaderToken(String raw) {
    final String lower = raw.trim().toLowerCase();
    final StringBuffer buffer = StringBuffer();
    for (int i = 0; i < lower.length; i++) {
      final String c = lower[i];
      final int code = c.codeUnitAt(0);
      final bool isLower = code >= 0x61 && code <= 0x7A;
      final bool isDigit = code >= 0x30 && code <= 0x39;
      if (isLower || isDigit) {
        buffer.write(c);
      } else if (c == ' ' || c == '-' || c == '_') {
        if (buffer.isNotEmpty &&
            buffer.toString()[buffer.length - 1] != '_') {
          buffer.write('_');
        }
      }
    }
    String result = buffer.toString();
    if (result.endsWith('_')) {
      result = result.substring(0, result.length - 1);
    }
    return result;
  }

  // ---------------------------------------------------------------------------
  // Bridge para package `excel`
  // ---------------------------------------------------------------------------

  List<SheetData>? _readBytes(Uint8List bytes) {
    xlsx.Excel decoded;
    try {
      decoded = xlsx.Excel.decodeBytes(bytes);
    } catch (_) {
      return null;
    }

    final List<SheetData> result = <SheetData>[];
    decoded.tables.forEach((String name, xlsx.Sheet sheet) {
      final List<List<String?>> rows = <List<String?>>[];
      for (final List<xlsx.Data?> rawRow in sheet.rows) {
        rows.add(rawRow.map(_cellToString).toList(growable: false));
      }
      result.add(SheetData(name: name, rows: rows));
    });
    return result;
  }

  String? _cellToString(xlsx.Data? cell) {
    if (cell == null) return null;
    final dynamic value = cell.value;
    if (value == null) return null;

    if (value is xlsx.DateCellValue) {
      return _formatYmd(value.year, value.month, value.day);
    }
    if (value is xlsx.DateTimeCellValue) {
      return _formatYmd(value.year, value.month, value.day);
    }

    // Para Text/Int/Double/Bool tentamos extrair `value.value` (campo
    // padrao das subclasses de CellValue) e produzir uma string limpa.
    try {
      final dynamic inner = (value as dynamic).value;
      if (inner == null) return null;
      if (inner is String) return inner;
      if (inner is num || inner is bool) return inner.toString();
      if (inner is DateTime) {
        return _formatYmd(inner.year, inner.month, inner.day);
      }
      // Algumas versoes da lib excel embrulham o texto em TextSpan
      // (flutter/painting). Pegamos `.text` se existir.
      try {
        final dynamic maybeText = (inner as dynamic).text;
        if (maybeText is String) return maybeText;
      } catch (_) {
        // ignore
      }
      return inner.toString();
    } catch (_) {
      return value.toString();
    }
  }

  String _formatYmd(int year, int month, int day) =>
      '${year.toString().padLeft(4, '0')}-'
      '${month.toString().padLeft(2, '0')}-'
      '${day.toString().padLeft(2, '0')}';
}

class _HeaderInfo {
  const _HeaderInfo({required this.columnIndex, required this.firstDataRow});
  final Map<String, int> columnIndex;
  final int firstDataRow;
}

/// Acumulador interno enquanto agrupamos atletas por (equipe canonica,
/// gênero). Convertido em `Team` ao final da iteração.
class _TeamBucket {
  _TeamBucket({
    required this.id,
    required this.displayName,
    required this.gender,
  });

  final String id;
  final String displayName;
  final TeamGender gender;
  final List<Player> players = <Player>[];
}
