import 'dart:js_interop';
import 'dart:typed_data';

import 'package:web/web.dart' as web;

/// Implementação Web do saver de templates.
///
/// Cria um `Blob` com os bytes e dispara o download pelo browser usando
/// `<a download>`. Chamada apenas quando `dart.library.html` está
/// disponível (Flutter Web).
Future<String?> defaultSaveTemplate(String filename, Uint8List bytes) async {
  final web.Blob blob = web.Blob(
    <JSAny>[bytes.toJS].toJS,
    web.BlobPropertyBag(
      type:
          'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
    ),
  );
  final String url = web.URL.createObjectURL(blob);
  final web.HTMLAnchorElement anchor = web.HTMLAnchorElement()
    ..href = url
    ..download = filename
    ..style.display = 'none';
  web.document.body?.appendChild(anchor);
  anchor.click();
  anchor.remove();
  web.URL.revokeObjectURL(url);
  // No browser, o caminho final fica a critério do diretório de Downloads
  // configurado pelo usuário — devolvemos só o nome sugerido.
  return 'Downloads/$filename';
}
