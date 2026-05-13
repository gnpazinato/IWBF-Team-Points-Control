import '../constants/point_limits.dart';
import 'player.dart';
import 'team.dart';

/// Estado mutável de uma partida em andamento.
///
/// Mantém os IDs dos atletas selecionados para cada equipe e recalcula
/// a soma das classes funcionais sob demanda.
class MatchState {
  MatchState({
    required this.teamA,
    required this.teamB,
    double pointLimit = kDefaultPointLimit,
    Set<String>? selectedTeamAIds,
    Set<String>? selectedTeamBIds,
    this.competitionName,
  })  : _pointLimit = pointLimit,
        _selectedTeamA = <String>{...?selectedTeamAIds},
        _selectedTeamB = <String>{...?selectedTeamBIds};

  final Team teamA;
  final Team teamB;
  final String? competitionName;

  double _pointLimit;
  final Set<String> _selectedTeamA;
  final Set<String> _selectedTeamB;

  double get pointLimit => _pointLimit;

  Set<String> get selectedTeamAIds => Set<String>.unmodifiable(_selectedTeamA);
  Set<String> get selectedTeamBIds => Set<String>.unmodifiable(_selectedTeamB);

  List<Player> get selectedTeamAPlayers =>
      teamA.players.where((Player p) => _selectedTeamA.contains(p.id)).toList();

  List<Player> get selectedTeamBPlayers =>
      teamB.players.where((Player p) => _selectedTeamB.contains(p.id)).toList();

  double get totalPointsTeamA => _sumClasses(selectedTeamAPlayers);
  double get totalPointsTeamB => _sumClasses(selectedTeamBPlayers);

  bool get isTeamAOverLimit => totalPointsTeamA > _pointLimit;
  bool get isTeamBOverLimit => totalPointsTeamB > _pointLimit;

  void setPointLimit(double value) {
    if (!isAcceptedPointLimit(value)) {
      throw ArgumentError('Point limit não permitido: $value');
    }
    _pointLimit = value;
  }

  /// Tenta selecionar [player]. Retorna `false` se a equipe já tem
  /// [kMaxPlayersPerTeam] selecionados ou se o jogador não pertence
  /// à equipe informada.
  bool selectPlayer(Player player) {
    final Set<String> bucket = _bucketFor(player);
    if (bucket.contains(player.id)) return true;
    if (bucket.length >= kMaxPlayersPerTeam) return false;
    bucket.add(player.id);
    return true;
  }

  void deselectPlayer(Player player) {
    _bucketFor(player).remove(player.id);
  }

  /// Inverte o estado de seleção. Retorna `true` quando a operação
  /// resultar em atleta selecionado, `false` quando ficar desselecionado
  /// ou não couber.
  bool togglePlayer(Player player) {
    final Set<String> bucket = _bucketFor(player);
    if (bucket.contains(player.id)) {
      bucket.remove(player.id);
      return false;
    }
    if (bucket.length >= kMaxPlayersPerTeam) return false;
    bucket.add(player.id);
    return true;
  }

  void clearTeamA() => _selectedTeamA.clear();
  void clearTeamB() => _selectedTeamB.clear();
  void clearAll() {
    _selectedTeamA.clear();
    _selectedTeamB.clear();
  }

  Set<String> _bucketFor(Player player) {
    if (teamA.players.any((Player p) => p.id == player.id)) {
      return _selectedTeamA;
    }
    if (teamB.players.any((Player p) => p.id == player.id)) {
      return _selectedTeamB;
    }
    throw ArgumentError('Jogador ${player.id} não pertence a Team A nem Team B');
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
        'selectedTeamA': _selectedTeamA.toList(),
        'selectedTeamB': _selectedTeamB.toList(),
      };

  factory MatchState.fromJson(Map<String, dynamic> json) {
    return MatchState(
      teamA: Team.fromJson(json['teamA'] as Map<String, dynamic>),
      teamB: Team.fromJson(json['teamB'] as Map<String, dynamic>),
      pointLimit: (json['pointLimit'] as num?)?.toDouble() ?? kDefaultPointLimit,
      selectedTeamAIds: ((json['selectedTeamA'] as List<dynamic>?) ?? const <dynamic>[])
          .cast<String>()
          .toSet(),
      selectedTeamBIds: ((json['selectedTeamB'] as List<dynamic>?) ?? const <dynamic>[])
          .cast<String>()
          .toSet(),
      competitionName: json['competitionName'] as String?,
    );
  }
}
