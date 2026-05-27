import 'dart:ui' show Color;

import '../constants/point_limits.dart';
import 'player.dart';
import 'team.dart';

/// Cores padrão de camisa, preservando o visual original (Team A clara,
/// Team B escura) quando o usuário não escolhe outra.
const Color kDefaultJerseyColorA = Color(0xFFFFFFFF);
const Color kDefaultJerseyColorB = Color(0xFF1F1B16);

/// Estado mutável de uma partida em andamento.
///
/// **Slots de seleção (Fase 5):** cada equipe tem [kMaxPlayersPerTeam]
/// posições fixas (slots). Cada slot guarda o `id` de um atleta ou `null`
/// quando está vazio.
///
/// - `togglePlayer` adiciona ao primeiro slot vazio quando o atleta entra,
///   ou libera o slot correspondente quando ele sai. Os outros slots não
///   se reorganizam — o slot vazio fica vazio até alguém entrar.
/// - Assim, o `_CourtView` posiciona cada slot numa coordenada fixa da
///   quadra, e o usuário sente que cada atleta "fica no lugar dele".
///
/// A API antiga (`selectedTeamAIds`, `selectedTeamAPlayers`) continua
/// disponível, derivada dos slots.
class MatchState {
  MatchState({
    required this.teamA,
    required this.teamB,
    double pointLimit = kDefaultPointLimit,
    List<String?>? teamASlots,
    List<String?>? teamBSlots,
    Set<String>? selectedTeamAIds,
    Set<String>? selectedTeamBIds,
    this.competitionName,
    Color? jerseyColorA,
    Color? jerseyColorB,
  })  : _pointLimit = pointLimit,
        jerseyColorA = jerseyColorA ?? kDefaultJerseyColorA,
        jerseyColorB = jerseyColorB ?? kDefaultJerseyColorB,
        _teamASlots =
            _initSlots(teamASlots, fallbackSet: selectedTeamAIds),
        _teamBSlots =
            _initSlots(teamBSlots, fallbackSet: selectedTeamBIds);

  static List<String?> _initSlots(
    List<String?>? slots, {
    Set<String>? fallbackSet,
  }) {
    final List<String?> result =
        List<String?>.filled(kMaxPlayersPerTeam, null, growable: false);
    if (slots != null) {
      for (int i = 0; i < slots.length && i < kMaxPlayersPerTeam; i++) {
        result[i] = slots[i];
      }
      return result;
    }
    if (fallbackSet != null) {
      int idx = 0;
      for (final String id in fallbackSet) {
        if (idx >= kMaxPlayersPerTeam) break;
        result[idx] = id;
        idx++;
      }
    }
    return result;
  }

  final Team teamA;
  final Team teamB;
  final String? competitionName;

  /// Cor da camisa de cada equipe (selecionada no setup; pinta os ícones
  /// de camisa na quadra e nas listas laterais).
  final Color jerseyColorA;
  final Color jerseyColorB;

  double _pointLimit;
  final List<String?> _teamASlots;
  final List<String?> _teamBSlots;

  double get pointLimit => _pointLimit;

  Set<String> get selectedTeamAIds => <String>{
        for (final String? id in _teamASlots)
          if (id != null) id,
      };

  Set<String> get selectedTeamBIds => <String>{
        for (final String? id in _teamBSlots)
          if (id != null) id,
      };

  /// Atletas selecionados na ordem de entrada em quadra (ordem dos slots).
  /// Slots vazios são omitidos.
  List<Player> get selectedTeamAPlayers => <Player>[
        for (final String? id in _teamASlots)
          if (id != null) _findPlayer(teamA, id),
      ];

  List<Player> get selectedTeamBPlayers => <Player>[
        for (final String? id in _teamBSlots)
          if (id != null) _findPlayer(teamB, id),
      ];

  /// Posições da quadra alinhadas aos 5 slots. Cada elemento é o atleta
  /// no slot ou `null` quando o slot está vazio. Usado pelo `_CourtView`
  /// para posicionar cada slot numa coordenada fixa.
  List<Player?> get teamASlotPlayers => <Player?>[
        for (final String? id in _teamASlots)
          id == null ? null : _findPlayer(teamA, id),
      ];

  List<Player?> get teamBSlotPlayers => <Player?>[
        for (final String? id in _teamBSlots)
          id == null ? null : _findPlayer(teamB, id),
      ];

  double get totalPointsTeamA => _sumClasses(selectedTeamAPlayers);
  double get totalPointsTeamB => _sumClasses(selectedTeamBPlayers);

  bool get isTeamAOverLimit => totalPointsTeamA > _pointLimit;
  bool get isTeamBOverLimit => totalPointsTeamB > _pointLimit;

  void setPointLimit(double value) {
    if (!isAcceptedPointLimit(value)) {
      throw ArgumentError('Point limit not allowed: $value');
    }
    _pointLimit = value;
  }

  /// Tenta selecionar [player] no primeiro slot vazio. Retorna `true`
  /// quando o atleta termina selecionado (inclusive se já estava).
  /// `false` quando não há slot livre.
  bool selectPlayer(Player player) {
    final List<String?> slots = _slotsFor(player);
    if (slots.contains(player.id)) return true;
    final int empty = slots.indexOf(null);
    if (empty == -1) return false;
    slots[empty] = player.id;
    return true;
  }

  /// Remove [player] da seleção. O slot que ele ocupava fica vazio (não
  /// recompacta os outros).
  void deselectPlayer(Player player) {
    final List<String?> slots = _slotsFor(player);
    final int idx = slots.indexOf(player.id);
    if (idx == -1) return;
    slots[idx] = null;
  }

  /// Alterna a seleção. Retorna `true` quando termina selecionado,
  /// `false` quando termina não selecionado ou quando não havia slot.
  bool togglePlayer(Player player) {
    final List<String?> slots = _slotsFor(player);
    final int existing = slots.indexOf(player.id);
    if (existing != -1) {
      slots[existing] = null;
      return false;
    }
    final int empty = slots.indexOf(null);
    if (empty == -1) return false;
    slots[empty] = player.id;
    return true;
  }

  void clearTeamA() {
    for (int i = 0; i < _teamASlots.length; i++) {
      _teamASlots[i] = null;
    }
  }

  void clearTeamB() {
    for (int i = 0; i < _teamBSlots.length; i++) {
      _teamBSlots[i] = null;
    }
  }

  void clearAll() {
    clearTeamA();
    clearTeamB();
  }

  List<String?> _slotsFor(Player player) {
    if (teamA.players.any((Player p) => p.id == player.id)) {
      return _teamASlots;
    }
    if (teamB.players.any((Player p) => p.id == player.id)) {
      return _teamBSlots;
    }
    throw ArgumentError(
        'Player ${player.id} does not belong to Team A or Team B');
  }

  static Player _findPlayer(Team team, String id) {
    return team.players.firstWhere(
      (Player p) => p.id == id,
      orElse: () => throw StateError(
          'Player $id not found in team ${team.teamName}'),
    );
  }

  double _sumClasses(List<Player> players) {
    double total = 0;
    for (final Player p in players) {
      total += p.playerClass;
    }
    return total;
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'competitionName': competitionName,
        'teamA': teamA.toJson(),
        'teamB': teamB.toJson(),
        'pointLimit': _pointLimit,
        'teamASlots': _teamASlots,
        'teamBSlots': _teamBSlots,
        'jerseyColorA': jerseyColorA.toARGB32(),
        'jerseyColorB': jerseyColorB.toARGB32(),
      };

  factory MatchState.fromJson(Map<String, dynamic> json) {
    return MatchState(
      teamA: Team.fromJson(json['teamA'] as Map<String, dynamic>),
      teamB: Team.fromJson(json['teamB'] as Map<String, dynamic>),
      pointLimit:
          (json['pointLimit'] as num?)?.toDouble() ?? kDefaultPointLimit,
      teamASlots: _readSlotsJson(json['teamASlots']),
      teamBSlots: _readSlotsJson(json['teamBSlots']),
      // Compat com caches antigos que ainda usavam `selectedTeamA/B` em set.
      selectedTeamAIds:
          ((json['selectedTeamA'] as List<dynamic>?) ?? const <dynamic>[])
              .cast<String>()
              .toSet(),
      selectedTeamBIds:
          ((json['selectedTeamB'] as List<dynamic>?) ?? const <dynamic>[])
              .cast<String>()
              .toSet(),
      competitionName: json['competitionName'] as String?,
      jerseyColorA: json['jerseyColorA'] != null
          ? Color(json['jerseyColorA'] as int)
          : null,
      jerseyColorB: json['jerseyColorB'] != null
          ? Color(json['jerseyColorB'] as int)
          : null,
    );
  }

  static List<String?>? _readSlotsJson(Object? raw) {
    if (raw is! List<dynamic>) return null;
    return raw.map((Object? v) => v as String?).toList(growable: false);
  }
}
