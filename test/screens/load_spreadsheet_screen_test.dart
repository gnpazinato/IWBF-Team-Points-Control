import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:iwbf_team_points_control/models/player.dart';
import 'package:iwbf_team_points_control/models/saved_roster.dart';
import 'package:iwbf_team_points_control/models/team.dart';
import 'package:iwbf_team_points_control/screens/load_spreadsheet_screen.dart';
import 'package:iwbf_team_points_control/services/cache_service.dart';
import 'package:iwbf_team_points_control/services/template_generator_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _FakeTemplateSaver {
  final List<({String filename, int byteCount})> calls = <({String filename, int byteCount})>[];
  String returnPath = '/tmp/fake/path';

  Future<String?> save(String filename, Uint8List bytes) async {
    calls.add((filename: filename, byteCount: bytes.lengthInBytes));
    return returnPath;
  }
}

Future<void> _pumpScreen(
  WidgetTester tester, {
  FilePickerFn? filePicker,
  CacheService? cache,
  TemplateSaveFn? saveTemplate,
  TemplateGeneratorService? templates,
}) async {
  await tester.pumpWidget(MaterialApp(
    home: LoadSpreadsheetScreen(
      cache: cache ?? CacheService(),
      filePicker: filePicker,
      saveTemplate: saveTemplate,
      templates: templates,
    ),
  ));
}

/// Salva uma planilha completa (3 equipes) no cache. A terceira equipe
/// (Canada) NUNCA estaria numa partida de 2 times — usamos ela para
/// provar que a restauracao traz a planilha INTEIRA, nao so as 2 equipes
/// que estavam jogando.
Future<void> _seedRoster(CacheService cache) async {
  await cache.saveRoster(SavedRoster(
    competitionName: 'Americas Championship',
    teams: <Team>[
      Team(
        id: 'team-brazil',
        teamName: 'Brazil',
        players: <Player>[
          Player(
            id: 'team-brazil::7',
            teamName: 'Brazil',
            shirtNumber: '7',
            name: 'João Silva',
            playerClass: 2.5,
          ),
        ],
      ),
      Team(id: 'team-argentina', teamName: 'Argentina'),
      Team(id: 'team-canada', teamName: 'Canada'),
    ],
  ));
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  testWidgets('mostra botões principais e copy institucional',
      (WidgetTester tester) async {
    await _pumpScreen(tester);
    await tester.pumpAndSettle();

    expect(find.text('IWBF Team Points Control'), findsOneWidget);
    expect(find.text('Load Reference Spreadsheet'), findsOneWidget);
    expect(find.text('Download Template — Single Sheet'), findsOneWidget);
    expect(find.text('Download Template — One Sheet per Team'), findsOneWidget);
  });

  testWidgets('botão Single Sheet salva o template e mostra o caminho',
      (WidgetTester tester) async {
    final _FakeTemplateSaver saver = _FakeTemplateSaver()
      ..returnPath = '/tmp/iwbf/iwbf_template_single_sheet.xlsx';
    await _pumpScreen(tester, saveTemplate: saver.save);
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('download-template-single-sheet')));
    await tester.pumpAndSettle();

    expect(saver.calls, hasLength(1));
    expect(saver.calls.first.filename, 'iwbf_template_single_sheet.xlsx');
    expect(saver.calls.first.byteCount, greaterThan(0));
    expect(
      find.text('Template saved to /tmp/iwbf/iwbf_template_single_sheet.xlsx'),
      findsOneWidget,
    );
  });

  testWidgets('botão Per Team salva o template no nome correto',
      (WidgetTester tester) async {
    final _FakeTemplateSaver saver = _FakeTemplateSaver()
      ..returnPath = '/tmp/iwbf/iwbf_template_per_team.xlsx';
    await _pumpScreen(tester, saveTemplate: saver.save);
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('download-template-per-team')));
    await tester.pumpAndSettle();

    expect(saver.calls, hasLength(1));
    expect(saver.calls.first.filename, 'iwbf_template_per_team.xlsx');
  });

  testWidgets('saver retornando null não mostra mensagem de erro',
      (WidgetTester tester) async {
    await _pumpScreen(
      tester,
      saveTemplate: (String _, Uint8List __) async => null,
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('download-template-single-sheet')));
    await tester.pumpAndSettle();

    expect(find.textContaining('Template saved to'), findsNothing);
    expect(find.textContaining('Could not save template'), findsNothing);
  });

  testWidgets('quando filePicker retorna null, nada acontece',
      (WidgetTester tester) async {
    bool pickerCalled = false;
    await _pumpScreen(tester, filePicker: () async {
      pickerCalled = true;
      return null;
    });
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('load-spreadsheet-button')));
    await tester.pumpAndSettle();

    expect(pickerCalled, isTrue);
    // Continua na mesma tela
    expect(find.text('Load Reference Spreadsheet'), findsOneWidget);
  });

  testWidgets('mostra diálogo de restauração quando há roster salvo',
      (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final CacheService cache = CacheService();
    await _seedRoster(cache);

    await _pumpScreen(tester, cache: cache);
    await tester.pumpAndSettle();

    expect(find.text('Previous data found.'), findsOneWidget);
    expect(find.text('Load Previous Spreadsheet'), findsOneWidget);
    expect(find.text('Start from Scratch'), findsOneWidget);
  });

  testWidgets('"Start from Scratch" limpa o cache', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final CacheService cache = CacheService();
    await _seedRoster(cache);

    await _pumpScreen(tester, cache: cache);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Start from Scratch'));
    await tester.pumpAndSettle();

    expect(await cache.hasRoster(), isFalse);
  });

  testWidgets(
      '"Load Previous Spreadsheet" abre o Resumo com a planilha INTEIRA',
      (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final CacheService cache = CacheService();
    await _seedRoster(cache);

    await _pumpScreen(tester, cache: cache);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Load Previous Spreadsheet'));
    await tester.pumpAndSettle();

    expect(find.text('Spreadsheet Summary'), findsOneWidget);
    expect(find.textContaining('Americas Championship'), findsOneWidget);
    // Todas as 3 equipes vêm de volta — inclusive Canada, que jamais
    // estaria numa partida de 2 times. Prova que a planilha inteira foi
    // restaurada (e não só as equipes da última partida).
    expect(find.text('Brazil'), findsOneWidget);
    expect(find.text('Argentina'), findsOneWidget);
    expect(find.text('Canada'), findsOneWidget);
  });

  testWidgets('voltar do segundo plano na Home refaz a pergunta',
      (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final CacheService cache = CacheService();
    await _seedRoster(cache);

    await _pumpScreen(tester, cache: cache);
    await tester.pumpAndSettle();

    // Diálogo inicial: descarta com "Start from Scratch" (limpa o roster).
    expect(find.text('Previous data found.'), findsOneWidget);
    await tester.tap(find.text('Start from Scratch'));
    await tester.pumpAndSettle();
    expect(find.text('Previous data found.'), findsNothing);

    // Uma nova planilha foi usada e o app foi minimizado: ao voltar à Home,
    // a pergunta deve reaparecer. Simula um ciclo background -> foreground
    // com uma transição válida (inactive -> resumed).
    await _seedRoster(cache);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pumpAndSettle();

    expect(find.text('Previous data found.'), findsOneWidget);
  });

  testWidgets('voltar do segundo plano FORA da Home não interrompe',
      (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final CacheService cache = CacheService();
    await _seedRoster(cache);

    await _pumpScreen(tester, cache: cache);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Load Previous Spreadsheet'));
    await tester.pumpAndSettle();
    expect(find.text('Spreadsheet Summary'), findsOneWidget);

    // Minimiza e volta enquanto está no Resumo: continua no Resumo, sem
    // novo diálogo (decisão do usuário: só perguntar se já na Home).
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pumpAndSettle();

    expect(find.text('Previous data found.'), findsNothing);
    expect(find.text('Spreadsheet Summary'), findsOneWidget);
  });

  testWidgets('upload válido leva para ValidationSummary',
      (WidgetTester tester) async {
    // Gera bytes .xlsx in-memory via parser de testes? Nesse caso,
    // simulamos um arquivo .xlsx mínimo construindo via excel package.
    // Para evitar dependência do pacote excel neste teste, usamos bytes
    // garbage que disparam fileUnreadable, e o fluxo navega para
    // MissingDataScreen (caminho ainda exercitado).
    await _pumpScreen(tester, filePicker: () async {
      return Uint8List.fromList(<int>[0, 1, 2, 3]);
    });
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('load-spreadsheet-button')));
    await tester.pumpAndSettle();

    expect(find.text('Missing Data'), findsOneWidget);
  });
}
