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

  group('TemplateGeneratorService — single sheet', () {
    test('produz bytes não vazios', () {
      final Uint8List bytes = generator.build(TemplateKind.singleSheet);
      expect(bytes.lengthInBytes, greaterThan(0));
    });

    test('o parser consegue ler o template como Players sem erros bloqueantes',
        () {
      final Uint8List bytes = generator.build(TemplateKind.singleSheet);
      final SpreadsheetParseResult result = parser.parseBytes(bytes);

      expect(result.hasBlockingIssues, isFalse,
          reason: 'Erros bloqueantes: ${result.issues.map((i) => i.message).join('; ')}');
      expect(result.teams.map((t) => t.teamName), containsAll(<String>['Brazil', 'Argentina']));
      expect(result.playerCount, 4);
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

    test('o parser identifica duas abas (Brazil e Argentina)', () {
      final Uint8List bytes = generator.build(TemplateKind.perTeam);
      final SpreadsheetParseResult result = parser.parseBytes(bytes);

      expect(result.hasBlockingIssues, isFalse,
          reason: 'Erros bloqueantes: ${result.issues.map((i) => i.message).join('; ')}');
      expect(result.teams.length, 2);
      expect(result.teams.map((t) => t.teamName), containsAll(<String>['Brazil', 'Argentina']));
      expect(result.playerCount, 4);
    });

    test('filename sugerido é iwbf_template_per_team.xlsx', () {
      expect(
        generator.filenameFor(TemplateKind.perTeam),
        'iwbf_template_per_team.xlsx',
      );
    });
  });
}
