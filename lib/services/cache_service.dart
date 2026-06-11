import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/match_state.dart';
import '../models/saved_roster.dart';

/// Persiste o estado da partida em `shared_preferences` para sobreviver
/// a bloqueio de tela, alternancia entre apps e encerramento do
/// processo pelo Android.
///
/// Dois conteudos sao persistidos:
/// - **match state** (`_matchStateKey`): as duas equipes em jogo + slots;
/// - **roster** (`_rosterKey`): a planilha INTEIRA (todas as equipes) da
///   ultima planilha usada — base da pergunta "restaurar planilha
///   anterior" na tela inicial.
///
/// O servico nao tenta sincronizar nada online: dados ficam apenas no
/// dispositivo e podem ser apagados pelo usuario via `clear()` ou pela
/// opcao "Load New Spreadsheet" no app.
class CacheService {
  CacheService({SharedPreferences? prefs}) : _injected = prefs;

  static const String _matchStateKey = 'iwbf.match_state.v1';
  static const String _rosterKey = 'iwbf.roster.v1';
  static const String _linkKey = 'iwbf.remote_link.v1';

  final SharedPreferences? _injected;

  Future<SharedPreferences> _prefs() async {
    final SharedPreferences? injected = _injected;
    if (injected != null) return injected;
    return SharedPreferences.getInstance();
  }

  Future<void> saveMatchState(MatchState state) async {
    final SharedPreferences prefs = await _prefs();
    final String encoded = jsonEncode(state.toJson());
    await prefs.setString(_matchStateKey, encoded);
  }

  Future<MatchState?> loadMatchState() async {
    final SharedPreferences prefs = await _prefs();
    final String? raw = prefs.getString(_matchStateKey);
    if (raw == null || raw.isEmpty) return null;
    try {
      final dynamic decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic>) return null;
      return MatchState.fromJson(decoded);
    } catch (_) {
      return null;
    }
  }

  Future<bool> hasMatchState() async {
    final SharedPreferences prefs = await _prefs();
    return prefs.containsKey(_matchStateKey);
  }

  /// Salva a planilha inteira (todas as equipes) como "ultima planilha
  /// usada". Sobrescreve qualquer roster anterior — o app puxa apenas a
  /// planilha mais recente.
  Future<void> saveRoster(SavedRoster roster) async {
    final SharedPreferences prefs = await _prefs();
    await prefs.setString(_rosterKey, jsonEncode(roster.toJson()));
  }

  Future<SavedRoster?> loadRoster() async {
    final SharedPreferences prefs = await _prefs();
    final String? raw = prefs.getString(_rosterKey);
    if (raw == null || raw.isEmpty) return null;
    try {
      final dynamic decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic>) return null;
      return SavedRoster.fromJson(decoded);
    } catch (_) {
      return null;
    }
  }

  Future<bool> hasRoster() async {
    final SharedPreferences prefs = await _prefs();
    final String? raw = prefs.getString(_rosterKey);
    return raw != null && raw.isNotEmpty;
  }

  Future<void> clearRoster() async {
    final SharedPreferences prefs = await _prefs();
    await prefs.remove(_rosterKey);
  }

  /// Guarda o ÚLTIMO link online carregado, para que o campo de link na tela
  /// inicial continue preenchido após fechar e reabrir o app.
  Future<void> saveLastLink(String url) async {
    final SharedPreferences prefs = await _prefs();
    await prefs.setString(_linkKey, url);
  }

  Future<String?> loadLastLink() async {
    final SharedPreferences prefs = await _prefs();
    final String? url = prefs.getString(_linkKey);
    return (url == null || url.isEmpty) ? null : url;
  }

  Future<void> clearLastLink() async {
    final SharedPreferences prefs = await _prefs();
    await prefs.remove(_linkKey);
  }

  /// Limpa TUDO (match state + roster + link). Usado por "Start from Scratch"
  /// e "Load New Spreadsheet" — ambos querem partir de uma tela limpa.
  Future<void> clear() async {
    final SharedPreferences prefs = await _prefs();
    await prefs.remove(_matchStateKey);
    await prefs.remove(_rosterKey);
    await prefs.remove(_linkKey);
  }
}
