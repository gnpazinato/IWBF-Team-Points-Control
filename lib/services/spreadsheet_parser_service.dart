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
class _RequiredColumns {
  static const List<String> singleSheet = <String>[
    'team_name',
    'shirt_number',
    'surname',
    'first_name',
    'player_class',
    'dob',
  ];
  static const List<String> perTeamSheet = <String>[
    'shirt_number',
    'surname',
    'first_name',
    'player_class',
    'dob',
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

    SheetData? playersSheet;
    for (final SheetData s in nonEmpty) {
      if (s.name.trim().toLowerCase() == 'players') {
        playersSheet = s;
        break;
      }
    }

    if (playersSheet != null) {
      return _parseSingleSheet(playersSheet);
    }
    return _parseMultiSheet(nonEmpty);
  }

  // ---------------------------------------------------------------------------
  // Modelo aba única
  // ---------------------------------------------------------------------------

  SpreadsheetParseResult _parseSingleSheet(SheetData sheet) {
    final _HeaderInfo? header = _readHeader(sheet);
    if (header == null) {
      return SpreadsheetParseResult.error(
        'Sheet "${sheet.name}" has no valid header row',
        ParseIssueCategory.missingRequiredColumn,
      );
    }

    final List<ParseIssue> issues = <ParseIssue>[];
    final List<String> missing = <String>[];
    for (final String required in _RequiredColumns.singleSheet) {
      if (!header.columnIndex.containsKey(required)) {
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
      return SpreadsheetParseResult(
        teams: const <Team>[],
        issues: issues,
      );
    }

    final Map<String, _TeamBucket> buckets = <String, _TeamBucket>{};
    String? competitionName;

    for (int i = header.firstDataRow; i < sheet.rows.length; i++) {
      final List<String?> row = sheet.rows[i];
      if (!_rowHasContent(row)) continue;

      final String rawTeam =
          (_readCell(row, header.columnIndex['team_name']) ?? '').trim();
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

      competitionName ??=
          _readOptionalString(row, header.columnIndex['competition_name']);

      // Quem decide o gênero do time é o gênero do atleta, não o nome
      // bruto. O "Brasil Men" do `team_name` é só uma dica — strippamos
      // pra usar o "Brasil" canônico.
      final String strippedTeam = _stripGenderKeyword(rawTeam);
      final String baseDisplay = resolver.displayNameFor(strippedTeam);
      final PlayerGender playerGender = _genderFromString(
          _readOptionalString(row, header.columnIndex['gender']));
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

    final List<Team> teams = buckets.values
        .map((_TeamBucket b) => Team(
              id: b.id,
              teamName: b.displayName,
              gender: b.gender,
              players: b.players,
            ))
        .toList();

    _detectDuplicateShirtNumbers(teams, issues, sheet.name);

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
        if (!header.columnIndex.containsKey(required)) {
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
      if (header.columnIndex.containsKey('team_name') &&
          header.firstDataRow < sheet.rows.length) {
        rawTeamFromColumn = _readOptionalString(
          sheet.rows[header.firstDataRow],
          header.columnIndex['team_name'],
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

        competitionName ??=
            _readOptionalString(row, header.columnIndex['competition_name']);

        final PlayerGender playerGender = _genderFromString(
            _readOptionalString(row, header.columnIndex['gender']));
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
    final String? shirtRaw =
        _readOptionalString(row, header.columnIndex['shirt_number']);
    final String surname =
        (_readOptionalString(row, header.columnIndex['surname']) ?? '').trim();
    final String firstName =
        (_readOptionalString(row, header.columnIndex['first_name']) ?? '').trim();
    final String classRaw =
        (_readOptionalString(row, header.columnIndex['player_class']) ?? '').trim();
    final String dobRaw =
        (_readOptionalString(row, header.columnIndex['dob']) ?? '').trim();
    final String? genderRaw =
        _readOptionalString(row, header.columnIndex['gender']);

    final String playerLabel = '${surname.toUpperCase()}, $firstName';

    bool valid = true;

    if (surname.isEmpty || firstName.isEmpty) {
      issues.add(ParseIssue(
        category: ParseIssueCategory.missingPlayerName,
        severity: ParseIssueSeverity.error,
        message: 'Player is missing full name (surname and first name)',
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
      playerClass = parsePlayerClass(classRaw);
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

    final DateTime? dob = _parseDateOfBirth(dobRaw);
    if (dob == null) {
      issues.add(ParseIssue(
        category: ParseIssueCategory.missingDateOfBirth,
        severity: ParseIssueSeverity.error,
        message: 'Date of birth is missing or invalid',
        sheetName: sheetName,
        rowNumber: rowNumber,
        teamName: teamName,
        playerLabel: playerLabel,
      ));
      valid = false;
    }

    if (!valid) return null;

    return Player(
      id: '$teamId::${shirtNumber!}',
      teamName: teamName,
      shirtNumber: shirtNumber,
      surname: surname,
      firstName: firstName,
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
    if (raw.isEmpty) return null;
    final DateTime? iso = DateTime.tryParse(raw);
    if (iso != null) return DateTime.utc(iso.year, iso.month, iso.day);
    final RegExp dmy = RegExp(r'^(\d{1,2})/(\d{1,2})/(\d{4})$');
    final RegExpMatch? m = dmy.firstMatch(raw);
    if (m != null) {
      final int day = int.parse(m.group(1)!);
      final int month = int.parse(m.group(2)!);
      final int year = int.parse(m.group(3)!);
      if (month < 1 || month > 12 || day < 1 || day > 31) return null;
      try {
        return DateTime.utc(year, month, day);
      } catch (_) {
        return null;
      }
    }
    return null;
  }

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
