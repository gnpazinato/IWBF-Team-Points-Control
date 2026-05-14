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
/// - [TemplateKind.perTeam]: uma aba por equipe com colunas mínimas
///   (mesmas colunas, sem o `team_name` — derivado do nome da aba).
///
/// Ambas vêm **pré-preenchidas** com 16 equipes (8 países × 2 gêneros)
/// e 12 atletas por equipe, distribuídos com classes funcionais oficiais
/// (`1.0`, `1.5`, `2.0`, `2.5`, `3.0`, `3.5`, `4.0`×3, `4.5`×3). O
/// usuário pode importar o template direto pra testar o app sem precisar
/// digitar dados fictícios.
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
    'competition_name',
    'shirt_number',
    'surname',
    'first_name',
    'player_class',
    'dob',
    'gender',
  ];

  /// Nome da aba no modelo de aba única.
  static const String singleSheetTabName = 'Players';

  /// Competição de exemplo embarcada nos templates.
  static const String sampleCompetition = "IWBF America's Cup";

  /// Distribuição oficial de classes por equipe (12 atletas).
  /// Soma = 35.5 pontos, dá margem confortável pros limites IWBF (13.0-16.0).
  static const List<double> _classDistribution = <double>[
    1.0, 1.5, 2.0, 2.5, 3.0, 3.5, 4.0, 4.0, 4.0, 4.5, 4.5, 4.5,
  ];

  /// Números de camiseta usados em cada equipe.
  static const List<int> _shirts = <int>[
    4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15,
  ];

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
    for (final _SampleRow row in _expandSampleRows()) {
      excel.appendRow(singleSheetTabName, <xlsx.CellValue?>[
        xlsx.TextCellValue(sampleCompetition),
        xlsx.TextCellValue(row.teamName),
        xlsx.IntCellValue(row.shirt),
        xlsx.TextCellValue(row.surname),
        xlsx.TextCellValue(row.firstName),
        xlsx.TextCellValue(_formatPlayerClass(row.playerClass)),
        xlsx.TextCellValue(_formatDob(row.dob)),
        xlsx.TextCellValue(row.gender),
      ]);
    }

    return _encode(excel);
  }

  Uint8List _buildPerTeam() {
    final xlsx.Excel excel = xlsx.Excel.createExcel();
    final String? defaultSheet = excel.getDefaultSheet();

    final Map<String, List<_SampleRow>> rowsByTab =
        <String, List<_SampleRow>>{};
    for (final _SampleRow r in _expandSampleRows()) {
      final String tab = _tabNameFor(r);
      rowsByTab.putIfAbsent(tab, () => <_SampleRow>[]).add(r);
    }

    // Mantém a ordem dos países e gêneros conforme [_sampleTeams].
    for (final String tabName in rowsByTab.keys) {
      excel.appendRow(
        tabName,
        perTeamHeaders
            .map((String h) => xlsx.TextCellValue(h))
            .toList(growable: false),
      );
      for (final _SampleRow row in rowsByTab[tabName]!) {
        excel.appendRow(tabName, <xlsx.CellValue?>[
          xlsx.TextCellValue(sampleCompetition),
          xlsx.IntCellValue(row.shirt),
          xlsx.TextCellValue(row.surname),
          xlsx.TextCellValue(row.firstName),
          xlsx.TextCellValue(_formatPlayerClass(row.playerClass)),
          xlsx.TextCellValue(_formatDob(row.dob)),
          xlsx.TextCellValue(row.gender),
        ]);
      }
    }

    if (defaultSheet != null && !rowsByTab.containsKey(defaultSheet)) {
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

  static String _formatPlayerClass(double value) {
    final String fixed = value.toStringAsFixed(1);
    return fixed.replaceAll('.', ',');
  }

  /// `1995-04-15` -> `15/04/1995`.
  static String _formatDob(String iso) {
    final List<String> parts = iso.split('-');
    if (parts.length != 3) return iso;
    return '${parts[2]}/${parts[1]}/${parts[0]}';
  }

  /// Nome da aba pro template "uma aba por equipe": "Argentina Men",
  /// "Brazil Women" etc.
  static String _tabNameFor(_SampleRow row) {
    final String suffix = row.gender == 'male' ? 'Men' : 'Women';
    return '${row.teamName} $suffix';
  }

  /// Materializa as 192 linhas (16 equipes × 12 atletas) a partir do
  /// catálogo `_sampleTeams`. Cada atleta recebe shirt, classe e DOB
  /// definidos pelas listas constantes.
  Iterable<_SampleRow> _expandSampleRows() sync* {
    for (int t = 0; t < _sampleTeams.length; t++) {
      final _SampleTeam team = _sampleTeams[t];
      for (int i = 0; i < 12; i++) {
        yield _SampleRow(
          teamName: team.country,
          gender: team.gender,
          shirt: _shirts[i],
          surname: team.surnames[i],
          firstName: team.firstNames[i],
          playerClass: _classDistribution[i],
          dob: _dobFor(t, i),
        );
      }
    }
  }

  /// DOBs variadas (ano + dia/mês) por equipe e jogador. Mantém atletas
  /// na faixa 1986-2005 (≈ 21-40 anos em 2026).
  static String _dobFor(int teamIndex, int playerIndex) {
    const List<int> years = <int>[
      1988, 1990, 1992, 1994, 1996, 1998,
      2000, 2002, 1991, 1993, 1995, 1997,
    ];
    final int year = years[playerIndex];
    final int day = ((teamIndex * 7 + playerIndex * 3) % 27) + 1;
    final int month = ((teamIndex * 3 + playerIndex * 5) % 12) + 1;
    final String d = day.toString().padLeft(2, '0');
    final String m = month.toString().padLeft(2, '0');
    return '$year-$m-$d';
  }
}

class _SampleRow {
  const _SampleRow({
    required this.teamName,
    required this.gender,
    required this.shirt,
    required this.surname,
    required this.firstName,
    required this.playerClass,
    required this.dob,
  });

  final String teamName;
  final String gender;
  final int shirt;
  final String surname;
  final String firstName;
  final double playerClass;
  final String dob;
}

class _SampleTeam {
  const _SampleTeam({
    required this.country,
    required this.gender,
    required this.surnames,
    required this.firstNames,
  });

  final String country;
  final String gender;
  final List<String> surnames;
  final List<String> firstNames;
}

const List<_SampleTeam> _sampleTeams = <_SampleTeam>[
  // ARGENTINA
  _SampleTeam(
    country: 'Argentina',
    gender: 'male',
    surnames: <String>[
      'LOPEZ', 'RODRIGUEZ', 'GARCIA', 'MARTINEZ',
      'GONZALEZ', 'HERNANDEZ', 'DIAZ', 'RAMIREZ',
      'SANCHEZ', 'TORRES', 'ROMERO', 'SUAREZ',
    ],
    firstNames: <String>[
      'Carlos', 'Juan', 'Pablo', 'Diego',
      'Sebastian', 'Lucas', 'Matias', 'Nicolas',
      'Joaquin', 'Tomas', 'Bautista', 'Santiago',
    ],
  ),
  _SampleTeam(
    country: 'Argentina',
    gender: 'female',
    surnames: <String>[
      'FERNANDEZ', 'PEREZ', 'GOMEZ', 'MORENO',
      'CASTRO', 'ALVAREZ', 'JIMENEZ', 'RUIZ',
      'VARGAS', 'AGUIRRE', 'ROJAS', 'CABRERA',
    ],
    firstNames: <String>[
      'Sofia', 'Maria', 'Lucia', 'Camila',
      'Valentina', 'Catalina', 'Martina', 'Julieta',
      'Florencia', 'Agustina', 'Renata', 'Mia',
    ],
  ),

  // BRAZIL
  _SampleTeam(
    country: 'Brazil',
    gender: 'male',
    surnames: <String>[
      'SILVA', 'SANTOS', 'SOUZA', 'OLIVEIRA',
      'PEREIRA', 'LIMA', 'COSTA', 'FERREIRA',
      'RODRIGUES', 'ALMEIDA', 'CARVALHO', 'GOMES',
    ],
    firstNames: <String>[
      'João', 'Pedro', 'Lucas', 'Gabriel',
      'Matheus', 'Rafael', 'Bruno', 'Felipe',
      'Thiago', 'Gustavo', 'Daniel', 'Leonardo',
    ],
  ),
  _SampleTeam(
    country: 'Brazil',
    gender: 'female',
    surnames: <String>[
      'SOUZA', 'RIBEIRO', 'ALVES', 'MARTINS',
      'BARBOSA', 'ROCHA', 'DIAS', 'NUNES',
      'CARDOSO', 'TEIXEIRA', 'PINTO', 'MENDES',
    ],
    firstNames: <String>[
      'Mariana', 'Ana', 'Beatriz', 'Camila',
      'Larissa', 'Juliana', 'Carolina', 'Fernanda',
      'Isabela', 'Letícia', 'Bruna', 'Amanda',
    ],
  ),

  // CANADA
  _SampleTeam(
    country: 'Canada',
    gender: 'male',
    surnames: <String>[
      'SMITH', 'WILSON', 'TREMBLAY', 'ROY',
      'MACDONALD', 'BOUCHARD', 'THOMPSON', 'ANDERSON',
      'WILLIAMS', 'BROWN', 'DAVIS', 'TAYLOR',
    ],
    firstNames: <String>[
      'James', 'Liam', 'Noah', 'William',
      'Olivier', 'Hugo', 'Ethan', 'Lucas',
      'Benjamin', 'Alexander', 'Mason', 'Felix',
    ],
  ),
  _SampleTeam(
    country: 'Canada',
    gender: 'female',
    surnames: <String>[
      'MARTIN', 'GAGNON', 'CLARK', 'LEWIS',
      'WALKER', 'YOUNG', 'BELANGER', 'WHITE',
      'HARRIS', 'LEE', 'NELSON', 'MORIN',
    ],
    firstNames: <String>[
      'Emma', 'Olivia', 'Charlotte', 'Amelia',
      'Sophia', 'Léa', 'Chloé', 'Hannah',
      'Madison', 'Avery', 'Isla', 'Zoé',
    ],
  ),

  // CHILE
  _SampleTeam(
    country: 'Chile',
    gender: 'male',
    surnames: <String>[
      'MUNOZ', 'GONZALEZ', 'ROJAS', 'DIAZ',
      'SOTO', 'CONTRERAS', 'SILVA', 'SEPULVEDA',
      'REYES', 'LOPEZ', 'CASTRO', 'TAPIA',
    ],
    firstNames: <String>[
      'Benjamin', 'Vicente', 'Maximiliano', 'Cristobal',
      'Felipe', 'Joaquin', 'Agustin', 'Tomas',
      'Sebastian', 'Martin', 'Bastian', 'Ignacio',
    ],
  ),
  _SampleTeam(
    country: 'Chile',
    gender: 'female',
    surnames: <String>[
      'NAVARRO', 'FUENTES', 'GUTIERREZ', 'CARRASCO',
      'MIRANDA', 'ESPINOZA', 'BRAVO', 'CORTES',
      'PINO', 'AGUILAR', 'PARRA', 'TAPIA',
    ],
    firstNames: <String>[
      'Antonella', 'Florencia', 'Isidora', 'Javiera',
      'Catalina', 'Constanza', 'Antonia', 'Trinidad',
      'Emilia', 'Amanda', 'Renata', 'Magdalena',
    ],
  ),

  // COLOMBIA
  _SampleTeam(
    country: 'Colombia',
    gender: 'male',
    surnames: <String>[
      'GOMEZ', 'HERRERA', 'CASTILLO', 'OSPINA',
      'CARDONA', 'QUINTERO', 'OCHOA', 'VARGAS',
      'CASTANEDA', 'GIRALDO', 'JARAMILLO', 'PALACIO',
    ],
    firstNames: <String>[
      'Santiago', 'Sebastian', 'Mateo', 'Samuel',
      'Daniel', 'Andres', 'Juan', 'Esteban',
      'Camilo', 'Nicolas', 'Diego', 'Emilio',
    ],
  ),
  _SampleTeam(
    country: 'Colombia',
    gender: 'female',
    surnames: <String>[
      'RESTREPO', 'OSORIO', 'ARANGO', 'ZAPATA',
      'BETANCUR', 'MUNERA', 'MEJIA', 'VELASQUEZ',
      'ESCOBAR', 'GAVIRIA', 'POSADA', 'TORO',
    ],
    firstNames: <String>[
      'Isabella', 'Mariana', 'Valeria', 'Daniela',
      'Sara', 'Salome', 'Natalia', 'Manuela',
      'Antonia', 'Gabriela', 'Mariangel', 'Luciana',
    ],
  ),

  // MEXICO
  _SampleTeam(
    country: 'Mexico',
    gender: 'male',
    surnames: <String>[
      'HERNANDEZ', 'GARCIA', 'MARTINEZ', 'LOPEZ',
      'GONZALEZ', 'PEREZ', 'SANCHEZ', 'RAMIREZ',
      'FLORES', 'GUTIERREZ', 'CRUZ', 'MORALES',
    ],
    firstNames: <String>[
      'Miguel', 'Diego', 'Alejandro', 'Luis',
      'Jose', 'Eduardo', 'Ricardo', 'Emiliano',
      'Carlos', 'Hector', 'Pablo', 'Andres',
    ],
  ),
  _SampleTeam(
    country: 'Mexico',
    gender: 'female',
    surnames: <String>[
      'JIMENEZ', 'REYES', 'TORRES', 'VAZQUEZ',
      'CASTILLO', 'GUERRERO', 'MENDOZA', 'AGUILAR',
      'RIVERA', 'CHAVEZ', 'NAVARRO', 'CAMPOS',
    ],
    firstNames: <String>[
      'Sofia', 'Valentina', 'Camila', 'Mariana',
      'Renata', 'Regina', 'Ximena', 'Andrea',
      'Maria', 'Fernanda', 'Daniela', 'Romina',
    ],
  ),

  // UNITED STATES OF AMERICA
  _SampleTeam(
    country: 'United States of America',
    gender: 'male',
    surnames: <String>[
      'SMITH', 'JOHNSON', 'WILLIAMS', 'BROWN',
      'JONES', 'MILLER', 'DAVIS', 'WILSON',
      'ANDERSON', 'TAYLOR', 'THOMAS', 'MOORE',
    ],
    firstNames: <String>[
      'Michael', 'David', 'Christopher', 'Andrew',
      'Daniel', 'Joshua', 'Matthew', 'Anthony',
      'Tyler', 'Brandon', 'Justin', 'Aaron',
    ],
  ),
  _SampleTeam(
    country: 'United States of America',
    gender: 'female',
    surnames: <String>[
      'MILLER', 'JACKSON', 'WHITE', 'HARRIS',
      'CLARK', 'LEWIS', 'WALKER', 'ALLEN',
      'YOUNG', 'KING', 'WRIGHT', 'SCOTT',
    ],
    firstNames: <String>[
      'Emily', 'Ashley', 'Jessica', 'Sarah',
      'Madison', 'Hannah', 'Brittany', 'Lauren',
      'Megan', 'Rachel', 'Stephanie', 'Nicole',
    ],
  ),

  // VENEZUELA
  _SampleTeam(
    country: 'Venezuela',
    gender: 'male',
    surnames: <String>[
      'RODRIGUEZ', 'GONZALEZ', 'GARCIA', 'HERNANDEZ',
      'MARTINEZ', 'PEREZ', 'LOPEZ', 'SANCHEZ',
      'RAMIREZ', 'TORRES', 'DIAZ', 'REYES',
    ],
    firstNames: <String>[
      'Jose', 'Carlos', 'Luis', 'Manuel',
      'Eduardo', 'Hugo', 'Ricardo', 'Javier',
      'Alberto', 'Daniel', 'Pedro', 'Gabriel',
    ],
  ),
  _SampleTeam(
    country: 'Venezuela',
    gender: 'female',
    surnames: <String>[
      'BLANCO', 'DELGADO', 'MARQUEZ', 'CARDOZO',
      'PINTO', 'COLMENARES', 'GUEVARA', 'PAREDES',
      'SALAZAR', 'PEREIRA', 'VELEZ', 'MEDINA',
    ],
    firstNames: <String>[
      'Maria', 'Andrea', 'Patricia', 'Gabriela',
      'Daniela', 'Adriana', 'Yorgelis', 'Genesis',
      'Oriana', 'Wilmary', 'Karelis', 'Beatriz',
    ],
  ),
];
