import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'screens/load_spreadsheet_screen.dart';
import 'services/wakelock_controller.dart';
import 'theme/iwbf_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // Tela cheia (immersive): as barras de sistema somem e só reaparecem com
  // um swipe na borda, voltando a sumir sozinhas.
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  runApp(const IwbfApp());
}

class IwbfApp extends StatefulWidget {
  const IwbfApp({super.key});

  @override
  State<IwbfApp> createState() => _IwbfAppState();
}

class _IwbfAppState extends State<IwbfApp> with WidgetsBindingObserver {
  final WakelockController _wakelock = const WakelockController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Mantém a tela sempre acordada em todo o app (não inativa por
    // inatividade). O wakelock só é ligado — nunca desligado em uso.
    unawaited(_wakelock.enable());
    // A orientação só pode ser decidida com o tamanho REAL da tela, que só
    // existe depois do primeiro frame. Avaliar em main() (como antes) lia
    // tamanho zero e prendia o tablet em portrait — por isso o post-frame.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _enforceImmersiveAndWakelock();
      _applyOrientationPreference();
    });
  }

  @override
  void didChangeMetrics() {
    // Reavalia ao mudar de tamanho/orientação (ex.: tablet girando).
    _applyOrientationPreference();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Ao voltar do background, reafirma tela cheia + wakelock.
    if (state == AppLifecycleState.resumed) {
      _enforceImmersiveAndWakelock();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void _enforceImmersiveAndWakelock() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    unawaited(_wakelock.enable());
  }

  /// Tablets podem girar (portrait + landscape); celulares ficam travados em
  /// portrait, onde os layouts de partida foram desenhados para caber bem.
  /// Critério: menor lado lógico da tela (>= 600dp ≈ tablet). É reavaliado
  /// após o primeiro frame e a cada mudança de métricas — em `main()` o
  /// tamanho ainda não existe (era 0), o que prendia o tablet em portrait.
  void _applyOrientationPreference() {
    final List<ui.FlutterView> views =
        WidgetsBinding.instance.platformDispatcher.views.toList();
    if (views.isEmpty) return;
    final ui.FlutterView view = views.first;
    final double dpr =
        view.devicePixelRatio == 0 ? 1.0 : view.devicePixelRatio;
    final Size logical = view.physicalSize / dpr;
    if (logical.isEmpty) return; // tamanho ainda indisponível
    final bool isTablet = logical.shortestSide >= 600;
    SystemChrome.setPreferredOrientations(
      isTablet
          ? const <DeviceOrientation>[
              DeviceOrientation.portraitUp,
              DeviceOrientation.portraitDown,
              DeviceOrientation.landscapeLeft,
              DeviceOrientation.landscapeRight,
            ]
          : const <DeviceOrientation>[
              DeviceOrientation.portraitUp,
              DeviceOrientation.portraitDown,
            ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'IWBF Team Points Control',
      debugShowCheckedModeBanner: false,
      theme: buildIwbfTheme(),
      home: const LoadSpreadsheetScreen(),
    );
  }
}
