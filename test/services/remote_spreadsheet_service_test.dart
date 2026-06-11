import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:iwbf_team_points_control/services/remote_spreadsheet_service.dart';

void main() {
  group('RemoteSpreadsheetService.normalize', () {
    final RemoteSpreadsheetService service = RemoteSpreadsheetService();

    test('SharePoint/OneDrive corporativo → ?download=1 (token no path)', () {
      final ({String url, RemoteProvider provider}) r = service.normalize(
          'https://tenant-my.sharepoint.com/:x:/g/personal/u/IQ_TOKEN?rtime=abc');
      expect(r.provider, RemoteProvider.sharePoint);
      expect(
        r.url,
        'https://tenant-my.sharepoint.com/:x:/g/personal/u/IQ_TOKEN?download=1',
      );
    });

    test('SharePoint normalize é idempotente', () {
      final String once = service
          .normalize('https://t-my.sharepoint.com/:x:/g/p/u/TOK?rtime=abc')
          .url;
      final String twice = service.normalize(once).url;
      expect(twice, once);
    });

    test('Google Drive file/d/{id} → uc?export=download', () {
      final ({String url, RemoteProvider provider}) r = service
          .normalize('https://drive.google.com/file/d/ABC123/view?usp=sharing');
      expect(r.provider, RemoteProvider.googleDrive);
      expect(r.url, 'https://drive.google.com/uc?export=download&id=ABC123');
    });

    test('Google Drive ?id={id} também resolve', () {
      final ({String url, RemoteProvider provider}) r = service
          .normalize('https://drive.google.com/open?id=XYZ789');
      expect(r.provider, RemoteProvider.googleDrive);
      expect(r.url, 'https://drive.google.com/uc?export=download&id=XYZ789');
    });

    test('Google Sheets → export?format=xlsx (sempre a versão atual)', () {
      final ({String url, RemoteProvider provider}) r = service.normalize(
          'https://docs.google.com/spreadsheets/d/SHEET1/edit#gid=0');
      expect(r.provider, RemoteProvider.googleSheets);
      expect(
        r.url,
        'https://docs.google.com/spreadsheets/d/SHEET1/export?format=xlsx',
      );
    });

    test('OneDrive pessoal (1drv.ms) → shares API /root/content', () {
      final ({String url, RemoteProvider provider}) r =
          service.normalize('https://1drv.ms/x/s!AbCdEf');
      expect(r.provider, RemoteProvider.oneDrivePersonal);
      expect(r.url, startsWith('https://api.onedrive.com/v1.0/shares/u!'));
      expect(r.url, endsWith('/root/content'));
      // base64url: sem '/', '+' ou '=' no token.
      expect(r.url.contains('+'), isFalse);
    });

    test('link direto para .xlsx é usado como está', () {
      final ({String url, RemoteProvider provider}) r =
          service.normalize('https://example.com/path/file.xlsx');
      expect(r.provider, RemoteProvider.direct);
      expect(r.url, 'https://example.com/path/file.xlsx');
    });

    test('link sem host lança RemoteFetchException', () {
      expect(() => service.normalize('not a url'),
          throwsA(isA<RemoteFetchException>()));
    });
  });

  group('RemoteSpreadsheetService.fetch', () {
    test('bytes que não são .xlsx → erro amigável', () async {
      // "<!d..." (HTML de erro/login), sem assinatura PK.
      final RemoteSpreadsheetService service = RemoteSpreadsheetService(
        fetcher: (String url) async =>
            Uint8List.fromList(<int>[0x3C, 0x21, 0x64, 0x6F, 0x63]),
      );
      expect(
        () => service.fetch('https://example.com/x.xlsx'),
        throwsA(isA<RemoteFetchException>()),
      );
    });

    test('assinatura PK válida → devolve resultado com hash', () async {
      final Uint8List bytes =
          Uint8List.fromList(<int>[0x50, 0x4B, 0x03, 0x04, 1, 2, 3]);
      final RemoteSpreadsheetService service =
          RemoteSpreadsheetService(fetcher: (String url) async => bytes);
      final RemoteFetchResult r =
          await service.fetch('https://example.com/x.xlsx');
      expect(r.provider, RemoteProvider.direct);
      expect(r.contentHash, isNotEmpty);
      expect(r.bytes, equals(bytes));
    });

    test('contentHashOf muda quando o conteúdo muda', () {
      final String a = RemoteSpreadsheetService.contentHashOf(
          Uint8List.fromList(<int>[0x50, 0x4B, 0x03, 0x04, 1]));
      final String b = RemoteSpreadsheetService.contentHashOf(
          Uint8List.fromList(<int>[0x50, 0x4B, 0x03, 0x04, 2]));
      expect(a, isNot(equals(b)));
    });
  });
}
