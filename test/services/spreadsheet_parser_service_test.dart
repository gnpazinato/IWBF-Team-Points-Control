import 'dart:typed_data';

import 'package:excel/excel.dart' as xlsx;
import 'package:flutter_test/flutter_test.dart';
import 'package:iwbf_team_points_control/models/team.dart';
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
      expect(teamBrazil.players.first.name, equals('João Silva'));
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
      // Faltam name (só há surname, sem first_name) e class. dob é opcional.
      expect(issue.message, contains('name'));
      expect(issue.message, contains('class'));
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
      expect(result.issues.first.playerLabel, equals('João Silva'));
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

    test('DOB ausente NAO bloqueia (campo opcional)', () {
      final SheetData sheet = _sheet('Players', <List<String?>>[
        _row(<String?>['team_name', 'shirt_number', 'surname', 'first_name', 'player_class', 'dob']),
        _row(<String?>['Brazil', '7', 'Silva', 'João', '2.5', '']),
      ]);

      final SpreadsheetParseResult result =
          parser.parseSheets(<SheetData>[sheet]);

      expect(result.hasBlockingIssues, isFalse,
          reason: result.issues.toString());
      expect(result.teams.first.players, hasLength(1));
      expect(result.teams.first.players.first.dateOfBirth, isNull);
    });

    test('classe autoformatada como data e recuperada (2026-05-02 -> 2.5)', () {
      final SheetData sheet = _sheet('Players', <List<String?>>[
        _row(<String?>['team_name', 'shirt_number', 'surname', 'first_name', 'player_class', 'dob']),
        _row(<String?>['Brazil', '7', 'Silva', 'João', '2026-05-02', '1998-01-02']),
      ]);

      final SpreadsheetParseResult result =
          parser.parseSheets(<SheetData>[sheet]);

      expect(result.hasBlockingIssues, isFalse,
          reason: result.issues.toString());
      expect(result.teams.first.players.first.playerClass, equals(2.5));
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

  group('SpreadsheetParserService - genero', () {
    final SpreadsheetParserService parser = SpreadsheetParserService();

    test('separa por gênero atletas que estavam num único team_name', () {
      // Brasil com 1 atleta masculino e 1 feminino vira 2 equipes
      // distintas: Brazil Men e Brazil Women.
      final SheetData sheet = _sheet('Players', <List<String?>>[
        _row(<String?>[
          'team_name', 'shirt_number', 'surname', 'first_name',
          'player_class', 'dob', 'gender',
        ]),
        _row(<String?>['Brazil', '7', 'Silva', 'João', '2.5', '1998-01-02', 'male']),
        _row(<String?>['Brazil', '8', 'Souza', 'Maria', '3.0', '1996-05-10', 'female']),
      ]);

      final SpreadsheetParseResult result =
          parser.parseSheets(<SheetData>[sheet]);

      expect(result.hasBlockingIssues, isFalse,
          reason: result.issues.toString());
      expect(result.teams, hasLength(2));
      final teamMen = result.teams.firstWhere(
          (Team t) => t.gender == TeamGender.men);
      final teamWomen = result.teams.firstWhere(
          (Team t) => t.gender == TeamGender.women);
      expect(teamMen.teamName, equals('Brazil'));
      expect(teamMen.displayName, equals('Brazil - Men'));
      expect(teamMen.players, hasLength(1));
      expect(teamWomen.displayName, equals('Brazil - Women'));
      expect(teamWomen.players, hasLength(1));
    });

    test('strip do "Men"/"Women" no team_name não duplica o sufixo', () {
      // Usuário escreveu "Brazil Women" no team_name mas a coluna gender
      // confirma female. O parser deve canonicalizar para "Brazil" e
      // adicionar "- Women" apenas via displayName.
      final SheetData sheet = _sheet('Players', <List<String?>>[
        _row(<String?>[
          'team_name', 'shirt_number', 'surname', 'first_name',
          'player_class', 'dob', 'gender',
        ]),
        _row(<String?>['Brazil Women', '7', 'Silva', 'Maria', '2.5', '1998-01-02', 'female']),
      ]);

      final SpreadsheetParseResult result =
          parser.parseSheets(<SheetData>[sheet]);

      expect(result.hasBlockingIssues, isFalse);
      expect(result.teams, hasLength(1));
      expect(result.teams.first.teamName, equals('Brazil'));
      expect(result.teams.first.displayName, equals('Brazil - Women'));
      expect(result.teams.first.gender, equals(TeamGender.women));
    });

    test('strip aceita formato "Brazil - Women" com hífen', () {
      // Confere que o regex tambem cobre o novo separador. Importante
      // porque o displayName agora ja sai com " - " e o usuario pode
      // copiar de volta para o team_name.
      final SheetData sheet = _sheet('Players', <List<String?>>[
        _row(<String?>[
          'team_name', 'shirt_number', 'surname', 'first_name',
          'player_class', 'dob', 'gender',
        ]),
        _row(<String?>[
          'Brazil - Women', '7', 'Silva', 'Maria', '2.5', '1998-01-02', 'female',
        ]),
      ]);

      final SpreadsheetParseResult result =
          parser.parseSheets(<SheetData>[sheet]);

      expect(result.hasBlockingIssues, isFalse);
      expect(result.teams, hasLength(1));
      expect(result.teams.first.teamName, equals('Brazil'));
      expect(result.teams.first.displayName, equals('Brazil - Women'));
    });

    test('sem coluna gender → equipe fica unspecified (compat)', () {
      final SheetData sheet = _sheet('Players', <List<String?>>[
        _row(<String?>[
          'team_name', 'shirt_number', 'surname', 'first_name',
          'player_class', 'dob',
        ]),
        _row(<String?>['Brazil', '7', 'Silva', 'João', '2.5', '1998-01-02']),
      ]);

      final SpreadsheetParseResult result =
          parser.parseSheets(<SheetData>[sheet]);

      expect(result.hasBlockingIssues, isFalse);
      expect(result.teams, hasLength(1));
      expect(result.teams.first.gender, equals(TeamGender.unspecified));
      expect(result.teams.first.displayName, equals('Brazil'));
    });
  });

  group('SpreadsheetParserService - variantes de genero (entrada 0030)', () {
    final SpreadsheetParserService parser = SpreadsheetParserService();

    /// Helper que monta uma planilha single-sheet com um time + um atleta,
    /// usando os valores fornecidos para `team_name` e `gender`. Verifica
    /// que o nome canonico do time vira "Argentina" e o gênero vira o
    /// esperado.
    void _expectArgentinaTeam({
      required String rawTeamName,
      required String rawGender,
      required TeamGender expectedGender,
      required String expectedDisplayName,
    }) {
      final SheetData sheet = _sheet('Players', <List<String?>>[
        _row(<String?>[
          'team_name', 'shirt_number', 'surname', 'first_name',
          'player_class', 'dob', 'gender',
        ]),
        _row(<String?>[
          rawTeamName, '7', 'Lopez', 'Diego', '2.5', '1998-01-02', rawGender,
        ]),
      ]);

      final SpreadsheetParseResult result =
          parser.parseSheets(<SheetData>[sheet]);

      expect(result.hasBlockingIssues, isFalse,
          reason: 'team_name="$rawTeamName" gender="$rawGender": '
              '${result.issues}');
      expect(result.teams, hasLength(1),
          reason: 'team_name="$rawTeamName" gender="$rawGender"');
      expect(result.teams.first.teamName, equals('Argentina'),
          reason: 'team_name="$rawTeamName"');
      expect(result.teams.first.gender, equals(expectedGender),
          reason: 'gender="$rawGender"');
      expect(result.teams.first.displayName, equals(expectedDisplayName),
          reason: 'team_name="$rawTeamName" gender="$rawGender"');
    }

    test('strip aceita M, Men, Mens, Mans, Man, Male, Masc, Masculino', () {
      const List<String> maleSuffixes = <String>[
        'Argentina M',
        'Argentina Men',
        'Argentina Mens',
        "Argentina Men's",
        'Argentina Man',
        'Argentina Mans',
        'Argentina Male',
        'Argentina Males',
        'Argentina Masculine',
        'Argentina Masculino',
        'Argentina Masculina',
        'Argentina Masc',
        'Argentina MAS',
      ];
      for (final String teamName in maleSuffixes) {
        _expectArgentinaTeam(
          rawTeamName: teamName,
          rawGender: 'male',
          expectedGender: TeamGender.men,
          expectedDisplayName: 'Argentina - Men',
        );
      }
    });

    test('strip aceita F, W, Women, Woman, Femenino, Feminino, Fem', () {
      const List<String> femaleSuffixes = <String>[
        'Argentina F',
        'Argentina W',
        'Argentina Women',
        'Argentina Womens',
        "Argentina Women's",
        'Argentina Woman',
        'Argentina Womans',
        'Argentina Female',
        'Argentina Females',
        'Argentina Feminine',
        'Argentina Feminino',
        'Argentina Feminina',
        'Argentina Femenino',
        'Argentina Femenina',
        'Argentina Fem',
      ];
      for (final String teamName in femaleSuffixes) {
        _expectArgentinaTeam(
          rawTeamName: teamName,
          rawGender: 'female',
          expectedGender: TeamGender.women,
          expectedDisplayName: 'Argentina - Women',
        );
      }
    });

    test('strip + alias 3 letras: "Arg Man", "ARG Mens", "ARG F"', () {
      _expectArgentinaTeam(
        rawTeamName: 'Arg Man',
        rawGender: 'male',
        expectedGender: TeamGender.men,
        expectedDisplayName: 'Argentina - Men',
      );
      _expectArgentinaTeam(
        rawTeamName: 'ARG Mens',
        rawGender: 'male',
        expectedGender: TeamGender.men,
        expectedDisplayName: 'Argentina - Men',
      );
      _expectArgentinaTeam(
        rawTeamName: 'ARG F',
        rawGender: 'female',
        expectedGender: TeamGender.women,
        expectedDisplayName: 'Argentina - Women',
      );
    });

    test('separador hifen funciona com qualquer variante: "Arg - M"', () {
      _expectArgentinaTeam(
        rawTeamName: 'Arg - M',
        rawGender: 'male',
        expectedGender: TeamGender.men,
        expectedDisplayName: 'Argentina - Men',
      );
      _expectArgentinaTeam(
        rawTeamName: 'Argentina-W',
        rawGender: 'female',
        expectedGender: TeamGender.women,
        expectedDisplayName: 'Argentina - Women',
      );
    });

    test('coluna gender aceita variantes: Mens, Masc, Woman, Femenino', () {
      // gender column vinda como "Mens" (plural) ou "Masc" deve cair em male.
      _expectArgentinaTeam(
        rawTeamName: 'Argentina',
        rawGender: 'Mens',
        expectedGender: TeamGender.men,
        expectedDisplayName: 'Argentina - Men',
      );
      _expectArgentinaTeam(
        rawTeamName: 'Argentina',
        rawGender: 'Masc',
        expectedGender: TeamGender.men,
        expectedDisplayName: 'Argentina - Men',
      );
      _expectArgentinaTeam(
        rawTeamName: 'Argentina',
        rawGender: 'Woman',
        expectedGender: TeamGender.women,
        expectedDisplayName: 'Argentina - Women',
      );
      _expectArgentinaTeam(
        rawTeamName: 'Argentina',
        rawGender: 'Femenino',
        expectedGender: TeamGender.women,
        expectedDisplayName: 'Argentina - Women',
      );
    });

    test(
        'USA com nome longo + variantes de genero: '
        '"United States America Men", "USA M", "US Fem"', () {
      final SheetData sheet = _sheet('Players', <List<String?>>[
        _row(<String?>[
          'team_name', 'shirt_number', 'surname', 'first_name',
          'player_class', 'dob', 'gender',
        ]),
        _row(<String?>[
          'United States America Men', '4', 'Smith', 'John', '2.0',
          '1995-01-01', 'male',
        ]),
        _row(<String?>[
          'USA M', '5', 'Davis', 'Mike', '3.0', '1996-02-02', 'm',
        ]),
        _row(<String?>[
          'US Fem', '6', 'Jones', 'Lisa', '1.5', '1997-03-03', 'female',
        ]),
      ]);

      final SpreadsheetParseResult result =
          parser.parseSheets(<SheetData>[sheet]);

      expect(result.hasBlockingIssues, isFalse,
          reason: result.issues.toString());
      // 3 atletas, 2 times (USA Men com 2, USA Women com 1).
      expect(result.teams, hasLength(2));
      final Team men = result.teams.firstWhere(
          (Team t) => t.gender == TeamGender.men);
      final Team women = result.teams.firstWhere(
          (Team t) => t.gender == TeamGender.women);
      expect(men.displayName, equals('United States of America - Men'));
      expect(women.displayName, equals('United States of America - Women'));
      expect(men.players, hasLength(2));
      expect(women.players, hasLength(1));
    });

    test('strip NAO ataca o nome quando nao ha separador antes do keyword',
        () {
      // "ArgM" nao tem espaco antes de "M". Deve ficar literal e o
      // resolver vai cair em fallback (nome desconhecido).
      final SheetData sheet = _sheet('Players', <List<String?>>[
        _row(<String?>[
          'team_name', 'shirt_number', 'surname', 'first_name',
          'player_class', 'dob', 'gender',
        ]),
        _row(<String?>[
          'ArgM', '7', 'Lopez', 'Diego', '2.5', '1998-01-02', 'male',
        ]),
      ]);

      final SpreadsheetParseResult result =
          parser.parseSheets(<SheetData>[sheet]);

      // Nome literal "ArgM" — nao bate com nenhum alias. Deve gerar warning
      // unknownTeam (mas nao bloqueante).
      final List<ParseIssue> unknowns = result.issues
          .where((ParseIssue i) =>
              i.category == ParseIssueCategory.unknownTeam)
          .toList();
      expect(unknowns, hasLength(1));
      expect(result.teams.first.teamName, equals('ArgM'));
    });
  });

  group('SpreadsheetParserService - regressao Chile (entrada 0029)', () {
    final SpreadsheetParserService parser = SpreadsheetParserService();

    test('aba unica com Chile NAO gera warning "unknown team"', () {
      final SheetData sheet = _sheet('Players', <List<String?>>[
        _row(<String?>[
          'team_name', 'shirt_number', 'surname', 'first_name',
          'player_class', 'dob', 'gender',
        ]),
        _row(<String?>[
          'Chile', '7', 'Soto', 'Diego', '2.5', '1998-01-02', 'male',
        ]),
      ]);

      final SpreadsheetParseResult result =
          parser.parseSheets(<SheetData>[sheet]);

      expect(result.hasBlockingIssues, isFalse);
      final List<ParseIssue> unknowns = result.issues
          .where((ParseIssue i) =>
              i.category == ParseIssueCategory.unknownTeam)
          .toList();
      expect(unknowns, isEmpty,
          reason:
              'Chile esta na lista oficial — nao deveria gerar warning.');
      expect(result.teams.first.teamName, equals('Chile'));
      expect(result.teams.first.displayName, equals('Chile - Men'));
    });

    test('per-team com abas "Chile Men" / "Chile Women" sem warning', () {
      final SheetData men = _sheet('Chile Men', <List<String?>>[
        _row(<String?>[
          'shirt_number', 'surname', 'first_name',
          'player_class', 'dob', 'gender',
        ]),
        _row(<String?>['7', 'Soto', 'Diego', '2.5', '1998-01-02', 'male']),
      ]);
      final SheetData women = _sheet('Chile Women', <List<String?>>[
        _row(<String?>[
          'shirt_number', 'surname', 'first_name',
          'player_class', 'dob', 'gender',
        ]),
        _row(<String?>['9', 'Diaz', 'Sofia', '3.0', '1996-05-10', 'female']),
      ]);

      final SpreadsheetParseResult result =
          parser.parseSheets(<SheetData>[men, women]);

      final List<ParseIssue> unknowns = result.issues
          .where((ParseIssue i) =>
              i.category == ParseIssueCategory.unknownTeam)
          .toList();
      expect(unknowns, isEmpty,
          reason:
              'Abas "Chile Men"/"Chile Women" devem ser reconhecidas via '
              'strip do sufixo de genero.');
      expect(result.teams, hasLength(2));
      final Set<String> names =
          result.teams.map((Team t) => t.displayName).toSet();
      expect(names, containsAll(<String>['Chile - Men', 'Chile - Women']));
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
