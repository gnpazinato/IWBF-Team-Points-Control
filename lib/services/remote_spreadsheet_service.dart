import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/foundation.dart' show kIsWeb;

import 'remote_fetcher.dart';

/// Assinatura do baixador de bytes (injetável nos testes).
typedef RemoteByteFetcher = Future<Uint8List> Function(String url);

/// Provedores de planilha online reconhecidos. Cada um precisa de uma
/// transformação de URL diferente para chegar ao download direto do `.xlsx`.
enum RemoteProvider {
  sharePoint,
  googleDrive,
  googleSheets,
  oneDrivePersonal,
  direct,
}

/// Erro amigável de busca remota (mensagem já pronta para exibir ao usuário).
class RemoteFetchException implements Exception {
  RemoteFetchException(this.message);
  final String message;
  @override
  String toString() => message;
}

/// Resultado de uma busca remota: os bytes do `.xlsx`, um hash de conteúdo
/// (para detectar mudanças entre verificações) e a URL/provedor resolvidos.
class RemoteFetchResult {
  RemoteFetchResult({
    required this.bytes,
    required this.contentHash,
    required this.normalizedUrl,
    required this.provider,
  });

  final Uint8List bytes;
  final String contentHash;
  final String normalizedUrl;
  final RemoteProvider provider;
}

/// Resolve links de compartilhamento (SharePoint/OneDrive/Google) para uma
/// URL de download direto e baixa os bytes do `.xlsx` em memória, prontos
/// para o `SpreadsheetParserService`.
///
/// **Plataforma:** só funciona no app nativo (Android). Na Web o navegador
/// bloqueia o download por CORS, então [fetch] lança [RemoteFetchException].
class RemoteSpreadsheetService {
  RemoteSpreadsheetService({RemoteByteFetcher? fetcher})
      : _fetch = fetcher ?? fetchRemoteBytes;

  final RemoteByteFetcher _fetch;

  /// Heurística rápida: parece uma URL http(s) válida?
  bool looksLikeSupportedLink(String raw) {
    final Uri? uri = Uri.tryParse(raw.trim());
    return uri != null &&
        (uri.isScheme('http') || uri.isScheme('https')) &&
        uri.host.isNotEmpty;
  }

  /// Converte um link de compartilhamento na URL de download direto + o
  /// provedor detectado. Idempotente: normalizar uma URL já normalizada
  /// devolve a mesma URL (importante para o polling, que renormaliza a cada
  /// verificação).
  ({String url, RemoteProvider provider}) normalize(String raw) {
    final String trimmed = raw.trim();
    final Uri? uri = Uri.tryParse(trimmed);
    if (uri == null || uri.host.isEmpty) {
      throw RemoteFetchException('Invalid link.');
    }
    final String host = uri.host.toLowerCase();

    // SharePoint / OneDrive corporativo: .../:x:/g/...  →  ?download=1
    // (substitui qualquer query existente, ex.: ?rtime=...). O token de
    // compartilhamento fica no PATH, então é preservado.
    if (host.endsWith('sharepoint.com')) {
      return (
        url: uri.replace(query: 'download=1').toString(),
        provider: RemoteProvider.sharePoint,
      );
    }

    // OneDrive pessoal: 1drv.ms (link curto) ou onedrive.live.com.
    // API anônima de shares: base64url da URL com prefixo `u!`.
    if (host == '1drv.ms' || host.endsWith('onedrive.live.com')) {
      final String token = _shareToken(trimmed);
      return (
        url: 'https://api.onedrive.com/v1.0/shares/u!$token/root/content',
        provider: RemoteProvider.oneDrivePersonal,
      );
    }

    // Google Sheets (documento nativo): exporta a versão atual como .xlsx —
    // ideal para auto-refresh, pois sempre devolve o conteúdo mais recente.
    if (host.endsWith('docs.google.com') &&
        uri.pathSegments.contains('spreadsheets')) {
      final String? id = _googleDocId(uri);
      if (id != null) {
        return (
          url: 'https://docs.google.com/spreadsheets/d/$id/export?format=xlsx',
          provider: RemoteProvider.googleSheets,
        );
      }
    }

    // Google Drive: arquivo .xlsx hospedado (file/d/{id} ou ?id={id}).
    if (host.endsWith('drive.google.com') ||
        host.endsWith('drive.usercontent.google.com')) {
      final String? id = _googleDriveId(uri);
      if (id != null) {
        return (
          url: 'https://drive.google.com/uc?export=download&id=$id',
          provider: RemoteProvider.googleDrive,
        );
      }
    }

    // Caso geral: já é um link direto para o arquivo.
    return (url: trimmed, provider: RemoteProvider.direct);
  }

  /// Baixa e valida a planilha. Lança [RemoteFetchException] com mensagem
  /// pronta para exibir em caso de falha (link inválido, offline, resposta
  /// que não é um `.xlsx`, plataforma Web, etc.).
  Future<RemoteFetchResult> fetch(String raw) async {
    if (kIsWeb) {
      throw RemoteFetchException(
          'Loading from an online link is only available in the Android app.');
    }
    final ({String url, RemoteProvider provider}) target = normalize(raw);

    Uint8List bytes;
    try {
      bytes = await _fetch(target.url);
    } on RemoteFetchException {
      rethrow;
    } catch (_) {
      throw RemoteFetchException(
          'Could not download the spreadsheet. Check the link and your '
          'internet connection.');
    }

    if (!_looksLikeXlsx(bytes)) {
      throw RemoteFetchException(
          'The link did not return a valid .xlsx file. Make sure the file is '
          'shared as "anyone with the link" and points to an .xlsx.');
    }

    return RemoteFetchResult(
      bytes: bytes,
      contentHash: contentHashOf(bytes),
      normalizedUrl: target.url,
      provider: target.provider,
    );
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  /// base64url (sem padding) da URL, prefixo `u!` exigido pela API de shares
  /// do OneDrive pessoal.
  String _shareToken(String url) {
    final String b64 = base64Encode(utf8.encode(url));
    return b64.replaceAll('=', '').replaceAll('/', '_').replaceAll('+', '-');
  }

  /// `.../spreadsheets/d/{id}/edit` → `{id}`.
  String? _googleDocId(Uri uri) {
    final List<String> seg = uri.pathSegments;
    final int i = seg.indexOf('d');
    if (i != -1 && i + 1 < seg.length) return seg[i + 1];
    return null;
  }

  /// `.../file/d/{id}/view`, `?id={id}` ou `/open?id={id}` → `{id}`.
  String? _googleDriveId(Uri uri) {
    final List<String> seg = uri.pathSegments;
    final int i = seg.indexOf('d');
    if (i != -1 && i + 1 < seg.length) return seg[i + 1];
    final String? q = uri.queryParameters['id'];
    if (q != null && q.isNotEmpty) return q;
    return null;
  }

  /// Assinatura ZIP local (`PK\x03\x04`) — todo `.xlsx` é um zip. Filtra
  /// páginas HTML de erro/login devolvidas quando o link não é público.
  static bool _looksLikeXlsx(Uint8List b) =>
      b.length >= 4 &&
      b[0] == 0x50 &&
      b[1] == 0x4B &&
      b[2] == 0x03 &&
      b[3] == 0x04;

  /// Hash de conteúdo (FNV-1a 32 bits + tamanho) para detectar mudanças
  /// entre verificações. Roda só no app nativo, onde `int` é 64 bits — o
  /// mascaramento mantém tudo dentro de 32 bits. Prefixar o tamanho reduz
  /// ainda mais a já ínfima chance de colisão.
  static String contentHashOf(Uint8List bytes) {
    int h = 0x811c9dc5;
    for (final int byte in bytes) {
      h = (h ^ byte) & 0xFFFFFFFF;
      h = (h * 0x01000193) & 0xFFFFFFFF;
    }
    return '${bytes.length}:${h.toRadixString(16)}';
  }
}
