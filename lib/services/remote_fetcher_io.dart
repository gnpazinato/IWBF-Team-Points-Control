import 'dart:io';
import 'dart:typed_data';

/// Implementação nativa (Android/desktop) do download remoto.
///
/// Usa `HttpClient` do `dart:io` com **redirecionamento manual** para poder
/// repassar os cookies recebidos em cada salto. É isso que faz o link de
/// compartilhamento anônimo do SharePoint funcionar: o primeiro `302`
/// devolve um cookie `FedAuth` anônimo que precisa acompanhar a requisição
/// seguinte (sem ele a resposta vira `403`). Os pacotes `http`/`dio` não
/// preservam cookies entre redirects sem configuração extra; o `dart:io`
/// expõe `response.cookies`/`request.cookies` e resolve isso de forma limpa.
Future<Uint8List> fetchRemoteBytes(String url) async {
  final HttpClient client = HttpClient()
    ..userAgent = 'Mozilla/5.0 (IWBF Team Points Control)'
    ..connectionTimeout = const Duration(seconds: 25);
  try {
    final List<Cookie> jar = <Cookie>[];
    Uri current = Uri.parse(url);

    for (int hop = 0; hop < 10; hop++) {
      final HttpClientRequest request = await client.getUrl(current);
      // Seguimos os redirects nós mesmos para controlar os cookies.
      request.followRedirects = false;
      if (jar.isNotEmpty) {
        request.cookies.addAll(jar);
      }
      final HttpClientResponse response = await request.close();

      // Acumula/atualiza os cookies deste salto (último valor de cada nome).
      for (final Cookie cookie in response.cookies) {
        jar.removeWhere((Cookie c) => c.name == cookie.name);
        jar.add(cookie);
      }

      final int code = response.statusCode;
      final bool isRedirect = code == HttpStatus.movedPermanently ||
          code == HttpStatus.found ||
          code == HttpStatus.seeOther ||
          code == HttpStatus.temporaryRedirect ||
          code == HttpStatus.permanentRedirect;

      if (isRedirect) {
        final String? location =
            response.headers.value(HttpHeaders.locationHeader);
        await response.drain<void>();
        if (location == null || location.isEmpty) {
          throw const HttpException('Redirect without a Location header');
        }
        current = current.resolve(location);
        continue;
      }

      if (code == HttpStatus.ok) {
        final BytesBuilder builder = BytesBuilder(copy: false);
        await for (final List<int> chunk in response) {
          builder.add(chunk);
        }
        return builder.takeBytes();
      }

      await response.drain<void>();
      throw HttpException('HTTP $code while downloading the spreadsheet');
    }
    throw const HttpException('Too many redirects');
  } finally {
    client.close(force: true);
  }
}
