import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'screens/load_spreadsheet_screen.dart';
import 'theme/iwbf_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  _applyOrientationPreference();
  runApp(const IwbfApp());
}

/// Tablets podem girar (portrait + landscape); celulares ficam travados em
/// portrait, onde os layouts de partida foram desenhados para caber bem.
/// Critério: menor lado lógico da tela (>= 600dp ≈ tablet).
void _applyOrientationPreference() {
  bool isTablet = false;
  final List<ui.FlutterView> views =
      WidgetsBinding.instance.platformDispatcher.views.toList();
  if (views.isNotEmpty) {
    final ui.FlutterView view = views.first;
    final double dpr =
        view.devicePixelRatio == 0 ? 1.0 : view.devicePixelRatio;
    final Size logical = view.physicalSize / dpr;
    if (logical.shortestSide >= 600) {
      isTablet = true;
    }
  }
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

class IwbfApp extends StatelessWidget {
  const IwbfApp({super.key});

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
