import 'dart:typed_data';

import 'package:excel/excel.dart' as xlsx;

/// Identifica qual layout de planilha exemplo gerar.
enum TemplateKind { singleSheet, perTeam }

/// Gera planilhas modelo `.xlsx` que o usuário pode baixar e usar como
/// ponto de partida na importação.
///
/// Os dois layouts seguem o que o `SpreadsheetParserService` aceita:
/// - [TemplateKind.singleSheet]: uma única aba `Players` com todas as
///   colunas (`competition_name`, `team_name`, `shirt_number`, `surname`,
///   `first_name`, `player_class`, `dob`, `gender`).
/// - [TemplateKind.perTeam]: uma aba por equipe (`Brazil`, `Argentina`
///   como exemplo) com colunas mínimas.
class TemplateGeneratorService {
  const TemplateGeneratorService();

  /// Colunas do modelo de aba única.
  static const List<String> singleSheetHeaders = <String>[
    'competition_name',
    'team_name',
    'shirt_number',
    'surname',
    'first_name',
    'player_class',
    'dob',
    'gender',
  ];

  /// Colunas do modelo de uma aba por equipe.
  static const List<String> perTeamHeaders = <String>[
    'shirt_number',
    'surname',
    'first_name',
    'player_class',
    'dob',
    'gender',
  ];

  /// Nome da aba no modelo de aba única.
  static const String singleSheetTabName = 'Players';

  /// Lista das equipes de exemplo no modelo de uma aba por equipe.
  static const List<String> exampleTeams = <String>['Brazil', 'Argentina'];

  /// Gera os bytes do template solicitado.
  Uint8List build(TemplateKind kind) {
    switch (kind) {
      case TemplateKind.singleSheet:
        return _buildSingleSheet();
      case TemplateKind.perTeam:
        return _buildPerTeam();
    }
  }

  /// Nome de arquivo sugerido (sem path) para cada layout.
  String filenameFor(TemplateKind kind) {
    switch (kind) {
      case TemplateKind.singleSheet:
        return 'iwbf_template_single_sheet.xlsx';
      case TemplateKind.perTeam:
        return 'iwbf_template_per_team.xlsx';
    }
  }

  Uint8List _buildSingleSheet() {
    final xlsx.Excel excel = xlsx.Excel.createExcel();
    excel.rename(excel.getDefaultSheet()!, singleSheetTabName);

    excel.appendRow(
      singleSheetTabName,
      singleSheetHeaders
          .map((String h) => xlsx.TextCellValue(h))
          .toList(growable: false),
    );
    for (final _SamplePlayer p in _sampleRoster) {
      excel.appendRow(singleSheetTabName, <xlsx.CellValue?>[
        xlsx.TextCellValue('IWBF Sample Championship'),
        xlsx.TextCellValue(p.team),
        xlsx.IntCellValue(p.shirt),
        xlsx.TextCellValue(p.surname),
        xlsx.TextCellValue(p.firstName),
        xlsx.DoubleCellValue(p.playerClass),
        xlsx.TextCellValue(p.dob),
        xlsx.TextCellValue(p.gender),
      ]);
    }

    return _encode(excel);
  }

  Uint8List _buildPerTeam() {
    final xlsx.Excel excel = xlsx.Excel.createExcel();
    final String? defaultSheet = excel.getDefaultSheet();

    for (final String teamName in exampleTeams) {
      excel.appendRow(
        teamName,
        perTeamHeaders
            .map((String h) => xlsx.TextCellValue(h))
            .toList(growable: false),
      );
      for (final _SamplePlayer p
          in _sampleRoster.where((_SamplePlayer p) => p.team == teamName)) {
        excel.appendRow(teamName, <xlsx.CellValue?>[
          xlsx.IntCellValue(p.shirt),
          xlsx.TextCellValue(p.surname),
          xlsx.TextCellValue(p.firstName),
          xlsx.DoubleCellValue(p.playerClass),
          xlsx.TextCellValue(p.dob),
          xlsx.TextCellValue(p.gender),
        ]);
      }
    }

    // Remove a aba padrão criada pela lib (`Sheet1`) se ela não for um
    // dos templates.
    if (defaultSheet != null && !exampleTeams.contains(defaultSheet)) {
      excel.delete(defaultSheet);
    }

    return _encode(excel);
  }

  Uint8List _encode(xlsx.Excel excel) {
    final List<int>? bytes = excel.encode();
    if (bytes == null) {
      throw StateError('Failed to encode generated .xlsx template.');
    }
    return Uint8List.fromList(bytes);
  }
}

class _SamplePlayer {
  const _SamplePlayer({
    required this.team,
    required this.shirt,
    required this.surname,
    required this.firstName,
    required this.playerClass,
    required this.dob,
    required this.gender,
  });

  final String team;
  final int shirt;
  final String surname;
  final String firstName;
  final double playerClass;
  final String dob;
  final String gender;
}

const List<_SamplePlayer> _sampleRoster = <_SamplePlayer>[
  _SamplePlayer(
    team: 'Brazil',
    shirt: 4,
    surname: 'SILVA',
    firstName: 'João',
    playerClass: 2.5,
    dob: '1995-04-15',
    gender: 'male',
  ),
  _SamplePlayer(
    team: 'Brazil',
    shirt: 7,
    surname: 'SOUZA',
    firstName: 'Maria',
    playerClass: 3.0,
    dob: '1998-07-22',
    gender: 'female',
  ),
  _SamplePlayer(
    team: 'Argentina',
    shirt: 5,
    surname: 'GARCIA',
    firstName: 'Carlos',
    playerClass: 2.0,
    dob: '1996-02-11',
    gender: 'male',
  ),
  _SamplePlayer(
    team: 'Argentina',
    shirt: 9,
    surname: 'PEREZ',
    firstName: 'Ana',
    playerClass: 1.5,
    dob: '1999-09-30',
    gender: 'female',
  ),
];
