import 'dart:typed_data';

import 'remote_fetcher_stub.dart'
    if (dart.library.io) 'remote_fetcher_io.dart'
    if (dart.library.html) 'remote_fetcher_web.dart' as impl;

/// Baixa os bytes de uma URL de download direto.
///
/// Segue redirecionamentos manualmente e **repassa os cookies** recebidos
/// em cada salto — necessário para links "anyone with the link" do
/// SharePoint/OneDrive corporativo, que emitem um cookie anônimo (`FedAuth`)
/// no primeiro `302` que precisa acompanhar a requisição seguinte (sem ele
/// o servidor responde `403`).
///
/// Disponível apenas no app nativo (Android/desktop). Na Web lança
/// [UnsupportedError]: não há como contornar o CORS de SharePoint/Drive a
/// partir do navegador sem um proxy próprio.
Future<Uint8List> fetchRemoteBytes(String url) => impl.fetchRemoteBytes(url);
