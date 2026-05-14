import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:iwbf_team_points_control/models/match_state.dart';
import 'package:iwbf_team_points_control/models/player.dart';
import 'package:iwbf_team_points_control/models/team.dart';
import 'package:iwbf_team_points_control/screens/lineup_control_screen.dart';
import 'package:iwbf_team_points_control/services/cache_service.dart';
import 'package:iwbf_team_points_control/services/vibration_service.dart';
import 'package:iwbf_team_points_control/services/wakelock_controller.dart';

class _FakeCache extends CacheService {
  int saveCount = 0;
  int clearCount = 0;
  MatchState? lastSaved;

  @override
  Future<void> saveMatchState(MatchState state) async {
    saveCount++;
    lastSaved = state;
  }

  @override
  Future<void> clear() async {
    clearCount++;
  }
}

class _FakeVibration extends VibrationService {
  int callCount = 0;

  @override
  Future<void> shortBuzz() async {
    callCount++;
  }
}

class _FakeWakelock extends WakelockController {
  int enableCount = 0;
  int disableCount = 0;

  @override
  Future<void> enable() async {
    enableCount++;
  }

  @override
  Future<void> disable() async {
    disableCount++;
  }
}

Player _player(String teamId, int shirt, double cls, {String? surname}) =>
    Player(
      id: '$teamId::$shirt',
      teamName: teamId,
      shirtNumber: shirt,
      surname: surname ?? 'Surname$shirt',
      firstName: 'First',
      playerClass: cls,
    );

Team _teamA() => Team(
      id: 'team-brazil',
      teamName: 'Brazil',
      players: <Player>[
        _player('team-brazil', 1, 1.0),
        _player('team-brazil', 2, 2.0),
        _player('team-brazil', 3, 3.0),
        _player('team-brazil', 4, 4.0),
        _player('team-brazil', 5, 4.5),
        _player('team-brazil', 6, 3.5),
      ],
    );

Team _teamB() => Team(
      id: 'team-argentina',
      teamName: 'Argentina',
      players: <Player>[
        _player('team-argentina', 7, 1.5),
        _player('team-argentina', 8, 2.5),
        _player('team-argentina', 9, 3.0),
        _player('team-argentina', 10, 3.5),
        _player('team-argentina', 11, 4.0),
        _player('team-argentina', 12, 4.5),
      ],
    );

MatchState _freshState({double pointLimit = 14.0, String? competition}) =>
    MatchState(
      teamA: _teamA(),
      teamB: _teamB(),
      pointLimit: pointLimit,
      competitionName: competition,
    );

Future<void> _pump(
  WidgetTester tester,
  Widget child, {
  Size size = const Size(1200, 900),
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(() {
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });
  await tester.pumpWidget(MaterialApp(home: child));
  await tester.pumpAndSettle();
}

Future<void> _tapPlayer(WidgetTester tester, String teamId, int shirt) async {
  final Finder card = find.byKey(Key('player-card-$teamId::$shirt'));
  await tester.ensureVisible(card.first);
  await tester.tap(card.first);
  await tester.pumpAndSettle();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('LineupControlScreen — header', () {
    testWidgets('mostra competition, nomes das equipes e Point Limit',
        (WidgetTester tester) async {
      await _pump(
        tester,
        LineupControlScreen(
          initialState:
              _freshState(competition: 'Americas Championship'),
          cache: _FakeCache(),
          vibration: _FakeVibration(),
          wakelock: _FakeWakelock(),
        ),
      );

      expect(find.text('Americas Championship'), findsOneWidget);
      // Header agora monta Team A / vs / Team B em widgets separados para
      // intercalar a bandeira de cada pais.
      expect(find.text('Brazil'), findsWidgets);
      expect(find.text('Argentina'), findsWidgets);
      expect(find.text('  vs  '), findsOneWidget);
      expect(find.text('Team A'), findsWidgets);
      expect(find.text('Team B'), findsWidgets);
      expect(find.text('0.0 / 14.0'), findsNWidgets(2));
      expect(find.text('Point Limit:'), findsOneWidget);
    });

    testWidgets('mudar Point Limit no dropdown re-avalia alerta',
        (WidgetTester tester) async {
      final _FakeCache cache = _FakeCache();
      final _FakeVibration vibration = _FakeVibration();
      await _pump(
        tester,
        LineupControlScreen(
          initialState: _freshState(),
          cache: cache,
          vibration: vibration,
          wakelock: _FakeWakelock(),
        ),
      );

      await _tapPlayer(tester, 'team-brazil', 5); // 4.5
      await _tapPlayer(tester, 'team-brazil', 4); // 4.0
      await _tapPlayer(tester, 'team-brazil', 3); // 3.0
      await _tapPlayer(tester, 'team-brazil', 2); // 2.0 → 13.5

      expect(find.text('Point limit exceeded.'), findsNothing);

      await tester.tap(find.byKey(const Key('lineup-point-limit-dropdown')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('13.0').last);
      await tester.pumpAndSettle();

      expect(find.text('Point limit exceeded.'), findsOneWidget);
      expect(vibration.callCount, 1);
    });
  });

  group('LineupControlScreen — responsive layout', () {
    testWidgets('em tablet (>=720) mostra listas laterais',
        (WidgetTester tester) async {
      await _pump(
        tester,
        LineupControlScreen(
          initialState: _freshState(),
          cache: _FakeCache(),
          vibration: _FakeVibration(),
          wakelock: _FakeWakelock(),
        ),
      );

      expect(find.byKey(const Key('tablet-team-a-list')), findsOneWidget);
      expect(find.byKey(const Key('tablet-team-b-list')), findsOneWidget);
      expect(find.byType(TabBar), findsNothing);
    });

    testWidgets('em celular (<720) mostra abas Team A/Court/Team B',
        (WidgetTester tester) async {
      await _pump(
        tester,
        LineupControlScreen(
          initialState: _freshState(),
          cache: _FakeCache(),
          vibration: _FakeVibration(),
          wakelock: _FakeWakelock(),
        ),
        size: const Size(400, 800),
      );

      expect(find.byType(TabBar), findsOneWidget);
      expect(find.byKey(const Key('phone-team-a-list')), findsOneWidget);
      expect(find.text('Court'), findsOneWidget);
    });
  });

  group('LineupControlScreen — court', () {
    testWidgets('quadra renderiza com hints vazios para Team A e Team B',
        (WidgetTester tester) async {
      await _pump(
        tester,
        LineupControlScreen(
          initialState: _freshState(),
          cache: _FakeCache(),
          vibration: _FakeVibration(),
          wakelock: _FakeWakelock(),
        ),
      );

      expect(find.byKey(const Key('court-view')), findsOneWidget);
      expect(find.text('Tap players in Team A list'), findsOneWidget);
      expect(find.text('Tap players in Team B list'), findsOneWidget);
    });

    testWidgets('jogador selecionado aparece como chip na quadra',
        (WidgetTester tester) async {
      await _pump(
        tester,
        LineupControlScreen(
          initialState: _freshState(),
          cache: _FakeCache(),
          vibration: _FakeVibration(),
          wakelock: _FakeWakelock(),
        ),
      );

      await _tapPlayer(tester, 'team-brazil', 1);

      // O chip da quadra agora usa `PlayerJerseyIcon` + SURNAME (em caixa
      // alta) + classe. A lista lateral mostra "SURNAME1, First" — o
      // sobrenome puro "SURNAME1" só aparece no chip da quadra.
      expect(find.text('SURNAME1'), findsOneWidget);
      // Hint da Team A some quando há ao menos 1 jogador.
      expect(find.text('Tap players in Team A list'), findsNothing);
      // Hint da Team B continua, pois ela não tem ninguém selecionado.
      expect(find.text('Tap players in Team B list'), findsOneWidget);
    });
  });

  group('LineupControlScreen — selection', () {
    testWidgets('tap em jogador seleciona e atualiza score',
        (WidgetTester tester) async {
      final _FakeCache cache = _FakeCache();
      await _pump(
        tester,
        LineupControlScreen(
          initialState: _freshState(),
          cache: cache,
          vibration: _FakeVibration(),
          wakelock: _FakeWakelock(),
        ),
      );

      await _tapPlayer(tester, 'team-brazil', 1); // 1.0
      await _tapPlayer(tester, 'team-brazil', 2); // 2.0 → 3.0

      expect(find.text('3.0 / 14.0'), findsOneWidget);
      // saveMatchState chamada ao menos: init + 2 toggles = 3.
      expect(cache.saveCount, greaterThanOrEqualTo(3));
    });

    testWidgets('tap no mesmo jogador desseleciona',
        (WidgetTester tester) async {
      await _pump(
        tester,
        LineupControlScreen(
          initialState: _freshState(),
          cache: _FakeCache(),
          vibration: _FakeVibration(),
          wakelock: _FakeWakelock(),
        ),
      );

      await _tapPlayer(tester, 'team-brazil', 3); // 3.0
      expect(find.text('3.0 / 14.0'), findsOneWidget);

      await _tapPlayer(tester, 'team-brazil', 3); // -3.0 → 0.0
      expect(find.text('0.0 / 14.0'), findsNWidgets(2));
    });

    testWidgets(
        'permite até 5 jogadores; o 6º é bloqueado com snackbar e contagem fica em 5',
        (WidgetTester tester) async {
      await _pump(
        tester,
        LineupControlScreen(
          initialState: _freshState(),
          cache: _FakeCache(),
          vibration: _FakeVibration(),
          wakelock: _FakeWakelock(),
        ),
      );

      // Seleciona 5 jogadores em Team A: shirts 1, 2, 3, 4, 6 = 1+2+3+4+3.5 = 13.5
      await _tapPlayer(tester, 'team-brazil', 1);
      await _tapPlayer(tester, 'team-brazil', 2);
      await _tapPlayer(tester, 'team-brazil', 3);
      await _tapPlayer(tester, 'team-brazil', 4);
      await _tapPlayer(tester, 'team-brazil', 6);

      expect(find.text('13.5 / 14.0'), findsOneWidget);
      expect(find.text('Point limit exceeded.'), findsNothing);

      // Tenta selecionar o 6º (shirt 5 com 4.5): deve ser bloqueado.
      await _tapPlayer(tester, 'team-brazil', 5);

      expect(
        find.text('Only 5 players can be selected for Team A.'),
        findsOneWidget,
      );
      expect(find.text('13.5 / 14.0'), findsOneWidget);
    });
  });

  group('LineupControlScreen — over-limit alert + vibration', () {
    testWidgets('cruzar o limite mostra alerta e vibra exatamente uma vez',
        (WidgetTester tester) async {
      final _FakeVibration vibration = _FakeVibration();
      await _pump(
        tester,
        LineupControlScreen(
          initialState: _freshState(),
          cache: _FakeCache(),
          vibration: vibration,
          wakelock: _FakeWakelock(),
        ),
      );

      // Seleciona shirts 2, 3, 4, 5 (Team A) = 2+3+4+4.5 = 13.5 (under)
      await _tapPlayer(tester, 'team-brazil', 2);
      await _tapPlayer(tester, 'team-brazil', 3);
      await _tapPlayer(tester, 'team-brazil', 4);
      await _tapPlayer(tester, 'team-brazil', 5);

      expect(find.text('13.5 / 14.0'), findsOneWidget);
      expect(find.text('Point limit exceeded.'), findsNothing);
      expect(vibration.callCount, 0);

      // Adiciona shirt 1 (1.0) → 14.5 → cruza limite!
      await _tapPlayer(tester, 'team-brazil', 1);

      expect(find.text('14.5 / 14.0'), findsOneWidget);
      expect(find.text('Point limit exceeded.'), findsOneWidget);
      expect(vibration.callCount, 1);
    });

    testWidgets('voltar abaixo do limite remove o alerta sem vibrar de novo',
        (WidgetTester tester) async {
      final _FakeVibration vibration = _FakeVibration();
      await _pump(
        tester,
        LineupControlScreen(
          initialState: _freshState(),
          cache: _FakeCache(),
          vibration: vibration,
          wakelock: _FakeWakelock(),
        ),
      );

      // Cruza o limite: shirts 1+2+3+4+5 = 14.5
      for (final int shirt in <int>[1, 2, 3, 4, 5]) {
        await _tapPlayer(tester, 'team-brazil', shirt);
      }
      expect(find.text('Point limit exceeded.'), findsOneWidget);
      expect(vibration.callCount, 1);

      // Desseleciona shirt 1 → 13.5 → volta abaixo
      await _tapPlayer(tester, 'team-brazil', 1);
      expect(find.text('Point limit exceeded.'), findsNothing);
      expect(vibration.callCount, 1);

      // Cruza de novo (re-seleciona shirt 1) → vibra outra vez
      await _tapPlayer(tester, 'team-brazil', 1);
      expect(find.text('Point limit exceeded.'), findsOneWidget);
      expect(vibration.callCount, 2);
    });

    testWidgets('limite excedido afeta apenas a equipe envolvida',
        (WidgetTester tester) async {
      final _FakeVibration vibration = _FakeVibration();
      await _pump(
        tester,
        LineupControlScreen(
          initialState: _freshState(),
          cache: _FakeCache(),
          vibration: vibration,
          wakelock: _FakeWakelock(),
        ),
      );

      // Team B: shirts 9, 10, 11, 12 = 3+3.5+4+4.5 = 15.0 → over (limite 14)
      await _tapPlayer(tester, 'team-argentina', 9);
      await _tapPlayer(tester, 'team-argentina', 10);
      await _tapPlayer(tester, 'team-argentina', 11);
      await _tapPlayer(tester, 'team-argentina', 12);

      expect(find.text('15.0 / 14.0'), findsOneWidget);
      expect(find.text('Point limit exceeded.'), findsOneWidget);
      expect(vibration.callCount, 1);
      // Team A não ultrapassou; deve mostrar 0.0 / 14.0 sem alerta.
      expect(find.text('0.0 / 14.0'), findsOneWidget);
    });
  });

  group('LineupControlScreen — operational buttons', () {
    testWidgets('Clear Team A remove apenas as seleções de Team A',
        (WidgetTester tester) async {
      await _pump(
        tester,
        LineupControlScreen(
          initialState: _freshState(),
          cache: _FakeCache(),
          vibration: _FakeVibration(),
          wakelock: _FakeWakelock(),
        ),
      );

      await _tapPlayer(tester, 'team-brazil', 1); // 1.0
      await _tapPlayer(tester, 'team-brazil', 2); // 2.0 → A=3.0
      await _tapPlayer(tester, 'team-argentina', 11); // B=4.0

      expect(find.text('3.0 / 14.0'), findsOneWidget); // Team A
      expect(find.text('4.0 / 14.0'), findsOneWidget); // Team B

      await tester.tap(find.byKey(const Key('clear-team-a-button')));
      await tester.pumpAndSettle();

      expect(find.text('0.0 / 14.0'), findsOneWidget); // Team A zerado
      expect(find.text('4.0 / 14.0'), findsOneWidget); // Team B preservado
    });

    testWidgets('Clear Team B remove apenas Team B',
        (WidgetTester tester) async {
      await _pump(
        tester,
        LineupControlScreen(
          initialState: _freshState(),
          cache: _FakeCache(),
          vibration: _FakeVibration(),
          wakelock: _FakeWakelock(),
        ),
      );

      await _tapPlayer(tester, 'team-brazil', 4); // 4.0
      await _tapPlayer(tester, 'team-argentina', 9); // 3.0

      await tester.tap(find.byKey(const Key('clear-team-b-button')));
      await tester.pumpAndSettle();

      expect(find.text('4.0 / 14.0'), findsOneWidget);
      expect(find.text('0.0 / 14.0'), findsOneWidget);
    });

    testWidgets('Clear All zera as duas equipes',
        (WidgetTester tester) async {
      await _pump(
        tester,
        LineupControlScreen(
          initialState: _freshState(),
          cache: _FakeCache(),
          vibration: _FakeVibration(),
          wakelock: _FakeWakelock(),
        ),
      );

      await _tapPlayer(tester, 'team-brazil', 4);
      await _tapPlayer(tester, 'team-argentina', 9);

      await tester.tap(find.byKey(const Key('clear-all-button')));
      await tester.pumpAndSettle();

      expect(find.text('0.0 / 14.0'), findsNWidgets(2));
    });
  });

  group('LineupControlScreen — leaving the match', () {
    testWidgets('Change Teams pede confirmação e, ao confirmar, faz pop',
        (WidgetTester tester) async {
      final GlobalKey<NavigatorState> navKey = GlobalKey<NavigatorState>();
      tester.view.physicalSize = const Size(1200, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });
      await tester.pumpWidget(MaterialApp(
        navigatorKey: navKey,
        home: Scaffold(
          body: Builder(
            builder: (BuildContext ctx) => Center(
              child: ElevatedButton(
                onPressed: () => Navigator.of(ctx).push<void>(
                  MaterialPageRoute<void>(
                    builder: (_) => LineupControlScreen(
                      initialState: _freshState(),
                      cache: _FakeCache(),
                      vibration: _FakeVibration(),
                      wakelock: _FakeWakelock(),
                    ),
                  ),
                ),
                child: const Text('go'),
              ),
            ),
          ),
        ),
      ));
      await tester.tap(find.text('go'));
      await tester.pumpAndSettle();

      expect(find.text('Lineup Control'), findsOneWidget);

      await tester.tap(find.byKey(const Key('change-teams-button')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('leave-match-dialog')), findsOneWidget);

      // Cancela: continua na tela.
      await tester.tap(find.byKey(const Key('leave-stay-button')));
      await tester.pumpAndSettle();
      expect(find.text('Lineup Control'), findsOneWidget);

      // Confirma: pop acontece.
      await tester.tap(find.byKey(const Key('change-teams-button')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('leave-confirm-button')));
      await tester.pumpAndSettle();

      expect(find.text('Lineup Control'), findsNothing);
      expect(find.text('go'), findsOneWidget);
    });

    testWidgets(
        'Load New Spreadsheet confirma, limpa cache e popUntil para a raiz',
        (WidgetTester tester) async {
      final _FakeCache cache = _FakeCache();
      tester.view.physicalSize = const Size(1200, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      // Stack: root (go-intermediate) → intermediate (go-lineup) → Lineup.
      await tester.pumpWidget(MaterialApp(
        home: Builder(
          builder: (BuildContext rootCtx) => Scaffold(
            body: Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(rootCtx).push<void>(
                    MaterialPageRoute<void>(
                      builder: (_) => Scaffold(
                        body: Builder(
                          builder: (BuildContext midCtx) => Center(
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.of(midCtx).push<void>(
                                  MaterialPageRoute<void>(
                                    builder: (_) => LineupControlScreen(
                                      initialState: _freshState(),
                                      cache: cache,
                                      vibration: _FakeVibration(),
                                      wakelock: _FakeWakelock(),
                                    ),
                                  ),
                                );
                              },
                              child: const Text('go-lineup'),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
                child: const Text('go-intermediate'),
              ),
            ),
          ),
        ),
      ));

      await tester.tap(find.text('go-intermediate'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('go-lineup'));
      await tester.pumpAndSettle();

      expect(find.text('Lineup Control'), findsOneWidget);

      await tester.tap(find.byKey(const Key('load-new-spreadsheet-button')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('leave-confirm-button')));
      await tester.pumpAndSettle();

      expect(cache.clearCount, 1);
      expect(find.text('Lineup Control'), findsNothing);
      expect(find.text('go-lineup'), findsNothing);
      expect(find.text('go-intermediate'), findsOneWidget);
    });

    testWidgets('back do Android dispara confirmação via PopScope',
        (WidgetTester tester) async {
      final GlobalKey<NavigatorState> navKey = GlobalKey<NavigatorState>();
      tester.view.physicalSize = const Size(1200, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });
      await tester.pumpWidget(MaterialApp(
        navigatorKey: navKey,
        home: Scaffold(
          body: Builder(
            builder: (BuildContext ctx) => Center(
              child: ElevatedButton(
                onPressed: () => Navigator.of(ctx).push<void>(
                  MaterialPageRoute<void>(
                    builder: (_) => LineupControlScreen(
                      initialState: _freshState(),
                      cache: _FakeCache(),
                      vibration: _FakeVibration(),
                      wakelock: _FakeWakelock(),
                    ),
                  ),
                ),
                child: const Text('go'),
              ),
            ),
          ),
        ),
      ));
      await tester.tap(find.text('go'));
      await tester.pumpAndSettle();

      // Simula o botão Back do Android.
      navKey.currentState!.maybePop();
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('leave-match-dialog')), findsOneWidget);
    });
  });

  group('LineupControlScreen — wakelock + cache lifecycle', () {
    testWidgets('habilita wakelock no init e desabilita no dispose',
        (WidgetTester tester) async {
      final _FakeWakelock wakelock = _FakeWakelock();
      tester.view.physicalSize = const Size(1200, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(MaterialApp(
        home: LineupControlScreen(
          initialState: _freshState(),
          cache: _FakeCache(),
          vibration: _FakeVibration(),
          wakelock: wakelock,
        ),
      ));
      await tester.pumpAndSettle();

      expect(wakelock.enableCount, 1);
      expect(wakelock.disableCount, 0);

      // Substitui a árvore: dispose é chamado.
      await tester.pumpWidget(const MaterialApp(home: SizedBox.shrink()));
      await tester.pumpAndSettle();

      expect(wakelock.disableCount, 1);
    });

    testWidgets('persiste o estado no cache no init',
        (WidgetTester tester) async {
      final _FakeCache cache = _FakeCache();
      await _pump(
        tester,
        LineupControlScreen(
          initialState: _freshState(),
          cache: cache,
          vibration: _FakeVibration(),
          wakelock: _FakeWakelock(),
        ),
      );

      expect(cache.saveCount, greaterThanOrEqualTo(1));
      expect(cache.lastSaved, isNotNull);
    });
  });

  group('LineupControlScreen — responsive court chips (entrada 0031)', () {
    testWidgets(
        'chip da quadra cabe dentro do slot maximo em tablet portrait estreito',
        (WidgetTester tester) async {
      // Simula o caso reportado pelo usuario: tablet portrait estreito
      // onde a quadra fica com ~250dp de largura e os chips antigos
      // (size 36 hard-coded) se sobrepunham.
      await _pump(
        tester,
        LineupControlScreen(
          initialState: _freshState(),
          cache: _FakeCache(),
          vibration: _FakeVibration(),
          wakelock: _FakeWakelock(),
        ),
        size: const Size(720, 1280),
      );

      // Seleciona 5 jogadores da Team A para preencher todos os slots.
      for (int shirt in <int>[1, 2, 3, 4, 5]) {
        await _tapPlayer(tester, 'team-brazil', shirt);
      }

      // Os 5 surnames devem aparecer na quadra. FittedBox dentro do chip
      // garante que nomes longos encolham em vez de cortar.
      for (int shirt in <int>[1, 2, 3, 4, 5]) {
        expect(find.text('SURNAME$shirt'), findsOneWidget);
      }
    });

    testWidgets(
        'nomes longos no card lateral usam FittedBox (auto-shrink)',
        (WidgetTester tester) async {
      // Garante que o widget tree contem FittedBox dentro do card
      // lateral. Sem isso, nomes como "MACDONALD, Olivier" eram cortados
      // com ellipsis ao inves de encolherem.
      await _pump(
        tester,
        LineupControlScreen(
          initialState: _freshState(),
          cache: _FakeCache(),
          vibration: _FakeVibration(),
          wakelock: _FakeWakelock(),
        ),
      );

      final Finder card = find.byKey(const Key('player-card-team-brazil::1'));
      expect(card, findsOneWidget);
      // Procura um FittedBox como descendente do card — comprova o
      // mecanismo de auto-shrink instalado pela entrada 0031.
      expect(
        find.descendant(of: card, matching: find.byType(FittedBox)),
        findsWidgets,
      );
    });
  });
}
