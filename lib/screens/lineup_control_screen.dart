import 'dart:async';

import 'package:flutter/material.dart';

import '../constants/point_limits.dart';
import '../models/match_state.dart';
import '../models/player.dart';
import '../models/team.dart';
import '../services/cache_service.dart';
import '../services/vibration_service.dart';
import '../services/wakelock_controller.dart';
import '../theme/iwbf_theme.dart';
import '../widgets/iwbf_logo_header.dart';

/// Tela principal da partida.
///
/// Funções:
/// - Layout responsivo: tablet (>= 720dp) usa listas laterais + quadra
///   central; celular usa abas Team A / Court / Team B.
/// - Seleção/deseleção por toque, limite de 5 atletas, bloqueio do 6º.
/// - Soma automática das classes funcionais e alerta persistente acima
///   do limite.
/// - Vibração leve apenas no instante em que cruza o limite (uma vez
///   por equipe e por cruzamento, via `VibrationService` injetável).
/// - Botões: Clear Team A / Clear Team B / Clear All / Change Teams /
///   Load New Spreadsheet (com confirmação antes de sair).
/// - Wakelock ligado enquanto a tela estiver ativa.
/// - `CacheService` salva o `MatchState` a cada mudança relevante.
class LineupControlScreen extends StatefulWidget {
  const LineupControlScreen({
    super.key,
    required this.initialState,
    CacheService? cache,
    VibrationService? vibration,
    WakelockController? wakelock,
  })  : _cache = cache,
        _vibration = vibration,
        _wakelock = wakelock;

  final MatchState initialState;
  final CacheService? _cache;
  final VibrationService? _vibration;
  final WakelockController? _wakelock;

  @override
  State<LineupControlScreen> createState() => _LineupControlScreenState();
}

class _LineupControlScreenState extends State<LineupControlScreen> {
  static const double _tabletBreakpoint = 720;

  late MatchState _state;
  late final CacheService _cache;
  late final VibrationService _vibration;
  late final WakelockController _wakelock;

  bool _wasOverA = false;
  bool _wasOverB = false;

  @override
  void initState() {
    super.initState();
    _state = widget.initialState;
    _cache = widget._cache ?? CacheService();
    _vibration = widget._vibration ?? const VibrationService();
    _wakelock = widget._wakelock ?? const WakelockController();
    _wasOverA = _state.isTeamAOverLimit;
    _wasOverB = _state.isTeamBOverLimit;
    unawaited(_wakelock.enable());
    unawaited(_persist());
  }

  @override
  void dispose() {
    unawaited(_wakelock.disable());
    super.dispose();
  }

  Future<void> _persist() => _cache.saveMatchState(_state);

  void _onPlayerTap(Player player, _Side side) {
    final Set<String> bucket = side == _Side.a
        ? _state.selectedTeamAIds
        : _state.selectedTeamBIds;
    final bool wasSelected = bucket.contains(player.id);
    final bool nowSelected = _state.togglePlayer(player);
    if (!wasSelected && !nowSelected) {
      _showSnack(side == _Side.a
          ? 'Only 5 players can be selected for Team A.'
          : 'Only 5 players can be selected for Team B.');
      return;
    }
    setState(() {});
    _checkLimitCrossing();
    unawaited(_persist());
  }

  void _onPointLimitChanged(double next) {
    setState(() {
      _state.setPointLimit(next);
    });
    _checkLimitCrossing();
    unawaited(_persist());
  }

  void _checkLimitCrossing() {
    final bool isOverA = _state.isTeamAOverLimit;
    final bool isOverB = _state.isTeamBOverLimit;
    if (!_wasOverA && isOverA) unawaited(_vibration.shortBuzz());
    if (!_wasOverB && isOverB) unawaited(_vibration.shortBuzz());
    _wasOverA = isOverA;
    _wasOverB = isOverB;
  }

  void _clearTeamA() {
    setState(() => _state.clearTeamA());
    _checkLimitCrossing();
    unawaited(_persist());
  }

  void _clearTeamB() {
    setState(() => _state.clearTeamB());
    _checkLimitCrossing();
    unawaited(_persist());
  }

  void _clearAll() {
    setState(() => _state.clearAll());
    _checkLimitCrossing();
    unawaited(_persist());
  }

  Future<bool> _confirmLeave() async {
    final bool? answer = await showDialog<bool>(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          key: const Key('leave-match-dialog'),
          title: const Text('Are you sure you want to leave this match?'),
          content: const Text('Current selections may be lost.'),
          actions: <Widget>[
            TextButton(
              key: const Key('leave-stay-button'),
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('Stay'),
            ),
            FilledButton(
              key: const Key('leave-confirm-button'),
              onPressed: () => Navigator.of(ctx).pop(true),
              child: const Text('Leave'),
            ),
          ],
        );
      },
    );
    return answer ?? false;
  }

  Future<void> _onChangeTeams() async {
    final bool ok = await _confirmLeave();
    if (!mounted || !ok) return;
    Navigator.of(context).pop();
  }

  Future<void> _onLoadNewSpreadsheet() async {
    final bool ok = await _confirmLeave();
    if (!mounted || !ok) return;
    await _cache.clear();
    if (!mounted) return;
    Navigator.of(context).popUntil((Route<void> r) => r.isFirst);
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope<Object?>(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, Object? _) async {
        if (didPop) return;
        final NavigatorState navigator = Navigator.of(context);
        final bool ok = await _confirmLeave();
        if (!ok) return;
        navigator.pop();
      },
      child: Scaffold(
        appBar: AppBar(
          title: const IwbfAppBarTitle(text: 'Lineup Control'),
        ),
        body: SafeArea(
          child: Column(
            children: <Widget>[
              _Header(
                state: _state,
                onPointLimitChanged: _onPointLimitChanged,
              ),
              Expanded(
                child: LayoutBuilder(
                  builder: (BuildContext _, BoxConstraints c) {
                    if (c.maxWidth >= _tabletBreakpoint) {
                      return _TabletBody(
                        state: _state,
                        onPlayerTap: _onPlayerTap,
                      );
                    }
                    return _PhoneBody(
                      state: _state,
                      onPlayerTap: _onPlayerTap,
                    );
                  },
                ),
              ),
              _OperationalButtons(
                onClearTeamA: _clearTeamA,
                onClearTeamB: _clearTeamB,
                onClearAll: _clearAll,
                onChangeTeams: _onChangeTeams,
                onLoadNewSpreadsheet: _onLoadNewSpreadsheet,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

enum _Side { a, b }

typedef _PlayerTapCallback = void Function(Player player, _Side side);

class _Header extends StatelessWidget {
  const _Header({required this.state, required this.onPointLimitChanged});

  final MatchState state;
  final ValueChanged<double> onPointLimitChanged;

  @override
  Widget build(BuildContext context) {
    final TextStyle? titleStyle = Theme.of(context).textTheme.titleMedium;
    final String? compName = state.competitionName;
    return Material(
      color: IwbfColors.offWhiteElevated,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            if (compName != null && compName.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(compName, style: titleStyle),
              ),
            Text(
              '${state.teamA.displayName}  vs  ${state.teamB.displayName}',
              style: titleStyle,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Row(
              children: <Widget>[
                Expanded(
                  child: _ScoreCell(
                    label: 'Team A',
                    total: state.totalPointsTeamA,
                    limit: state.pointLimit,
                    isOver: state.isTeamAOverLimit,
                    keyName: 'score-team-a',
                  ),
                ),
                Expanded(
                  child: _ScoreCell(
                    label: 'Team B',
                    total: state.totalPointsTeamB,
                    limit: state.pointLimit,
                    isOver: state.isTeamBOverLimit,
                    keyName: 'score-team-b',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const Text('Point Limit:'),
                const SizedBox(width: 8),
                DropdownButton<double>(
                  key: const Key('lineup-point-limit-dropdown'),
                  value: state.pointLimit,
                  items: kAcceptedPointLimits
                      .map(
                        (double v) => DropdownMenuItem<double>(
                          value: v,
                          child: Text(v.toStringAsFixed(1)),
                        ),
                      )
                      .toList(),
                  onChanged: (double? next) {
                    if (next != null) onPointLimitChanged(next);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ScoreCell extends StatelessWidget {
  const _ScoreCell({
    required this.label,
    required this.total,
    required this.limit,
    required this.isOver,
    required this.keyName,
  });

  final String label;
  final double total;
  final double limit;
  final bool isOver;
  final String keyName;

  @override
  Widget build(BuildContext context) {
    final Color textColor =
        isOver ? IwbfColors.alertRed : IwbfColors.textPrimary;
    return Container(
      key: Key(keyName),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: isOver ? IwbfColors.alertRedSurface : Colors.transparent,
        border: Border.all(
          color: isOver ? IwbfColors.alertRed : Colors.black12,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: <Widget>[
          Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
          Text(
            '${total.toStringAsFixed(1)} / ${limit.toStringAsFixed(1)}',
            style: TextStyle(
              color: textColor,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          if (isOver)
            const Text(
              'Point limit exceeded.',
              style: TextStyle(
                color: IwbfColors.alertRed,
                fontWeight: FontWeight.bold,
              ),
            ),
        ],
      ),
    );
  }
}

class _TabletBody extends StatelessWidget {
  const _TabletBody({required this.state, required this.onPlayerTap});

  final MatchState state;
  final _PlayerTapCallback onPlayerTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Expanded(
          flex: 3,
          child: _TeamPlayerList(
            key: const Key('tablet-team-a-list'),
            team: state.teamA,
            selectedIds: state.selectedTeamAIds,
            onPlayerTap: (Player p) => onPlayerTap(p, _Side.a),
          ),
        ),
        Expanded(
          flex: 4,
          child: _CourtView(state: state),
        ),
        Expanded(
          flex: 3,
          child: _TeamPlayerList(
            key: const Key('tablet-team-b-list'),
            team: state.teamB,
            selectedIds: state.selectedTeamBIds,
            onPlayerTap: (Player p) => onPlayerTap(p, _Side.b),
          ),
        ),
      ],
    );
  }
}

class _PhoneBody extends StatelessWidget {
  const _PhoneBody({required this.state, required this.onPlayerTap});

  final MatchState state;
  final _PlayerTapCallback onPlayerTap;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Column(
        children: <Widget>[
          const TabBar(
            tabs: <Widget>[
              Tab(text: 'Team A'),
              Tab(text: 'Court'),
              Tab(text: 'Team B'),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: <Widget>[
                _TeamPlayerList(
                  key: const Key('phone-team-a-list'),
                  team: state.teamA,
                  selectedIds: state.selectedTeamAIds,
                  onPlayerTap: (Player p) => onPlayerTap(p, _Side.a),
                ),
                _CourtView(state: state),
                _TeamPlayerList(
                  key: const Key('phone-team-b-list'),
                  team: state.teamB,
                  selectedIds: state.selectedTeamBIds,
                  onPlayerTap: (Player p) => onPlayerTap(p, _Side.b),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TeamPlayerList extends StatelessWidget {
  const _TeamPlayerList({
    super.key,
    required this.team,
    required this.selectedIds,
    required this.onPlayerTap,
  });

  final Team team;
  final Set<String> selectedIds;
  final ValueChanged<Player> onPlayerTap;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(8),
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Text(
            team.displayName,
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
        ...team.players.map(
          (Player p) => _PlayerCard(
            player: p,
            selected: selectedIds.contains(p.id),
            onTap: () => onPlayerTap(p),
          ),
        ),
      ],
    );
  }
}

class _PlayerCard extends StatelessWidget {
  const _PlayerCard({
    required this.player,
    required this.selected,
    required this.onTap,
  });

  final Player player;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Material(
        color: selected ? cs.primaryContainer : Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(
            color: selected ? cs.primary : Colors.black12,
          ),
        ),
        child: InkWell(
          key: Key('player-card-${player.id}'),
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: <Widget>[
                CircleAvatar(
                  radius: 16,
                  child: Text(
                    '${player.shirtNumber}',
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    player.displayName,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  player.playerClass.toStringAsFixed(1),
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CourtView extends StatelessWidget {
  const _CourtView({required this.state});

  final MatchState state;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFE8C898),
        border: Border.all(color: Colors.brown.shade400),
        borderRadius: BorderRadius.circular(8),
      ),
      margin: const EdgeInsets.all(8),
      padding: const EdgeInsets.all(8),
      child: Column(
        children: <Widget>[
          Expanded(
            child: _CourtHalf(
              players: state.selectedTeamAPlayers,
              isTeamA: true,
              emptyHint: 'Tap players in Team A list',
            ),
          ),
          Container(height: 2, color: Colors.white),
          Expanded(
            child: _CourtHalf(
              players: state.selectedTeamBPlayers,
              isTeamA: false,
              emptyHint: 'Tap players in Team B list',
            ),
          ),
        ],
      ),
    );
  }
}

class _CourtHalf extends StatelessWidget {
  const _CourtHalf({
    required this.players,
    required this.isTeamA,
    required this.emptyHint,
  });

  final List<Player> players;
  final bool isTeamA;
  final String emptyHint;

  @override
  Widget build(BuildContext context) {
    if (players.isEmpty) {
      return Center(
        child: Text(
          emptyHint,
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.brown.shade700, fontSize: 12),
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.all(4),
      child: Wrap(
        alignment: WrapAlignment.center,
        spacing: 8,
        runSpacing: 8,
        children: players
            .map(
              (Player p) => _CourtPlayerChip(player: p, isTeamA: isTeamA),
            )
            .toList(),
      ),
    );
  }
}

class _CourtPlayerChip extends StatelessWidget {
  const _CourtPlayerChip({required this.player, required this.isTeamA});

  final Player player;
  final bool isTeamA;

  @override
  Widget build(BuildContext context) {
    final Color bg = isTeamA ? Colors.white : Colors.black87;
    final Color fg = isTeamA ? Colors.black87 : Colors.white;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        border: Border.all(color: Colors.brown.shade700),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(
            '#${player.shirtNumber}',
            style: TextStyle(
              color: fg,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
          Text(
            player.surname.toUpperCase(),
            style: TextStyle(color: fg, fontSize: 10),
          ),
          Text(
            player.playerClass.toStringAsFixed(1),
            style: TextStyle(color: fg, fontSize: 10),
          ),
        ],
      ),
    );
  }
}

class _OperationalButtons extends StatelessWidget {
  const _OperationalButtons({
    required this.onClearTeamA,
    required this.onClearTeamB,
    required this.onClearAll,
    required this.onChangeTeams,
    required this.onLoadNewSpreadsheet,
  });

  final VoidCallback onClearTeamA;
  final VoidCallback onClearTeamB;
  final VoidCallback onClearAll;
  final VoidCallback onChangeTeams;
  final VoidCallback onLoadNewSpreadsheet;

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 4,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Wrap(
            alignment: WrapAlignment.center,
            spacing: 8,
            runSpacing: 8,
            children: <Widget>[
              OutlinedButton(
                key: const Key('clear-team-a-button'),
                onPressed: onClearTeamA,
                child: const Text('Clear Team A'),
              ),
              OutlinedButton(
                key: const Key('clear-team-b-button'),
                onPressed: onClearTeamB,
                child: const Text('Clear Team B'),
              ),
              OutlinedButton(
                key: const Key('clear-all-button'),
                onPressed: onClearAll,
                child: const Text('Clear All'),
              ),
              OutlinedButton(
                key: const Key('change-teams-button'),
                onPressed: onChangeTeams,
                child: const Text('Change Teams'),
              ),
              OutlinedButton(
                key: const Key('load-new-spreadsheet-button'),
                onPressed: onLoadNewSpreadsheet,
                child: const Text('Load New Spreadsheet'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
