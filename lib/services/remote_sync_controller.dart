import 'dart:async';

import 'package:flutter/foundation.dart';

import 'remote_spreadsheet_service.dart';
import 'spreadsheet_parser_service.dart';

/// Uma nova versão da planilha online, já baixada e parseada, ainda **não
/// aplicada** na UI. Quem consome decide quando aplicar (na tela de edição é
/// imediato; durante uma partida fica em espera até o usuário sair).
class RemoteUpdate {
  RemoteUpdate({required this.result, required this.contentHash});
  final SpreadsheetParseResult result;
  final String contentHash;
}

/// Sincroniza a planilha de uma fonte online (link), fazendo *polling* e
/// expondo a versão nova detectada para as telas reagirem.
///
/// Comportamento (pedido do usuário):
/// - Verifica periodicamente (e ao voltar do segundo plano) se a planilha do
///   link mudou; compara por hash de conteúdo.
/// - Quando muda, guarda como [pending] e notifica os ouvintes. **Não**
///   aplica sozinho — a tela de edição aplica na hora; a tela de partida
///   ignora e o app oferece "atualizar" ao sair da partida.
///
/// É um [ChangeNotifier]. Em produção há uma [instance] única compartilhada
/// pelas telas; nos testes injete uma instância própria (com fetcher fake).
class RemoteSyncController extends ChangeNotifier {
  RemoteSyncController({
    RemoteSpreadsheetService? remote,
    SpreadsheetParserService? parser,
    Duration pollInterval = const Duration(seconds: 15),
  })  : _remote = remote ?? RemoteSpreadsheetService(),
        _parser = parser ?? SpreadsheetParserService(),
        _pollInterval = pollInterval;

  /// Instância compartilhada usada por padrão pelas telas. Fica inativa
  /// (sem timer, sem rede) até alguém chamar [activate].
  static final RemoteSyncController instance = RemoteSyncController();

  final RemoteSpreadsheetService _remote;
  final SpreadsheetParserService _parser;
  final Duration _pollInterval;

  String? _sourceUrl;
  String? _appliedHash; // hash da versão mais recente já BAIXADA/conhecida
  RemoteUpdate? _pending;
  bool _checking = false;
  bool _paused = false;
  Object? _lastError;
  Timer? _timer;

  /// Quando `true`, há uma partida em andamento: o polling continua detectando
  /// mudanças (`pending`), mas a tela de edição NÃO as aplica — segura até o
  /// usuário sair do jogo (`LineupControlScreen` liga/desliga esta flag).
  bool matchInProgress = false;

  String? get sourceUrl => _sourceUrl;
  String? get appliedHash => _appliedHash;
  bool get isActive => _sourceUrl != null;
  bool get isChecking => _checking;
  Object? get lastError => _lastError;
  RemoteUpdate? get pending => _pending;
  bool get hasPendingUpdate => _pending != null;

  /// Liga a sincronização para [url], registrando o hash já aplicado
  /// (a versão que o usuário está vendo agora). Reinicia o timer de polling.
  void activate(String url, String appliedHash) {
    _sourceUrl = url;
    _appliedHash = appliedHash;
    _pending = null;
    _lastError = null;
    _restartTimer();
    notifyListeners();
  }

  /// Desliga a sincronização (ex.: o usuário carregou uma planilha local).
  void deactivate() {
    _sourceUrl = null;
    _appliedHash = null;
    _pending = null;
    _timer?.cancel();
    _timer = null;
    notifyListeners();
  }

  /// O consumidor aplicou [update] na UI: vira a versão conhecida e limpa o
  /// pending (se ainda for o mesmo).
  void markApplied(RemoteUpdate update) {
    _appliedHash = update.contentHash;
    if (_pending != null && _pending!.contentHash == update.contentHash) {
      _pending = null;
    }
    notifyListeners();
  }

  /// Descarta a atualização pendente sem aplicá-la, mas mantendo-a como
  /// "conhecida" para não reaparecer (o usuário optou por não atualizar).
  void dismissPending() {
    final RemoteUpdate? p = _pending;
    if (p != null) _appliedHash = p.contentHash;
    _pending = null;
    notifyListeners();
  }

  void onAppPaused() {
    _paused = true;
    _timer?.cancel();
    _timer = null;
  }

  void onAppResumed() {
    _paused = false;
    if (_sourceUrl != null) {
      _restartTimer();
      unawaited(checkNow());
    }
  }

  void _restartTimer() {
    _timer?.cancel();
    if (_sourceUrl == null || _paused) return;
    _timer = Timer.periodic(_pollInterval, (_) => unawaited(checkNow()));
  }

  /// Verifica agora se a planilha mudou. Se mudou, baixa, parseia, guarda em
  /// [pending] e notifica. Retorna `true` se encontrou versão nova. Falhas de
  /// rede são silenciosas (ficam em [lastError]); o polling segue tentando.
  Future<bool> checkNow() async {
    final String? url = _sourceUrl;
    if (url == null || _checking) return false;
    _checking = true;
    notifyListeners();
    try {
      final RemoteFetchResult fetched = await _remote.fetch(url);
      _lastError = null;
      if (fetched.contentHash == _appliedHash) return false;
      // Versão nova: parseia e oferece como pending.
      _appliedHash = fetched.contentHash;
      final SpreadsheetParseResult parsed = _parser.parseBytes(fetched.bytes);
      _pending =
          RemoteUpdate(result: parsed, contentHash: fetched.contentHash);
      notifyListeners();
      return true;
    } catch (e) {
      _lastError = e;
      return false;
    } finally {
      _checking = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
