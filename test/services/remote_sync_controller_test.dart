import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:iwbf_team_points_control/services/remote_spreadsheet_service.dart';
import 'package:iwbf_team_points_control/services/remote_sync_controller.dart';

/// Bytes com assinatura `.xlsx` (PK) + um payload variável para gerar hashes
/// diferentes. O parser falha ao decodificar (não é um zip válido) e devolve
/// um resultado de erro — o suficiente para exercitar a máquina de estados do
/// controller (que apenas precisa de um `SpreadsheetParseResult` não nulo).
Uint8List _xlsxLike(String payload) {
  return Uint8List.fromList(<int>[0x50, 0x4B, 0x03, 0x04, ...payload.codeUnits]);
}

void main() {
  test('detecta versão nova e expõe como pending; markApplied limpa',
      () async {
    Uint8List bytes = _xlsxLike('v1');
    final RemoteSpreadsheetService remote =
        RemoteSpreadsheetService(fetcher: (String url) async => bytes);
    final RemoteSyncController controller = RemoteSyncController(
      remote: remote,
      pollInterval: const Duration(minutes: 10),
    );
    addTearDown(controller.dispose);

    final String v1Hash = RemoteSpreadsheetService.contentHashOf(bytes);
    controller.activate('https://example.com/file.xlsx', v1Hash);
    expect(controller.isActive, isTrue);
    expect(controller.sourceUrl, 'https://example.com/file.xlsx');
    expect(controller.hasPendingUpdate, isFalse);

    // Mesmo conteúdo → nenhuma atualização pendente.
    expect(await controller.checkNow(), isFalse);
    expect(controller.hasPendingUpdate, isFalse);

    // Conteúdo mudou → vira pending.
    bytes = _xlsxLike('v2-longer-payload');
    expect(await controller.checkNow(), isTrue);
    expect(controller.hasPendingUpdate, isTrue);

    // Aplicar limpa o pending e atualiza o hash conhecido.
    controller.markApplied(controller.pending!);
    expect(controller.hasPendingUpdate, isFalse);

    // Buscar de novo o MESMO conteúdo não re-dispara.
    expect(await controller.checkNow(), isFalse);
    expect(controller.hasPendingUpdate, isFalse);
  });

  test('deactivate desliga a sincronização', () async {
    final RemoteSpreadsheetService remote = RemoteSpreadsheetService(
        fetcher: (String url) async => _xlsxLike('x'));
    final RemoteSyncController controller =
        RemoteSyncController(remote: remote);
    addTearDown(controller.dispose);

    controller.activate('https://example.com/file.xlsx', 'h0');
    expect(controller.isActive, isTrue);

    controller.deactivate();
    expect(controller.isActive, isFalse);
    expect(controller.sourceUrl, isNull);
    // Sem fonte ativa, checkNow é no-op.
    expect(await controller.checkNow(), isFalse);
  });

  test('dismissPending descarta sem reaparecer', () async {
    Uint8List bytes = _xlsxLike('a');
    final RemoteSpreadsheetService remote =
        RemoteSpreadsheetService(fetcher: (String url) async => bytes);
    final RemoteSyncController controller = RemoteSyncController(
      remote: remote,
      pollInterval: const Duration(minutes: 10),
    );
    addTearDown(controller.dispose);

    controller.activate(
        'https://example.com/file.xlsx',
        RemoteSpreadsheetService.contentHashOf(bytes));

    bytes = _xlsxLike('b-changed');
    expect(await controller.checkNow(), isTrue);
    expect(controller.hasPendingUpdate, isTrue);

    controller.dismissPending();
    expect(controller.hasPendingUpdate, isFalse);
    // A mesma versão descartada não volta a aparecer.
    expect(await controller.checkNow(), isFalse);
    expect(controller.hasPendingUpdate, isFalse);
  });
}
