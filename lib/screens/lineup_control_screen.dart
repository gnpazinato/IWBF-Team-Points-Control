import 'dart:async';

import 'package:flutter/material.dart';

import '../constants/point_limits.dart';
import '../models/match_state.dart';
import '../models/player.dart';
import '../models/saved_roster.dart';
import '../models/team.dart';
import '../services/cache_service.dart';
import '../services/remote_sync_controller.dart';
import '../services/vibration_service.dart';
import '../services/wakelock_controller.dart';
import '../theme/iwbf_theme.dart';
import '../widgets/country_flag.dart';
import '../widgets/iwbf_logo_header.dart';
import '../widgets/player_jersey_icon.dart';
import 'validation_summary_screen.dart';

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
    RemoteSyncController? remoteSync,
  })  : _cache = cache,
        _vibration = vibration,
        _wakelock = wakelock,
        _remoteSync = remoteSync;

  final MatchState initialState;
  final CacheService? _cache;
  final VibrationService? _vibration;
  final WakelockController? _wakelock;
  final RemoteSyncController? _remoteSync;

  @override
  State<LineupControlScreen> createState() => _LineupControlScreenState();
}

class _LineupControlScreenState extends State<LineupControlScreen> {
  static const double _tabletBreakpoint = 720;

  late MatchState _state;
  late final CacheService _cache;
  late final VibrationService _vibration;
  late final WakelockController _wakelock;
  late final RemoteSyncController _remoteSync;

  bool _wasOverA = false;
  bool _wasOverB = false;

  @override
  void initState() {
    super.initState();
    _state = widget.initialState;
    _cache = widget._cache ?? CacheService();
    _vibration = widget._vibration ?? const VibrationService();
    _wakelock = widget._wakelock ?? const WakelockController();
    _remoteSync = widget._remoteSync ?? RemoteSyncController.instance;
    // Marca que uma partida está em andamento: enquanto isso, uma mudança na
    // planilha do link fica RETIDA (não é aplicada na tela de edição por
    // baixo) e só é oferecida quando o usuário sai do jogo.
    _remoteSync.matchInProgress = true;
    _wasOverA = _state.isTeamAOverLimit;
    _wasOverB = _state.isTeamBOverLimit;
    unawaited(_wakelock.enable());
    unawaited(_persist());
  }
  // O wakelock NÃO é desligado no dispose: a tela fica acordada em todo o
  // app (o `main` liga no início e reafirma no resume). Desligar aqui faria
  // a tela poder inativar ao sair da partida.

  @override
  void dispose() {
    // Fim da partida: libera a retenção de atualizações do link (a tela de
    // edição volta a aplicar mudanças em tempo real).
    _remoteSync.matchInProgress = false;
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
    await _leaveWithPossibleUpdate();
  }

  Future<void> _onLoadNewSpreadsheet() async {
    final bool ok = await _confirmLeave();
    if (!mounted || !ok) return;
    // "Load New Spreadsheet" parte do zero: desliga a sincronização do link
    // e limpa o cache antes de voltar à Home.
    _remoteSync.deactivate();
    await _cache.clear();
    if (!mounted) return;
    Navigator.of(context).popUntil((Route<void> r) => r.isFirst);
  }

  /// Ao SAIR da partida: se a planilha do link mudou enquanto o jogo
  /// acontecia (atualização ficou em espera), pergunta se o usuário quer
  /// atualizar os dados agora. Sim → recarrega o Resumo com a versão nova;
  /// não → mantém os dados atuais. Sem atualização pendente, sai normalmente.
  Future<void> _leaveWithPossibleUpdate() async {
    final NavigatorState navigator = Navigator.of(context);
    final RemoteUpdate? pending = _remoteSync.pending;
    if (pending == null) {
      navigator.pop();
      return;
    }
    final bool? apply = await _confirmApplyUpdate();
    if (!mounted) return;
    if (apply == true) {
      _remoteSync.markApplied(pending);
      await _cache.saveRoster(SavedRoster(
        teams: pending.result.teams,
        competitionName: pending.result.competitionName,
        sourceUrl: _remoteSync.sourceUrl,
        sourceHash: pending.contentHash,
      ));
      if (!mounted) return;
      navigator.popUntil((Route<void> r) => r.isFirst);
      navigator.push<void>(MaterialPageRoute<void>(
        builder: (_) => ValidationSummaryScreen(
          result: pending.result,
          cache: _cache,
          sourceUrl: _remoteSync.sourceUrl,
        ),
      ));
    } else {
      _remoteSync.dismissPending();
      navigator.pop();
    }
  }

  Future<bool?> _confirmApplyUpdate() {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext ctx) => AlertDialog(
        key: const Key('remote-update-dialog'),
        title: const Text('Spreadsheet updated'),
        content: const Text(
          'The online spreadsheet changed during the match. Update the data '
          'now (you will pick the teams again), or keep the current data?',
        ),
        actions: <Widget>[
          TextButton(
            key: const Key('remote-update-keep'),
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Keep current'),
          ),
          FilledButton(
            key: const Key('remote-update-apply'),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Update data'),
          ),
        ],
      ),
    );
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
        final bool ok = await _confirmLeave();
        if (!mounted || !ok) return;
        await _leaveWithPossibleUpdate();
      },
      child: Scaffold(
        appBar: AppBar(
          title: const IwbfAppBarTitle(text: 'Lineup Control'),
          actions: <Widget>[
            _PointLimitMenu(
              value: _state.pointLimit,
              onChanged: _onPointLimitChanged,
            ),
          ],
        ),
        body: SafeArea(
          child: Column(
            children: <Widget>[
              _Header(state: _state),
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
  const _Header({required this.state});

  final MatchState state;

  @override
  Widget build(BuildContext context) {
    final TextStyle teamStyle = Theme.of(context)
            .textTheme
            .titleSmall
            ?.copyWith(fontWeight: FontWeight.w700) ??
        const TextStyle(fontWeight: FontWeight.w700);
    final String? compName = state.competitionName;
    return Material(
      color: IwbfColors.offWhiteElevated,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 6, 8, 6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            if (compName != null && compName.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 2),
                child: Text(
                  compName,
                  style: teamStyle,
                  textAlign: TextAlign.center,
                ),
              ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                CountryFlag(rawName: state.teamA.teamName, size: 16),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    state.teamA.displayName,
                    style: teamStyle,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text('  vs  ', style: teamStyle),
                Flexible(
                  child: Text(
                    state.teamB.displayName,
                    style: teamStyle,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 4),
                CountryFlag(rawName: state.teamB.teamName, size: 16),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: <Widget>[
                Expanded(
                  child: _ScoreCell(
                    total: state.totalPointsTeamA,
                    limit: state.pointLimit,
                    isOver: state.isTeamAOverLimit,
                    keyName: 'score-team-a',
                  ),
                ),
                Expanded(
                  child: _ScoreCell(
                    total: state.totalPointsTeamB,
                    limit: state.pointLimit,
                    isOver: state.isTeamBOverLimit,
                    keyName: 'score-team-b',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Menu discreto na AppBar para ajustar o limite de pontos, liberando o
/// cabeçalho. O limite atual continua visível no denominador do placar.
class _PointLimitMenu extends StatelessWidget {
  const _PointLimitMenu({required this.value, required this.onChanged});

  final double value;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<double>(
      key: const Key('lineup-point-limit-dropdown'),
      tooltip: 'Point Limit',
      icon: const Icon(Icons.tune),
      initialValue: value,
      onSelected: onChanged,
      itemBuilder: (BuildContext context) => <PopupMenuEntry<double>>[
        const PopupMenuItem<double>(
          enabled: false,
          child: Text('Point Limit',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
        ),
        const PopupMenuDivider(),
        ...kAcceptedPointLimits.map(
          (double v) => PopupMenuItem<double>(
            value: v,
            child: Text(v.toStringAsFixed(1)),
          ),
        ),
      ],
    );
  }
}

class _ScoreCell extends StatelessWidget {
  const _ScoreCell({
    required this.total,
    required this.limit,
    required this.isOver,
    required this.keyName,
  });

  final double total;
  final double limit;
  final bool isOver;
  final String keyName;

  @override
  Widget build(BuildContext context) {
    final Color textColor =
        isOver ? IwbfColors.alertRed : IwbfColors.textPrimary;
    return AnimatedContainer(
      key: Key(keyName),
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: isOver ? IwbfColors.alertRedSurface : IwbfColors.cardWhite,
        border: Border.all(
          color: isOver ? IwbfColors.alertRed : IwbfColors.slate200,
          width: isOver ? 1.6 : 1,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: isOver
            ? <BoxShadow>[
                BoxShadow(
                  color: IwbfColors.alertRed.withValues(alpha: 0.35),
                  blurRadius: 12,
                  spreadRadius: 1,
                ),
              ]
            : const <BoxShadow>[
                BoxShadow(
                  color: Color(0x14000000),
                  blurRadius: 6,
                  offset: Offset(0, 2),
                ),
              ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              '${total.toStringAsFixed(1)} / ${limit.toStringAsFixed(1)}',
              style: TextStyle(
                color: textColor,
                fontSize: 24,
                fontWeight: FontWeight.w900,
                height: 1.05,
                fontFeatures: const <FontFeature>[
                  FontFeature.tabularFigures(),
                ],
              ),
            ),
          ),
          // Espaço fixo reservado pro alerta — mantém os dois boxes com a
          // mesma altura mesmo quando só um time estoura o limite.
          SizedBox(
            height: 14,
            child: isOver
                ? const Text(
                    'Point limit exceeded.',
                    style: TextStyle(
                      color: IwbfColors.alertRed,
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                    ),
                  )
                : null,
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
            isTeamA: true,
            selectedIds: state.selectedTeamAIds,
            onPlayerTap: (Player p) => onPlayerTap(p, _Side.a),
            jerseyColor: state.jerseyColorA,
          ),
        ),
        Expanded(
          flex: 4,
          child: _CourtView(state: state, onPlayerTap: onPlayerTap),
        ),
        Expanded(
          flex: 3,
          child: _TeamPlayerList(
            key: const Key('tablet-team-b-list'),
            team: state.teamB,
            isTeamA: false,
            selectedIds: state.selectedTeamBIds,
            onPlayerTap: (Player p) => onPlayerTap(p, _Side.b),
            jerseyColor: state.jerseyColorB,
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
                  isTeamA: true,
                  selectedIds: state.selectedTeamAIds,
                  onPlayerTap: (Player p) => onPlayerTap(p, _Side.a),
                  jerseyColor: state.jerseyColorA,
                ),
                _CourtView(state: state, onPlayerTap: onPlayerTap),
                _TeamPlayerList(
                  key: const Key('phone-team-b-list'),
                  team: state.teamB,
                  isTeamA: false,
                  selectedIds: state.selectedTeamBIds,
                  onPlayerTap: (Player p) => onPlayerTap(p, _Side.b),
                  jerseyColor: state.jerseyColorB,
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
    required this.isTeamA,
    required this.selectedIds,
    required this.onPlayerTap,
    required this.jerseyColor,
  });

  final Team team;
  final bool isTeamA;
  final Set<String> selectedIds;
  final ValueChanged<Player> onPlayerTap;
  final Color jerseyColor;

  @override
  Widget build(BuildContext context) {
    // Lista lateral ordenada por número da camiseta (em ordem crescente),
    // mesma ordem usada na Summary.
    final List<Player> sortedPlayers = <Player>[...team.players]
      ..sort((Player a, Player b) =>
          Player.compareShirtLabels(a.shirtNumber, b.shirtNumber));

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        // Reserva uma faixa para o header (bandeira + nome do país).
        const double headerHeight = 28;
        final double listHeight = constraints.maxHeight - headerHeight;
        // Para garantir que TODOS os atletas caibam, dividimos a altura
        // disponível pelo número de atletas — com piso/teto razoáveis.
        // Se o time tem 12 atletas e a faixa é grande, cada card fica
        // confortável; se o time tem 6, os cards ficam ainda maiores.
        final int playerCount = sortedPlayers.length;
        final double rawSlotHeight = playerCount > 0
            ? listHeight / playerCount
            : 0;
        // Bordas: nunca menos que 28dp (toque mínimo) nem mais que 56dp
        // (perde elegância em times pequenos).
        final double slotHeight = rawSlotHeight.clamp(28.0, 56.0);

        return Column(
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            SizedBox(
              height: headerHeight,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    CountryFlag(rawName: team.teamName, size: 16),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        team.displayName,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                itemCount: sortedPlayers.length,
                itemExtent: slotHeight,
                itemBuilder: (BuildContext _, int i) {
                  final Player p = sortedPlayers[i];
                  return _PlayerCard(
                    player: p,
                    isTeamA: isTeamA,
                    selected: selectedIds.contains(p.id),
                    height: slotHeight,
                    onTap: () => onPlayerTap(p),
                    jerseyColor: jerseyColor,
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}

class _PlayerCard extends StatelessWidget {
  const _PlayerCard({
    required this.player,
    required this.isTeamA,
    required this.selected,
    required this.height,
    required this.onTap,
    required this.jerseyColor,
  });

  final Player player;
  final bool isTeamA;
  final bool selected;
  final double height;
  final VoidCallback onTap;
  final Color jerseyColor;

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    // Tamanhos derivados da altura disponível para o slot, mantendo
    // proporções legíveis em qualquer tamanho.
    final double iconSize = (height * 0.78).clamp(22.0, 44.0);
    final double fontSize = (height * 0.32).clamp(11.0, 14.0);
    final double verticalPadding = (height * 0.08).clamp(2.0, 6.0);
    return Padding(
      padding: EdgeInsets.symmetric(vertical: verticalPadding * 0.4),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        curve: Curves.easeOut,
        decoration: BoxDecoration(
          color: selected ? cs.primaryContainer : IwbfColors.cardWhite,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: selected ? IwbfColors.gold : IwbfColors.slate200,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            key: Key('player-card-${player.id}'),
            onTap: onTap,
            borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: 6,
              vertical: verticalPadding,
            ),
            child: Row(
              children: <Widget>[
                PlayerJerseyIcon(
                  player: player,
                  isTeamA: isTeamA,
                  size: iconSize,
                  jerseyColor: jerseyColor,
                ),
                const SizedBox(width: 6),
                // _AutoShrinkText mede o texto com TextPainter e reduz
                // o fontSize proporcionalmente à largura disponível,
                // até o piso `minFontSize`. Mais confiável que
                // FittedBox/ellipsis dentro de Expanded — nomes longos
                // como "MACDONALD, Olivier" aparecem inteiros encolhidos.
                Expanded(
                  child: _AutoShrinkText(
                    text: player.displayName,
                    maxFontSize: fontSize,
                    // 7dp ainda é legível em tablet; permite que
                    // "MACDONALD, Olivier" / "WILLIAMS, Benjamin"
                    // caibam encolhidos sem cair em ellipsis quando
                    // ainda há espaço.
                    minFontSize: 7.0,
                    textAlign: TextAlign.left,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  player.playerClass.toStringAsFixed(1),
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: fontSize,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
    );
  }
}

/// Asset da quadra (orientação landscape original 2816x1504).
///
/// É exibida rotacionada 90° para o app, que opera em retrato.
const String kCourtAsset = 'assets/images/court.png';

/// Vista aérea simplificada da quadra com posicionamento simétrico
/// dos cinco jogadores selecionados em cada metade.
///
/// O asset `court.png` é landscape (2816x1504). Como o app é portrait,
/// rotacionamos 90° via `RotatedBox` para enxergar a quadra na vertical
/// (Team A na metade superior, Team B na inferior).
class _CourtView extends StatelessWidget {
  const _CourtView({required this.state, required this.onPlayerTap});

  final MatchState state;

  /// Mesmo callback das listas laterais: tocar um chip em quadra remove o
  /// jogador (togglePlayer já estava selecionado → sai da seleção).
  final _PlayerTapCallback onPlayerTap;

  /// Aspect ratio da quadra pós-rotação (1504/2816 ≈ 0.534, portrait).
  static const double _aspectRatio = 1504 / 2816;

  /// Posições fracionárias (x, y) para os 5 jogadores da Team A na metade
  /// superior (y < 0.5). Convenção: 2 perto da tabela, 2 mais à frente,
  /// 1 perto do meio-campo (point guard). Espaçamento vertical entre
  /// fileiras é 0.18 (linha 1 → linha 2) e 0.16 (linha 2 → centro), com
  /// o ponto guardado a 0.42 — gap suficiente para chips com altura
  /// até ≈ 0.13 * h sem encostarem mesmo em tablets portrait estreitos.
  static const List<Offset> _teamATargets = <Offset>[
    Offset(0.28, 0.08),
    Offset(0.72, 0.08),
    Offset(0.28, 0.26),
    Offset(0.72, 0.26),
    Offset(0.50, 0.42),
  ];

  /// Espelho simétrico da Team A para a metade inferior. O point guard
  /// da Team B fica a 0.58, dando gap 0.16 entre os dois centros — ainda
  /// acomoda chips de 0.13 * h sem encostarem.
  static const List<Offset> _teamBTargets = <Offset>[
    Offset(0.28, 0.92),
    Offset(0.72, 0.92),
    Offset(0.28, 0.74),
    Offset(0.72, 0.74),
    Offset(0.50, 0.58),
  ];

  @override
  Widget build(BuildContext context) {
    // Posições alinhadas ao slot do `MatchState`: o slot 0 sempre cai
    // na coordenada _teamATargets[0], slot 1 em [1], etc. Slots vazios
    // (null) deixam o lugar em branco em quadra — quando um jogador
    // sai, a posição dele fica vazia até alguém entrar no slot.
    final List<Player?> teamA = state.teamASlotPlayers;
    final List<Player?> teamB = state.teamBSlotPlayers;
    final bool teamAEmpty = teamA.every((Player? p) => p == null);
    final bool teamBEmpty = teamB.every((Player? p) => p == null);

    return Center(
      key: const Key('court-view'),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: AspectRatio(
          aspectRatio: _aspectRatio,
          child: Container(
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: IwbfColors.slate200),
              boxShadow: const <BoxShadow>[
                BoxShadow(
                  color: Color(0x14000000),
                  blurRadius: 10,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: LayoutBuilder(
              builder: (BuildContext _, BoxConstraints c) {
                final double w = c.maxWidth;
                final double h = c.maxHeight;
                // Passo horizontal entre os slots laterais (0.28 e
                // 0.72) é 0.44 * w — reservamos 0.34 * w para o chip
                // e 0.10 * w de gap. Passo vertical mais apertado é
                // 0.16 * h (linha 2 → centro). Reservamos 0.12 * h
                // para o chip e 0.04 * h de gap. Os clamps cobrem
                // limites razoáveis: viewports muito pequenos ainda
                // têm chip legível (>=46dp); telas grandes não criam
                // chip gigante (<=110dp). Como TODOS os chips usam
                // EXATAMENTE estas dimensões via SizedBox, ficam com
                // tamanho idêntico.
                final double slotMaxWidth = (w * 0.34).clamp(60.0, 150.0);
                final double slotMaxHeight = (h * 0.12).clamp(46.0, 110.0);
                return Stack(
                  alignment: Alignment.center,
                  children: <Widget>[
                    const Positioned.fill(
                      child: RotatedBox(
                        quarterTurns: 1,
                        child: Image(
                          image: AssetImage(kCourtAsset),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    if (teamAEmpty)
                      const Align(
                        alignment: Alignment(0, -0.55),
                        child: _CourtHint(text: 'Tap players in Team A list'),
                      ),
                    if (teamBEmpty)
                      const Align(
                        alignment: Alignment(0, 0.55),
                        child: _CourtHint(text: 'Tap players in Team B list'),
                      ),
                    for (int i = 0; i < 5; i++)
                      if (teamA[i] != null)
                        _CourtPlayerSlot(
                          player: teamA[i]!,
                          isTeamA: true,
                          target: _teamATargets[i],
                          width: w,
                          height: h,
                          slotMaxWidth: slotMaxWidth,
                          slotMaxHeight: slotMaxHeight,
                          jerseyColor: state.jerseyColorA,
                          onTap: () => onPlayerTap(teamA[i]!, _Side.a),
                        ),
                    for (int i = 0; i < 5; i++)
                      if (teamB[i] != null)
                        _CourtPlayerSlot(
                          player: teamB[i]!,
                          isTeamA: false,
                          target: _teamBTargets[i],
                          width: w,
                          height: h,
                          slotMaxWidth: slotMaxWidth,
                          slotMaxHeight: slotMaxHeight,
                          jerseyColor: state.jerseyColorB,
                          onTap: () => onPlayerTap(teamB[i]!, _Side.b),
                        ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _CourtHint extends StatelessWidget {
  const _CourtHint({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: IwbfColors.textPrimary,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _CourtPlayerSlot extends StatelessWidget {
  const _CourtPlayerSlot({
    required this.player,
    required this.isTeamA,
    required this.target,
    required this.width,
    required this.height,
    required this.slotMaxWidth,
    required this.slotMaxHeight,
    required this.jerseyColor,
    required this.onTap,
  });

  final Player player;
  final bool isTeamA;
  final Offset target;
  final double width;
  final double height;
  final double slotMaxWidth;
  final double slotMaxHeight;
  final Color jerseyColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: width * target.dx,
      top: height * target.dy,
      child: FractionalTranslation(
        translation: const Offset(-0.5, -0.5),
        child: _CourtPlayerChip(
          player: player,
          isTeamA: isTeamA,
          maxWidth: slotMaxWidth,
          maxHeight: slotMaxHeight,
          jerseyColor: jerseyColor,
          onTap: onTap,
        ),
      ),
    );
  }
}

/// Nome curto exibido no chip da quadra: apenas a parte antes da vírgula.
/// As planilhas vêm no formato "SOBRENOME, Nome" (ex.: "LOPEZ, Alvarez"),
/// então o chip mostra só "LOPEZ" — sem a vírgula, para ocupar pouco espaço.
/// Sem vírgula, usa o nome inteiro. As relações laterais mantêm o nome
/// completo (com a vírgula).
String _courtChipName(String name) {
  final int comma = name.indexOf(',');
  final String base = comma >= 0 ? name.substring(0, comma) : name;
  return base.trim();
}

class _CourtPlayerChip extends StatelessWidget {
  const _CourtPlayerChip({
    required this.player,
    required this.isTeamA,
    required this.maxWidth,
    required this.maxHeight,
    required this.jerseyColor,
    required this.onTap,
  });

  final Player player;
  final bool isTeamA;
  final double maxWidth;
  final double maxHeight;
  final Color jerseyColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final Color bg = isTeamA ? Colors.white : IwbfColors.textPrimary;
    final Color fg = isTeamA ? IwbfColors.textPrimary : Colors.white;
    final Color border = isTeamA ? IwbfColors.goldDeep : IwbfColors.textPrimary;

    // Dimensões internas derivam APENAS de `maxHeight` para que TODOS os
    // chips fiquem com tamanho idêntico (o SizedBox externo abaixo fixa
    // width × height = maxWidth × maxHeight). A diferença visual entre
    // chips fica restrita ao sobrenome (que pode encolher via
    // _AutoShrinkText). Formulas conservadoras: garantem que a soma das
    // alturas (icone + gap + surname + classe + 2*padding) é sempre <
    // maxHeight, mesmo no piso 46dp.
    final double base = maxHeight;
    final double iconSize = (base * 0.46).clamp(18.0, 42.0);
    final double fontSize = (base * 0.15).clamp(7.5, 11.5);
    final double horizontalPad = (base * 0.06).clamp(2.0, 6.0);
    final double verticalPad = (base * 0.04).clamp(1.5, 4.0);
    final double gap = (base * 0.02).clamp(0.5, 2.0);

    return SizedBox(
      width: maxWidth,
      height: maxHeight,
      child: GestureDetector(
        key: Key('court-chip-${player.id}'),
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: horizontalPad,
            vertical: verticalPad,
          ),
          decoration: BoxDecoration(
            color: bg,
            border: Border.all(color: border, width: 1.2),
            borderRadius: BorderRadius.circular(8),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.25),
                blurRadius: 4,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              PlayerJerseyIcon(
                player: player,
                isTeamA: isTeamA,
                size: iconSize,
                jerseyColor: jerseyColor,
              ),
              SizedBox(height: gap),
              // _AutoShrinkText mede o sobrenome e reduz proporcionalmente
              // o fontSize quando excede a largura do chip. Mantém o chip
              // visualmente uniforme: todos com o mesmo tamanho externo,
              // o sobrenome é o único elemento que muda de tamanho
              // proporcional ao seu comprimento.
              Flexible(
                child: _AutoShrinkText(
                  text: _courtChipName(player.name).toUpperCase(),
                  maxFontSize: fontSize,
                  minFontSize: 8.0,
                  color: fg,
                  fontWeight: FontWeight.w600,
                  textAlign: TextAlign.center,
                ),
              ),
              Text(
                player.playerClass.toStringAsFixed(1),
                style: TextStyle(color: fg, fontSize: fontSize, height: 1.0),
              ),
            ],
          ),
        ),
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
      elevation: 6,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Wrap(
            alignment: WrapAlignment.center,
            spacing: 8,
            runSpacing: 8,
            children: <Widget>[
              OutlinedButton.icon(
                key: const Key('clear-team-a-button'),
                onPressed: onClearTeamA,
                icon: const Icon(Icons.backspace_outlined, size: 18),
                label: const Text('Clear Team A'),
              ),
              OutlinedButton.icon(
                key: const Key('clear-team-b-button'),
                onPressed: onClearTeamB,
                icon: const Icon(Icons.backspace_outlined, size: 18),
                label: const Text('Clear Team B'),
              ),
              OutlinedButton.icon(
                key: const Key('clear-all-button'),
                onPressed: onClearAll,
                icon: const Icon(Icons.clear_all, size: 18),
                label: const Text('Clear All'),
              ),
              OutlinedButton.icon(
                key: const Key('change-teams-button'),
                onPressed: onChangeTeams,
                icon: const Icon(Icons.swap_horiz, size: 18),
                label: const Text('Change Teams'),
              ),
              OutlinedButton.icon(
                key: const Key('load-new-spreadsheet-button'),
                onPressed: onLoadNewSpreadsheet,
                icon: const Icon(Icons.folder_open_outlined, size: 18),
                label: const Text('Load New Spreadsheet'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Renderiza texto em uma única linha aplicando, nesta ordem:
///
/// 1. **Caber tamanho natural**: se a largura natural do texto a
///    `maxFontSize` couber, mantém `maxFontSize`.
/// 2. **Auto-shrink proporcional**: se não couber, calcula
///    `idealFontSize = maxFontSize * maxWidth / naturalWidth` e usa
///    esse valor — texto continua inteiro, fonte menor.
/// 3. **Ellipsis no piso**: se o `idealFontSize` ficaria abaixo de
///    `minFontSize` (texto muito longo para ser legível mesmo
///    encolhido), trava no piso e aplica `TextOverflow.ellipsis`
///    como fallback final — "THOMPSON, Et…" é melhor do que
///    desaparecer.
///
/// `softWrap: false` impede que o `Text` quebre o nome em duas
/// linhas e esconda a segunda com `maxLines: 1` (esse era o bug do
/// "first name some sem ellipsis": o Flutter wrapava em
/// "THOMPSON,/Ethan" e cortava a segunda linha invisivelmente).
class _AutoShrinkText extends StatelessWidget {
  const _AutoShrinkText({
    required this.text,
    required this.maxFontSize,
    this.minFontSize = 7.0,
    this.fontWeight,
    this.color,
    this.textAlign = TextAlign.left,
  });

  final String text;
  final double maxFontSize;
  final double minFontSize;
  final FontWeight? fontWeight;
  final Color? color;
  final TextAlign textAlign;

  /// Piso absoluto de fonte ao quebrar em 2 linhas (last resort).
  static const double _hardMinFontSize = 6.0;

  TextStyle _styleFor(double size) => TextStyle(
        fontSize: size,
        fontWeight: fontWeight,
        color: color,
        height: 1.05,
      );

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final double maxW = constraints.maxWidth;
        final double maxH = constraints.maxHeight;

        // Sem largura definida: renderiza direto (até 2 linhas, sem corte).
        if (!maxW.isFinite) {
          return Text(text,
              maxLines: 2,
              softWrap: true,
              textAlign: textAlign,
              style: _styleFor(maxFontSize));
        }

        // 1) Cabe em UMA linha no tamanho máximo?
        final TextPainter p1 = TextPainter(
          text: TextSpan(text: text, style: _styleFor(maxFontSize)),
          textDirection: TextDirection.ltr,
          maxLines: 1,
        )..layout();

        if (p1.size.width <= maxW) {
          return Text(text,
              maxLines: 1,
              softWrap: false,
              textAlign: textAlign,
              overflow: TextOverflow.clip,
              style: _styleFor(maxFontSize));
        }

        // 2) ENCOLHE a fonte para caber em uma linha, até o piso legível
        //    (minFontSize). Mantém o nome inteiro numa linha só.
        final double oneLineFont = maxFontSize * maxW / p1.size.width;
        if (oneLineFont >= minFontSize) {
          return Text(text,
              maxLines: 1,
              softWrap: false,
              textAlign: textAlign,
              overflow: TextOverflow.clip,
              style: _styleFor(oneLineFont * 0.98));
        }

        // 3) Se mesmo no piso não cabe em uma linha → QUEBRA em até 2
        //    linhas, escolhendo a maior fonte que couber (largura + altura).
        //    Nunca usa ellipsis: o nome completo permanece visível.
        double fit = _hardMinFontSize;
        for (double f = maxFontSize; f >= _hardMinFontSize; f -= 0.5) {
          final TextPainter p2 = TextPainter(
            text: TextSpan(text: text, style: _styleFor(f)),
            textDirection: TextDirection.ltr,
            maxLines: 2,
          )..layout(maxWidth: maxW);
          final bool heightOk = !maxH.isFinite || p2.height <= maxH + 0.5;
          if (!p2.didExceedMaxLines && heightOk) {
            fit = f;
            break;
          }
        }
        return Text(text,
            maxLines: 2,
            softWrap: true,
            textAlign: textAlign,
            overflow: TextOverflow.clip,
            style: _styleFor(fit));
      },
    );
  }
}
