import 'dart:typed_data';

import 'template_saver_stub.dart'
    if (dart.library.io) 'template_saver_io.dart'
    if (dart.library.html) 'template_saver_web.dart' as impl;

/// Salva os bytes de um template `.xlsx` no destino apropriado para a
/// plataforma atual.
///
/// - Android/iOS/desktop: abre o diálogo "Save As" do sistema (SAF no
///   Android) e deixa o usuário escolher onde gravar. Devolve o caminho
///   final ou `null` se cancelar.
/// - Web: dispara download via `<a download>` no browser.
/// - Outras plataformas: lança `UnsupportedError`.
Future<String?> defaultSaveTemplate(String filename, Uint8List bytes) =>
    impl.defaultSaveTemplate(filename, bytes);
