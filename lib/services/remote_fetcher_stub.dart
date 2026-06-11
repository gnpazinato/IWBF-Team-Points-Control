import 'dart:typed_data';

/// Fallback para plataformas sem `dart:io` nem `dart:html`. Nunca deve ser
/// alcançado em produção (Android usa o `_io`, Web usa o `_web`).
Future<Uint8List> fetchRemoteBytes(String url) {
  throw UnsupportedError(
      'Remote spreadsheet fetching is not supported on this platform.');
}
