// Renderização da tela inicial para gerar o print do manual do usuário.
//
// NÃO termina em `_test.dart` de propósito: o `flutter test` padrão (sem
// argumentos, usado no build-apk.yml) ignora este arquivo. Ele é executado
// SOMENTE pelo workflow manual `screenshot.yml` com:
//   flutter test --update-goldens test/screenshots/home_screenshot.dart
// que grava `test/screenshots/home.png` (o print real da Home v1.5.x, com o
// card "Load from Online Link"), publicado como artifact para entrar no
// manual `.docx`.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:iwbf_team_points_control/screens/load_spreadsheet_screen.dart';
import 'package:iwbf_team_points_control/services/cache_service.dart';
import 'package:iwbf_team_points_control/theme/iwbf_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('home screenshot (v1.5.x)', (WidgetTester tester) async {
    // Cache vazio: sem diálogo de restauração e sem rede.
    SharedPreferences.setMockInitialValues(<String, Object>{});

    // Viewport retrato, alto o suficiente para mostrar os 3 cards + rodapé
    // sem rolagem. DPR 3 para um print nítido.
    tester.view.physicalSize = const Size(1200, 2940);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: buildIwbfTheme(),
      home: LoadSpreadsheetScreen(cache: CacheService()),
    ));
    await tester.pumpAndSettle();

    await expectLater(
      find.byType(LoadSpreadsheetScreen),
      matchesGoldenFile('home.png'),
    );
  });
}
