// Renderiza a tela inicial para gerar o print do manual do usuário.
//
// NÃO termina em `_test.dart` de propósito: o `flutter test` padrão (sem
// argumentos, usado no build-apk.yml) ignora este arquivo. Executado SOMENTE
// pelo workflow `screenshot.yml` com:
//   flutter test test/screenshots/home_screenshot.dart
// que grava `test/screenshots/home.png` (Home real v1.5.x, com o card
// "Load from Online Link") em 3x, publicado como artifact para o manual.
//
// Tudo isto (este arquivo, o workflow e a dev-dep golden_toolkit) é
// TEMPORÁRIO e removido antes do merge na main.
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:iwbf_team_points_control/screens/load_spreadsheet_screen.dart';
import 'package:iwbf_team_points_control/services/cache_service.dart';
import 'package:iwbf_team_points_control/theme/iwbf_theme.dart';
import 'package:iwbf_team_points_control/widgets/iwbf_logo_header.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('render Home v1.5.x', (WidgetTester tester) async {
    // Carrega as fontes reais (MaterialIcons + texto) — sem isto o golden do
    // flutter_test desenha tudo como caixas pretas.
    await loadAppFonts();

    // Cache vazio: sem diálogo de restauração e sem rede.
    SharedPreferences.setMockInitialValues(<String, Object>{});

    // Retrato ~phone, alto o suficiente para os 3 cards + rodapé.
    tester.view.physicalSize = const Size(400, 1000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final GlobalKey boundaryKey = GlobalKey();
    await tester.pumpWidget(RepaintBoundary(
      key: boundaryKey,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: buildIwbfTheme(),
        home: LoadSpreadsheetScreen(cache: CacheService()),
      ),
    ));
    await tester.pumpAndSettle();

    // Garante a decodificação do logo (Image.asset) antes do print.
    await tester.runAsync(() async {
      final BuildContext ctx =
          tester.element(find.byType(LoadSpreadsheetScreen));
      await precacheImage(const AssetImage(kIwbfLogoBlackAsset), ctx);
    });
    await tester.pumpAndSettle();

    // Captura em 3x para um print nítido (1200×3000 px).
    await tester.runAsync(() async {
      final RenderRepaintBoundary boundary =
          tester.renderObject(find.byKey(boundaryKey));
      final ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      final ByteData? data =
          await image.toByteData(format: ui.ImageByteFormat.png);
      final Directory dir = Directory('test/screenshots');
      if (!dir.existsSync()) dir.createSync(recursive: true);
      File('${dir.path}/home.png')
          .writeAsBytesSync(data!.buffer.asUint8List());
    });
  });
}
