import 'dart:typed_data';

/// Stub usado quando nenhuma das libs especializadas (dart:io / dart:html)
/// está disponível. Em prática, o app só roda em Android (io) e Web (html),
/// então este caminho serve apenas como salvaguarda.
Future<String?> defaultSaveTemplate(String filename, Uint8List bytes) async {
  throw UnsupportedError(
    'defaultSaveTemplate is not implemented for this platform.',
  );
}
