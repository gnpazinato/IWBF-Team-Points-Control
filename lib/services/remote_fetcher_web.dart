import 'dart:typed_data';

/// Implementação Web — **não suportada**.
///
/// Um app Flutter Web (ex.: GitHub Pages) não consegue baixar arquivos do
/// SharePoint/OneDrive/Google Drive diretamente: esses serviços não enviam
/// cabeçalhos CORS, então o navegador bloqueia o `fetch`. O recurso de link
/// online existe apenas no app Android.
Future<Uint8List> fetchRemoteBytes(String url) async {
  throw UnsupportedError(
      'Loading from an online link is only available in the Android app.');
}
