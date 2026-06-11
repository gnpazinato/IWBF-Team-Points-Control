import 'dart:typed_data';

import 'package:excel/excel.dart' as xlsx;
import 'package:flutter_test/flutter_test.dart';
import 'package:iwbf_team_points_control/models/player.dart';
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
      expect(teamBrazil.players.first.name, equals('SILVA, João'));
      expect(teamBrazil.players.first.shirtNumber, equals('7'));
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

    test('preserva "00" e "0" como camisas distintas (texto)', () {
      // "00" e "0" são rótulos diferentes: o parser deve preservar o texto
      // exato (zeros à esquerda) e não tratá-los como números iguais.
      final SheetData sheet = _sheet('Players', <List<String?>>[
        _row(<String?>['team_name', 'shirt_number', 'surname', 'first_name', 'player_class', 'dob']),
        _row(<String?>['Brazil', '00', 'Silva', 'João', '2.5', '1998-01-02']),
        _row(<String?>['Brazil', '0', 'Souza', 'Pedro', '4.0', '1995-12-31']),
      ]);

      final SpreadsheetParseResult result =
          parser.parseSheets(<SheetData>[sheet]);

      expect(result.hasBlockingIssues, isFalse,
          reason: result.issues.toString());
      final Team brazil =
          result.teams.firstWhere((Team t) => t.teamName == 'Brazil');
      final List<String> shirts =
          brazil.players.map((Player p) => p.shirtNumber).toList();
      expect(shirts, containsAll(<String>['00', '0']));
      // Distintos: dois jogadores, rótulos diferentes.
      expect(brazil.players, hasLength(2));
      expect(shirts.toSet(), hasLength(2));
    });

    test('celula numerica "7.0" vira camisa "7" (sem ".0")', () {
      final SheetData sheet = _sheet('Players', <List<String?>>[
        _row(<String?>['team_name', 'shirt_number', 'surname', 'first_name', 'player_class', 'dob']),
        _row(<String?>['Brazil', '7.0', 'Silva', 'João', '2.5', '1998-01-02']),
      ]);

      final SpreadsheetParseResult result =
          parser.parseSheets(<SheetData>[sheet]);

      expect(result.hasBlockingIssues, isFalse,
          reason: result.issues.toString());
      expect(result.teams.first.players.first.shirtNumber, equals('7'));
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

    test('aceita DOB com separador hifen e ano de 4 digitos', () {
      final SheetData sheet = _sheet('Players', <List<String?>>[
        _row(<String?>['team_name', 'shirt_number', 'surname', 'first_name', 'player_class', 'dob']),
        _row(<String?>['Brazil', '7', 'Silva', 'João', '2.5', '12-12-2025']),
      ]);
      final SpreadsheetParseResult result =
          parser.parseSheets(<SheetData>[sheet]);
      expect(result.teams.first.players.first.dateOfBirth,
          equals(DateTime.utc(2025, 12, 12)));
    });

    test('aceita DOB com ano de 2 digitos (12-12-25 -> 2025)', () {
      final SheetData sheet = _sheet('Players', <List<String?>>[
        _row(<String?>['team_name', 'shirt_number', 'surname', 'first_name', 'player_class', 'dob']),
        _row(<String?>['Brazil', '7', 'Silva', 'João', '2.5', '12-12-25']),
      ]);
      final SpreadsheetParseResult result =
          parser.parseSheets(<SheetData>[sheet]);
      expect(result.teams.first.players.first.dateOfBirth,
          equals(DateTime.utc(2025, 12, 12)));
    });

    test('ano de 2 digitos acima do pivo cai no seculo 1900 (90 -> 1990)', () {
      final SheetData sheet = _sheet('Players', <List<String?>>[
        _row(<String?>['team_name', 'shirt_number', 'surname', 'first_name', 'player_class', 'dob']),
        _row(<String?>['Brazil', '7', 'Silva', 'João', '2.5', '05/06/90']),
      ]);
      final SpreadsheetParseResult result =
          parser.parseSheets(<SheetData>[sheet]);
      expect(result.teams.first.players.first.dateOfBirth,
          equals(DateTime.utc(1990, 6, 5)));
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
      expect(result.teams.first.players.first.shirtNumber, equals('7'));
      expect(result.teams.first.players.first.playerClass, equals(2.5));
    });
  });

  group('SpreadsheetParserService - aliases de coluna (entrada 0039)', () {
    final SpreadsheetParserService parser = SpreadsheetParserService();

    test('planilha real estilo IWBF: COUNTRY/FULL NAME + colunas ignoradas',
        () {
      // Reproduz a planilha anexada pelo usuário: uma única aba (não
      // chamada "Players") com COMPETITION, COUNTRY, CLASS, FULL NAME,
      // NUMBER e colunas que devem ser IGNORADAS (FIRST/LAST NAME pois já
      // há FULL NAME, ROLE, CS). Vários países na mesma aba.
      final SheetData sheet = _sheet('Sheet1', <List<String?>>[
        _row(<String?>[
          'COMPETITION', 'COUNTRY', 'CLASS', 'FULL NAME', 'NUMBER',
          'FIRST NAME', 'LAST NAME', 'DOB', 'ROLE', 'CS',
        ]),
        _row(<String?>[
          'WM Repechage', 'Argentina', '4.0', 'Paiva, Evangelina', '4',
          'Evangelina', 'Paiva', '27/12/1987', 'PLAYER', 'C',
        ]),
        _row(<String?>[
          'WM Repechage', 'Australia', '1.0', 'Vinci, Sarah', '4',
          'Sarah', 'Vinci', '04/12/1991', 'PLAYER', 'C',
        ]),
        _row(<String?>[
          'WM Repechage', 'France', '3.5', 'Veuille, Mathilde', '0',
          'Mathilde', 'Veuille', '19/01/1993', 'PLAYER', 'N',
        ]),
      ]);

      final SpreadsheetParseResult result =
          parser.parseSheets(<SheetData>[sheet]);

      expect(result.hasBlockingIssues, isFalse,
          reason: result.issues.toString());
      expect(result.competitionName, equals('WM Repechage'));
      // Três países distintos viram três equipes (gênero unspecified, pois
      // não há coluna gender).
      expect(result.teams.map((Team t) => t.teamName).toSet(),
          equals(<String>{'Argentina', 'Australia', 'France'}));
      final Team arg =
          result.teams.firstWhere((Team t) => t.teamName == 'Argentina');
      // Usou FULL NAME (não reconstruiu de first/last name).
      expect(arg.players.first.name, equals('Paiva, Evangelina'));
      expect(arg.players.first.playerClass, equals(4.0));
      expect(arg.players.first.shirtNumber, equals('4'));
      expect(arg.players.first.dateOfBirth, equals(DateTime.utc(1987, 12, 27)));
    });

    test('aliases: country=team, classification=class, tournament=competition',
        () {
      final SheetData sheet = _sheet('Players', <List<String?>>[
        _row(<String?>[
          'tournament', 'country', 'classification', 'player_name',
          'jersey_number',
        ]),
        _row(<String?>['Worlds', 'Brazil', '2.5', 'SILVA, João', '7']),
      ]);

      final SpreadsheetParseResult result =
          parser.parseSheets(<SheetData>[sheet]);

      expect(result.hasBlockingIssues, isFalse,
          reason: result.issues.toString());
      expect(result.competitionName, equals('Worlds'));
      expect(result.teams.first.teamName, equals('Brazil'));
      expect(result.teams.first.players.first.name, equals('SILVA, João'));
      expect(result.teams.first.players.first.playerClass, equals(2.5));
      expect(result.teams.first.players.first.shirtNumber, equals('7'));
    });

    test('sem FULL NAME: reconstrói "SOBRENOME, Nome" de last/first name', () {
      final SheetData sheet = _sheet('Players', <List<String?>>[
        _row(<String?>[
          'team_name', 'number', 'last_name', 'first_name', 'class',
        ]),
        _row(<String?>['Brazil', '7', 'Silva', 'João', '2.5']),
      ]);

      final SpreadsheetParseResult result =
          parser.parseSheets(<SheetData>[sheet]);

      expect(result.hasBlockingIssues, isFalse,
          reason: result.issues.toString());
      expect(result.teams.first.players.first.name, equals('SILVA, João'));
    });

    test('colunas obrigatórias mínimas: team_name, class, name, number', () {
      // Sem dob nem gender — não deve bloquear; ficam em branco.
      final SheetData sheet = _sheet('Players', <List<String?>>[
        _row(<String?>['country', 'sport_class', 'full_name', 'number']),
        _row(<String?>['Brazil', '2.5', 'SILVA, João', '7']),
      ]);

      final SpreadsheetParseResult result =
          parser.parseSheets(<SheetData>[sheet]);

      expect(result.hasBlockingIssues, isFalse,
          reason: result.issues.toString());
      expect(result.teams.first.players.first.dateOfBirth, isNull);
      expect(result.teams.first.players.first.gender,
          equals(PlayerGender.unspecified));
    });

    test('título da aba é irrelevante: aba "Foo" com coluna de equipe', () {
      // O nome da aba ("Foo") não tem nada a ver com equipe — o que vale
      // é a coluna `country`. Deve virar Brazil + Argentina.
      final SheetData sheet = _sheet('Foo Bar 123', <List<String?>>[
        _row(<String?>['country', 'class', 'full_name', 'number']),
        _row(<String?>['Brazil', '2.5', 'SILVA, João', '7']),
        _row(<String?>['Argentina', '1.5', 'LOPEZ, Carlos', '4']),
      ]);

      final SpreadsheetParseResult result =
          parser.parseSheets(<SheetData>[sheet]);

      expect(result.hasBlockingIssues, isFalse,
          reason: result.issues.toString());
      expect(result.teams.map((Team t) => t.teamName).toSet(),
          equals(<String>{'Brazil', 'Argentina'}));
    });

    test('aba "todas as equipes" vence: demais abas são ignoradas', () {
      // Workbook com a planilha real (coluna de equipe) + uma aba de
      // instruções sem coluna de equipe. A de instruções é ignorada.
      final SheetData roster = _sheet('Roster', <List<String?>>[
        _row(<String?>['country', 'class', 'full_name', 'number']),
        _row(<String?>['Brazil', '2.5', 'SILVA, João', '7']),
        _row(<String?>['Argentina', '1.5', 'LOPEZ, Carlos', '4']),
      ]);
      final SheetData notes = _sheet('Instructions', <List<String?>>[
        _row(<String?>['note']),
        _row(<String?>['Fill one row per athlete.']),
        _row(<String?>['Columns can be in any order.']),
      ]);

      final SpreadsheetParseResult result =
          parser.parseSheets(<SheetData>[roster, notes]);

      expect(result.hasBlockingIssues, isFalse,
          reason: result.issues.toString());
      expect(result.teams.map((Team t) => t.teamName).toSet(),
          equals(<String>{'Brazil', 'Argentina'}));
    });

    test('múltiplas abas com coluna de equipe são combinadas', () {
      final SheetData groupA = _sheet('Group A', <List<String?>>[
        _row(<String?>['country', 'class', 'full_name', 'number']),
        _row(<String?>['Brazil', '2.5', 'SILVA, João', '7']),
        _row(<String?>['Argentina', '1.5', 'LOPEZ, Carlos', '4']),
      ]);
      final SheetData groupB = _sheet('Group B', <List<String?>>[
        _row(<String?>['country', 'class', 'full_name', 'number']),
        _row(<String?>['Chile', '3.0', 'SOTO, Diego', '9']),
        _row(<String?>['Colombia', '4.0', 'GOMEZ, Gladys', '14']),
      ]);

      final SpreadsheetParseResult result =
          parser.parseSheets(<SheetData>[groupA, groupB]);

      expect(result.hasBlockingIssues, isFalse,
          reason: result.issues.toString());
      expect(result.teams.map((Team t) => t.teamName).toSet(),
          equals(<String>{'Brazil', 'Argentina', 'Chile', 'Colombia'}));
    });
  });
}
