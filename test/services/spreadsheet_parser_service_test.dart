import 'dart:typed_data';

import 'package:excel/excel.dart' as xlsx;
import 'package:flutter_test/flutter_test.dart';
import 'package:iwbf_team_points_control/services/spreadsheet_parser_service.dart';

SheetData _sheet(String name, List<List<String?>> rows) =>
    SheetData(name: name, rows: rows);

List<String?> _row(List<String?> cells) => List<String?>.from(cells);

void main() {
  group('SpreadsheetParserService - modelo aba unica', () {
    final SpreadsheetParserService parser = SpreadsheetParserService();

    test('parseia planilha valida com uma aba "Players"', () {
      final SheetData sheet = _sheet('Players', <List<String?>>[
        _row(<String?>[
          'competition_name',
          'team_name',
          'shirt_number',
          'surname',
          'first_name',
          'player_class',
          'dob',
        ]),
        _row(<String?>[
          'Americas Championship',
          'Brazil',
          '7',
          'Silva',
          'João',
          '2.5',
          '1998-01-02',
        ]),
        _row(<String?>[
          'Americas Championship',
          'Brazil',
          '9',
          'Souza',
          'Pedro',
          '4.0',
          '1995-12-31',
        ]),
        _row(<String?>[
          'Americas Championship',
          'Argentina',
          '4',
          'Lopez',
          'Carlos',
          '1.5',
          '01/03/1992',
        ]),
      ]);

      final SpreadsheetParseResult result =
          parser.parseSheets(<SheetData>[sheet]);

      expect(result.hasBlockingIssues, isFalse,
          reason: result.issues.toString());
      expect(result.teams, hasLength(2));
      expect(result.competitionName, equals('Americas Championship'));
      expect(result.playerCount, equals(3));

      final teamBrazil =
          result.teams.firstWhere((t) => t.teamName == 'Brazil');
      expect(teamBrazil.players, hasLength(2));
      expect(teamBrazil.players.first.surname, equals('Silva'));
      expect(teamBrazil.players.first.shirtNumber, equals(7));
      expect(teamBrazil.players.first.playerClass, equals(2.5));
      expect(
        teamBrazil.players.first.dateOfBirth,
        equals(DateTime.utc(1998, 1, 2)),
      );

      final teamArg =
          result.teams.firstWhere((t) => t.teamName == 'Argentina');
      expect(teamArg.players, hasLength(1));
      expect(
        teamArg.players.first.dateOfBirth,
        equals(DateTime.utc(1992, 3, 1)),
      );
    });

    test('aceita classe funcional com vírgula', () {
      final SheetData sheet = _sheet('Players', <List<String?>>[
        _row(<String?>['team_name', 'shirt_number', 'surname', 'first_name', 'player_class', 'dob']),
        _row(<String?>['Brazil', '7', 'Silva', 'João', '2,5', '1998-01-02']),
      ]);

      final SpreadsheetParseResult result =
          parser.parseSheets(<SheetData>[sheet]);

      expect(result.hasBlockingIssues, isFalse);
      expect(result.teams.first.players.first.playerClass, equals(2.5));
    });

    test('reporta erro quando faltam colunas obrigatorias', () {
      final SheetData sheet = _sheet('Players', <List<String?>>[
        _row(<String?>['team_name', 'shirt_number', 'surname']),
        _row(<String?>['Brazil', '7', 'Silva']),
      ]);

      final SpreadsheetParseResult result =
          parser.parseSheets(<SheetData>[sheet]);

      expect(result.hasBlockingIssues, isTrue);
      final ParseIssue issue = result.issues.first;
      expect(issue.category,
          equals(ParseIssueCategory.missingRequiredColumn));
      expect(issue.message, contains('first_name'));
      expect(issue.message, contains('player_class'));
      expect(issue.message, contains('dob'));
    });

    test('reporta atleta sem numero como erro bloqueante', () {
      final SheetData sheet = _sheet('Players', <List<String?>>[
        _row(<String?>['team_name', 'shirt_number', 'surname', 'first_name', 'player_class', 'dob']),
        _row(<String?>['Brazil', '', 'Silva', 'João', '2.5', '1998-01-02']),
      ]);

      final SpreadsheetParseResult result =
          parser.parseSheets(<SheetData>[sheet]);

      expect(result.hasBlockingIssues, isTrue);
      expect(
        result.issues.first.category,
        equals(ParseIssueCategory.missingShirtNumber),
      );
      expect(result.issues.first.playerLabel, equals('SILVA, João'));
    });

    test('reporta classe funcional invalida', () {
      final SheetData sheet = _sheet('Players', <List<String?>>[
        _row(<String?>['team_name', 'shirt_number', 'surname', 'first_name', 'player_class', 'dob']),
        _row(<String?>['Brazil', '7', 'Silva', 'João', '2.3', '1998-01-02']),
      ]);

      final SpreadsheetParseResult result =
          parser.parseSheets(<SheetData>[sheet]);

      expect(result.hasBlockingIssues, isTrue);
      expect(
        result.issues.first.category,
        equals(ParseIssueCategory.invalidPlayerClass),
      );
    });

    test('reporta DOB ausente', () {
      final SheetData sheet = _sheet('Players', <List<String?>>[
        _row(<String?>['team_name', 'shirt_number', 'surname', 'first_name', 'player_class', 'dob']),
        _row(<String?>['Brazil', '7', 'Silva', 'João', '2.5', '']),
      ]);

      final SpreadsheetParseResult result =
          parser.parseSheets(<SheetData>[sheet]);

      expect(result.hasBlockingIssues, isTrue);
      expect(
        result.issues.first.category,
        equals(ParseIssueCategory.missingDateOfBirth),
      );
    });

    test('marca equipe nao reconhecida como warning, nao erro', () {
      final SheetData sheet = _sheet('Players', <List<String?>>[
        _row(<String?>['team_name', 'shirt_number', 'surname', 'first_name', 'player_class', 'dob']),
        _row(<String?>['Atlantis', '7', 'Silva', 'João', '2.5', '1998-01-02']),
      ]);

      final SpreadsheetParseResult result =
          parser.parseSheets(<SheetData>[sheet]);

      expect(result.hasBlockingIssues, isFalse);
      expect(
        result.issues.any((i) => i.category == ParseIssueCategory.unknownTeam),
        isTrue,
      );
      expect(result.teams.first.teamName, equals('Atlantis'));
    });

    test('reporta numeros de camiseta duplicados', () {
      final SheetData sheet = _sheet('Players', <List<String?>>[
        _row(<String?>['team_name', 'shirt_number', 'surname', 'first_name', 'player_class', 'dob']),
        _row(<String?>['Brazil', '7', 'Silva', 'João', '2.5', '1998-01-02']),
        _row(<String?>['Brazil', '7', 'Souza', 'Pedro', '4.0', '1995-12-31']),
      ]);

      final SpreadsheetParseResult result =
          parser.parseSheets(<SheetData>[sheet]);

      final dups = result.issues
          .where((i) => i.category == ParseIssueCategory.duplicateShirtNumber)
          .toList();
      expect(dups, hasLength(1));
      expect(dups.first.severity, equals(ParseIssueSeverity.warning));
    });
  });

  group('SpreadsheetParserService - modelo aba por equipe', () {
    final SpreadsheetParserService parser = SpreadsheetParserService();

    test('usa o nome da aba como nome da equipe', () {
      final SheetData brazilSheet = _sheet('Brazil', <List<String?>>[
        _row(<String?>['shirt_number', 'surname', 'first_name', 'player_class', 'dob']),
        _row(<String?>['7', 'Silva', 'João', '2.5', '1998-01-02']),
      ]);
      final SheetData argSheet = _sheet('Argentina', <List<String?>>[
        _row(<String?>['shirt_number', 'surname', 'first_name', 'player_class', 'dob']),
        _row(<String?>['4', 'Lopez', 'Carlos', '1.5', '1992-03-01']),
      ]);

      final SpreadsheetParseResult result =
          parser.parseSheets(<SheetData>[brazilSheet, argSheet]);

      expect(result.hasBlockingIssues, isFalse,
          reason: result.issues.toString());
      expect(result.teams.map((t) => t.teamName).toSet(),
          equals(<String>{'Brazil', 'Argentina'}));
    });

    test('usa team_name da planilha quando presente', () {
      final SheetData sheet = _sheet('Aba1', <List<String?>>[
        _row(<String?>['team_name', 'shirt_number', 'surname', 'first_name', 'player_class', 'dob']),
        _row(<String?>['Brazil', '7', 'Silva', 'João', '2.5', '1998-01-02']),
      ]);

      final SpreadsheetParseResult result =
          parser.parseSheets(<SheetData>[sheet]);

      expect(result.hasBlockingIssues, isFalse);
      expect(result.teams, hasLength(1));
      expect(result.teams.first.teamName, equals('Brazil'));
    });

    test('reporta colunas obrigatorias ausentes por aba', () {
      final SheetData ok = _sheet('Brazil', <List<String?>>[
        _row(<String?>['shirt_number', 'surname', 'first_name', 'player_class', 'dob']),
        _row(<String?>['7', 'Silva', 'João', '2.5', '1998-01-02']),
      ]);
      final SheetData bad = _sheet('Argentina', <List<String?>>[
        _row(<String?>['shirt_number', 'surname']),
        _row(<String?>['4', 'Lopez']),
      ]);

      final SpreadsheetParseResult result =
          parser.parseSheets(<SheetData>[ok, bad]);

      expect(result.hasBlockingIssues, isTrue);
      final missing = result.issues
          .firstWhere((i) => i.category == ParseIssueCategory.missingRequiredColumn);
      expect(missing.sheetName, equals('Argentina'));
    });
  });

  group('SpreadsheetParserService - geral', () {
    final SpreadsheetParserService parser = SpreadsheetParserService();

    test('parseia mesmo com headers em caixa alta e snake-case', () {
      final SheetData sheet = _sheet('Players', <List<String?>>[
        _row(<String?>['TEAM NAME', 'Shirt-Number', 'Surname', 'First Name', 'Player Class', 'DOB']),
        _row(<String?>['Brazil', '7', 'Silva', 'João', '2.5', '1998-01-02']),
      ]);

      final SpreadsheetParseResult result =
          parser.parseSheets(<SheetData>[sheet]);

      expect(result.hasBlockingIssues, isFalse,
          reason: result.issues.toString());
      expect(result.teams.first.teamName, equals('Brazil'));
    });

    test('planilha vazia retorna erro', () {
      final SpreadsheetParseResult result = parser.parseSheets(
        <SheetData>[_sheet('Players', <List<String?>>[])],
      );
      expect(result.hasBlockingIssues, isTrue);
      expect(result.issues.first.category, equals(ParseIssueCategory.emptyFile));
    });

    test('linhas em branco no meio sao ignoradas', () {
      final SheetData sheet = _sheet('Players', <List<String?>>[
        _row(<String?>['team_name', 'shirt_number', 'surname', 'first_name', 'player_class', 'dob']),
        _row(<String?>['Brazil', '7', 'Silva', 'João', '2.5', '1998-01-02']),
        _row(<String?>['', '', '', '', '', '']),
        _row(<String?>['Brazil', '9', 'Souza', 'Pedro', '4.0', '1995-12-31']),
      ]);

      final SpreadsheetParseResult result =
          parser.parseSheets(<SheetData>[sheet]);

      expect(result.hasBlockingIssues, isFalse);
      expect(result.teams.first.players, hasLength(2));
    });

    test('aceita DOB no formato DD/MM/YYYY', () {
      final SheetData sheet = _sheet('Players', <List<String?>>[
        _row(<String?>['team_name', 'shirt_number', 'surname', 'first_name', 'player_class', 'dob']),
        _row(<String?>['Brazil', '7', 'Silva', 'João', '2.5', '02/01/1998']),
      ]);
      final SpreadsheetParseResult result =
          parser.parseSheets(<SheetData>[sheet]);
      expect(result.teams.first.players.first.dateOfBirth,
          equals(DateTime.utc(1998, 1, 2)));
    });

    test('parseBytes retorna erro para bytes invalidos', () {
      final Uint8List garbage = Uint8List.fromList(<int>[1, 2, 3, 4]);
      final SpreadsheetParseResult result = parser.parseBytes(garbage);
      expect(result.hasBlockingIssues, isTrue);
      expect(result.issues.first.category,
          equals(ParseIssueCategory.fileUnreadable));
    });
  });

  group('SpreadsheetParserService - integracao com package excel', () {
    test('roundtrip: escreve com excel e le com parseBytes', () {
      final xlsx.Excel excel = xlsx.Excel.createExcel();
      // Excel.createExcel cria uma aba "Sheet1"; renomeamos para "Players".
      excel.rename('Sheet1', 'Players');
      final xlsx.Sheet sheet = excel['Players'];
      sheet.appendRow(<xlsx.CellValue?>[
        xlsx.TextCellValue('team_name'),
        xlsx.TextCellValue('shirt_number'),
        xlsx.TextCellValue('surname'),
        xlsx.TextCellValue('first_name'),
        xlsx.TextCellValue('player_class'),
        xlsx.TextCellValue('dob'),
      ]);
      sheet.appendRow(<xlsx.CellValue?>[
        xlsx.TextCellValue('Brazil'),
        const xlsx.IntCellValue(7),
        xlsx.TextCellValue('Silva'),
        xlsx.TextCellValue('Joao'),
        xlsx.TextCellValue('2.5'),
        xlsx.TextCellValue('1998-01-02'),
      ]);

      final List<int>? bytes = excel.encode();
      expect(bytes, isNotNull);

      final SpreadsheetParserService parser = SpreadsheetParserService();
      final SpreadsheetParseResult result =
          parser.parseBytes(Uint8List.fromList(bytes!));

      expect(result.hasBlockingIssues, isFalse,
          reason: result.issues.toString());
      expect(result.teams, hasLength(1));
      expect(result.teams.first.teamName, equals('Brazil'));
      expect(result.teams.first.players, hasLength(1));
      expect(result.teams.first.players.first.shirtNumber, equals(7));
      expect(result.teams.first.players.first.playerClass, equals(2.5));
    });
  });
}
