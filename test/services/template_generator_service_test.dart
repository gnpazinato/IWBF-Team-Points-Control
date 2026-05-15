import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:iwbf_team_points_control/services/spreadsheet_parser_service.dart';
import 'package:iwbf_team_points_control/services/template_generator_service.dart';

void main() {
  late TemplateGeneratorService generator;
  late SpreadsheetParserService parser;

  setUp(() {
    generator = const TemplateGeneratorService();
    parser = SpreadsheetParserService();
  });

  // Os templates vêm pré-preenchidos com 8 países × 2 gêneros = 16 equipes,
  // 12 atletas por equipe = 192 atletas no total. Competição: IWBF America's Cup.
  const Set<String> expectedCountries = <String>{
    'Argentina',
    'Brazil',
    'Canada',
    'Chile',
    'Colombia',
    'Mexico',
    'United States of America',
    'Venezuela',
  };

  group('TemplateGeneratorService — single sheet', () {
    test('produz bytes não vazios', () {
      final Uint8List bytes = generator.build(TemplateKind.singleSheet);
      expect(bytes.lengthInBytes, greaterThan(0));
    });

    test('o parser consegue ler o template (16 equipes, 192 atletas)', () {
      final Uint8List bytes = generator.build(TemplateKind.singleSheet);
      final SpreadsheetParseResult result = parser.parseBytes(bytes);

      expect(result.hasBlockingIssues, isFalse,
          reason:
              'Erros bloqueantes: ${result.issues.map((i) => i.message).join('; ')}');
      expect(result.teams, hasLength(16));
      expect(result.playerCount, equals(192));
      expect(result.competitionName, equals("IWBF America's Cup"));
      // Todos os 8 países aparecem (cada um vira 2 equipes: Men + Women).
      expect(
        result.teams.map((t) => t.teamName).toSet(),
        equals(expectedCountries),
      );
    });

    test('filename sugerido é iwbf_template_single_sheet.xlsx', () {
      expect(
        generator.filenameFor(TemplateKind.singleSheet),
        'iwbf_template_single_sheet.xlsx',
      );
    });
  });

  group('TemplateGeneratorService — per team', () {
    test('produz bytes não vazios', () {
      final Uint8List bytes = generator.build(TemplateKind.perTeam);
      expect(bytes.lengthInBytes, greaterThan(0));
    });

    test('o parser identifica 16 equipes (8 países × 2 gêneros)', () {
      final Uint8List bytes = generator.build(TemplateKind.perTeam);
      final SpreadsheetParseResult result = parser.parseBytes(bytes);

      expect(result.hasBlockingIssues, isFalse,
          reason:
              'Erros bloqueantes: ${result.issues.map((i) => i.message).join('; ')}');
      expect(result.teams, hasLength(16));
      expect(result.playerCount, equals(192));
      expect(
        result.teams.map((t) => t.teamName).toSet(),
        equals(expectedCountries),
      );
    });

    test('filename sugerido é iwbf_template_per_team.xlsx', () {
      expect(
        generator.filenameFor(TemplateKind.perTeam),
        'iwbf_template_per_team.xlsx',
      );
    });
  });
}
