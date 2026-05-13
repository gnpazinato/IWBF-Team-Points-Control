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
        'Não foi possível ler o arquivo .xlsx',
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
        'Planilha sem dados',
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
        'Aba "${sheet.name}" sem cabeçalho válido',
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
        message: 'Colunas obrigatórias ausentes: ${missing.join(", ")}',
        sheetName: sheet.name,
      ));
      return SpreadsheetParseResult(
        teams: const <Team>[],
        issues: issues,
      );
    }

    final Map<String, List<Player>> playersByTeamId = <String, List<Player>>{};
    final Map<String, String> teamIdToName = <String, String>{};
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
          message: 'Linha sem team_name',
          sheetName: sheet.name,
          rowNumber: i + 1,
        ));
        continue;
      }

      competitionName ??=
          _readOptionalString(row, header.columnIndex['competition_name']);

      final String teamDisplay = resolver.displayNameFor(rawTeam);
      final String teamId = _teamIdFromName(teamDisplay);
      teamIdToName[teamId] = teamDisplay;
      if (!resolver.isKnown(rawTeam)) {
        if (!issues.any((ParseIssue x) =>
            x.category == ParseIssueCategory.unknownTeam &&
            x.teamName == teamDisplay)) {
          issues.add(ParseIssue(
            category: ParseIssueCategory.unknownTeam,
            severity: ParseIssueSeverity.warning,
            message: 'Equipe não reconhecida: "$rawTeam"',
            sheetName: sheet.name,
            teamName: teamDisplay,
          ));
        }
      }

      final Player? player = _buildPlayer(
        row: row,
        header: header,
        sheetName: sheet.name,
        rowNumber: i + 1,
        teamId: teamId,
        teamName: teamDisplay,
        issues: issues,
      );
      if (player != null) {
        playersByTeamId.putIfAbsent(teamId, () => <Player>[]).add(player);
      }
    }

    final List<Team> teams = <Team>[];
    teamIdToName.forEach((String teamId, String teamName) {
      teams.add(Team(
        id: teamId,
        teamName: teamName,
        players: playersByTeamId[teamId] ?? const <Player>[],
      ));
    });

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
          message: 'Aba "${sheet.name}" sem cabeçalho válido',
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
          message: 'Colunas obrigatórias ausentes: ${missing.join(", ")}',
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

      final String teamDisplay = resolver.displayNameFor(teamName);
      final String teamId = _teamIdFromName(teamDisplay);
      if (!resolver.isKnown(teamName)) {
        issues.add(ParseIssue(
          category: ParseIssueCategory.unknownTeam,
          severity: ParseIssueSeverity.warning,
          message: 'Equipe não reconhecida: "$teamName"',
          sheetName: sheet.name,
          teamName: teamDisplay,
        ));
      }

      final List<Player> teamPlayers = <Player>[];
      for (int i = header.firstDataRow; i < sheet.rows.length; i++) {
        final List<String?> row = sheet.rows[i];
        if (!_rowHasContent(row)) continue;

        competitionName ??=
            _readOptionalString(row, header.columnIndex['competition_name']);

        final Player? player = _buildPlayer(
          row: row,
          header: header,
          sheetName: sheet.name,
          rowNumber: i + 1,
          teamId: teamId,
          teamName: teamDisplay,
          issues: issues,
        );
        if (player != null) teamPlayers.add(player);
      }

      teams.add(Team(
        id: teamId,
        teamName: teamDisplay,
        players: teamPlayers,
      ));
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
        message: 'Atleta sem nome completo',
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
        message: 'Atleta sem número de camiseta',
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
        message: 'Atleta sem classe funcional',
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
              'Classe funcional inválida para $playerLabel (valores aceitos: ${kAcceptedPlayerClasses.join(", ")})',
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
        message: 'Data de nascimento ausente ou inválida',
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
                'Número de camiseta #$number aparece $n vezes na equipe ${team.teamName}',
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

  PlayerGender _genderFromString(String? raw) {
    if (raw == null) return PlayerGender.unspecified;
    final String value = raw.trim().toLowerCase();
    if (value == 'm' || value == 'male' || value == 'masculino') {
      return PlayerGender.male;
    }
    if (value == 'f' || value == 'female' || value == 'feminino') {
      return PlayerGender.female;
    }
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
