// Renderiza a tela inicial para gerar o print do manual do usuário.
//
// NÃO termina em `_test.dart` de propósito: o `flutter test` padrão (sem
// argumentos, usado no build-apk.yml) ignora este arquivo. Executado SOMENTE
// pelo workflow `screenshot.yml`:
//   flutter test test/screenshots/home_screenshot.dart
// que grava `test/screenshots/home.png` (Home real v1.5.x, com o card
// "Load from Online Link") em 3x, publicado como artifact para o manual.
//
// Tudo isto (este arquivo, o workflow e a dev-dep golden_toolkit) é
// TEMPORÁRIO e removido antes do merge na main.
import 'dart:io';
import 'dart:typed_data';
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

/// Carrega um TTF sans-serif do sistema (CI Ubuntu) como família [family],
/// para o texto renderizar de verdade (o golden do flutter_test desenha
/// caixas pretas quando a fonte do estilo não está carregada — caso dos
/// rótulos de botão, cujo `textStyle` do tema não fixa família).
Future<String?> _loadDocFont() async {
  const String family = 'DocSans';
  const List<String> candidates = <String>[
    '/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf',
    '/usr/share/fonts/truetype/liberation/LiberationSans-Regular.ttf',
    '/usr/share/fonts/truetype/freefont/FreeSans.ttf',
  ];
  for (final String path in candidates) {
    final File f = File(path);
    if (f.existsSync()) {
      final Uint8List bytes = f.readAsBytesSync();
      final FontLoader loader = FontLoader(family)
        ..addFont(Future<ByteData>.value(ByteData.view(bytes.buffer)));
      await loader.load();
      return family;
    }
  }
  return null; // fallback: usa o que o loadAppFonts trouxe
}

ThemeData _screenshotTheme(String? family) {
  final ThemeData base = buildIwbfTheme();
  if (family == null) return base;
  ButtonStyle withFamily(ButtonStyle? s, FontWeight w) =>
      (s ?? const ButtonStyle()).copyWith(
        textStyle: WidgetStatePropertyAll<TextStyle>(
          TextStyle(fontFamily: family, fontWeight: w),
        ),
      );
  return base.copyWith(
    textTheme: base.textTheme.apply(fontFamily: family),
    primaryTextTheme: base.primaryTextTheme.apply(fontFamily: family),
    filledButtonTheme: FilledButtonThemeData(
      style: withFamily(base.filledButtonTheme.style, FontWeight.w700),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: withFamily(base.outlinedButtonTheme.style, FontWeight.w600),
    ),
  );
}

void main() {
  testWidgets('render Home v1.5.x', (WidgetTester tester) async {
    await loadAppFonts(); // MaterialIcons + fontes do manifesto
    final String? family = await _loadDocFont();

    SharedPreferences.setMockInitialValues(<String, Object>{});

    tester.view.physicalSize = const Size(400, 1000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final GlobalKey boundaryKey = GlobalKey();
    await tester.pumpWidget(RepaintBoundary(
      key: boundaryKey,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: _screenshotTheme(family),
        home: LoadSpreadsheetScreen(cache: CacheService()),
      ),
    ));
    await tester.pumpAndSettle();

    await tester.runAsync(() async {
      final BuildContext ctx =
          tester.element(find.byType(LoadSpreadsheetScreen));
      await precacheImage(const AssetImage(kIwbfLogoBlackAsset), ctx);
    });
    await tester.pumpAndSettle();

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
