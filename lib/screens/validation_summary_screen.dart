import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../constants/player_classes.dart';
import '../models/player.dart';
import '../models/team.dart';
import '../services/cache_service.dart';
import '../services/spreadsheet_parser_service.dart';
import '../theme/iwbf_theme.dart';
import '../widgets/country_flag.dart';
import '../widgets/iwbf_logo_header.dart';
import 'match_setup_screen.dart';
import 'missing_data_screen.dart';

/// Resumo da planilha após o parser.
///
/// - Mostra contagem de equipes e atletas válidos.
/// - Lista warnings (não bloqueantes) e erros (bloqueantes).
/// - "Continue" só fica habilitado quando não há erros bloqueantes.
/// - Cada equipe vira um `ExpansionTile` com a lista de atletas em ordem
///   de camiseta. Dentro da lista, o usuário pode editar inline:
///   - número da camiseta (input numérico 0-99, com checagem de duplicata
///     dentro da equipe);
///   - classe funcional (dropdown com as 8 classes oficiais).
///   Toda edição é commitada imediatamente; não há botão de "salvar".
class ValidationSummaryScreen extends StatefulWidget {
  const ValidationSummaryScreen({
    super.key,
    required this.result,
    this.cache,
  });

  final SpreadsheetParseResult result;
  final CacheService? cache;

  @override
  State<ValidationSummaryScreen> createState() =>
      _ValidationSummaryScreenState();
}

class _ValidationSummaryScreenState extends State<ValidationSummaryScreen> {
  late List<Team> _teams;

  @override
  void initState() {
    super.initState();
    _teams = <Team>[...widget.result.teams];
  }

  List<ParseIssue> get _errors => widget.result.issues
      .where((ParseIssue i) => i.severity == ParseIssueSeverity.error)
      .toList();

  List<ParseIssue> get _warnings => widget.result.issues
      .where((ParseIssue i) => i.severity == ParseIssueSeverity.warning)
      .toList();

  int get _playerCount {
    int total = 0;
    for (final Team t in _teams) {
      total += t.players.length;
    }
    return total;
  }

  /// Atualiza o número da camiseta de um atleta.
  ///
  /// O `player.id` original é mantido (e usado como `key` do widget) —
  /// se fosse recalculado pra `${team.id}::$newShirt`, o `_EditablePlayerRow`
  /// seria reconstruído a cada tecla e o `TextField` perderia foco.
  /// A duplicata é detectada por `shirtNumber`, não por `id`.
  void _updateShirt(Team team, Player player, int newShirt) {
    final int teamIdx = _teams.indexWhere((Team t) => t.id == team.id);
    if (teamIdx == -1) return;
    final List<Player> updated = team.players
        .map((Player p) =>
            p.id == player.id ? p.copyWith(shirtNumber: newShirt) : p)
        .toList(growable: false);
    setState(() {
      _teams[teamIdx] = team.copyWith(players: updated);
    });
  }

  void _updateClass(Team team, Player player, double newClass) {
    final int teamIdx = _teams.indexWhere((Team t) => t.id == team.id);
    if (teamIdx == -1) return;
    final List<Player> updated = team.players
        .map((Player p) =>
            p.id == player.id ? p.copyWith(playerClass: newClass) : p)
        .toList(growable: false);
    setState(() {
      _teams[teamIdx] = team.copyWith(players: updated);
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<ParseIssue> errors = _errors;
    final List<ParseIssue> warnings = _warnings;

    return Scaffold(
      appBar: AppBar(
        title: const IwbfAppBarTitle(text: 'Spreadsheet Summary'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: <Widget>[
            _Header(
              competitionName: widget.result.competitionName,
              teamCount: _teams.length,
              playerCount: _playerCount,
              hasBlockingIssues: errors.isNotEmpty,
            ),
            const SizedBox(height: 16),
            if (errors.isNotEmpty)
              _IssueBlock(
                title: 'Errors that block the match',
                color: IwbfColors.alertRedSurface,
                borderColor: IwbfColors.alertRed,
                icon: Icons.error_outline,
                issues: errors,
                trailing: FilledButton.tonalIcon(
                  key: const Key('view-issues-button'),
                  onPressed: () => _openMissingData(context),
                  icon: const Icon(Icons.list_alt),
                  label: const Text('View Issues'),
                ),
              ),
            if (warnings.isNotEmpty)
              _IssueBlock(
                title: 'Warnings',
                color: const Color(0xFFFFF7E0),
                borderColor: IwbfColors.goldDeep,
                icon: Icons.warning_amber_outlined,
                issues: warnings,
              ),
            const SizedBox(height: 8),
            ..._teamTiles(),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: <Widget>[
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Load Different Spreadsheet'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton(
                  key: const Key('continue-button'),
                  onPressed: errors.isEmpty && _teams.isNotEmpty
                      ? () => _continue(context)
                      : null,
                  child: const Text('Continue'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _teamTiles() {
    if (_teams.isEmpty) return const <Widget>[];
    final List<Team> sorted = <Team>[..._teams]
      ..sort((Team a, Team b) =>
          a.displayName.toLowerCase().compareTo(b.displayName.toLowerCase()));
    return <Widget>[
      const Padding(
        padding: EdgeInsets.symmetric(vertical: 8),
        child: Text(
          'Teams found',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
        ),
      ),
      ...sorted.map((Team team) => Card(
            clipBehavior: Clip.antiAlias,
            child: ExpansionTile(
              key: Key('team-tile-${team.id}'),
              leading: CountryFlag(rawName: team.teamName, size: 24),
              title: Text(team.displayName),
              subtitle:
                  Text('${team.players.length} player(s) imported'),
              children: _playerRows(team),
            ),
          )),
    ];
  }

  List<Widget> _playerRows(Team team) {
    if (team.players.isEmpty) {
      return const <Widget>[
        Padding(
          padding: EdgeInsets.all(12),
          child: Text('No players imported for this team.'),
        ),
      ];
    }
    final List<Player> sorted = <Player>[...team.players]
      ..sort((Player a, Player b) => a.shirtNumber.compareTo(b.shirtNumber));
    return <Widget>[
      const Divider(height: 1),
      for (final Player p in sorted)
        _EditablePlayerRow(
          key: ValueKey<String>('player-row-${p.id}'),
          player: p,
          siblings: team.players,
          onShirtChanged: (int newShirt) => _updateShirt(team, p, newShirt),
          onClassChanged: (double newClass) =>
              _updateClass(team, p, newClass),
        ),
    ];
  }

  Future<void> _openMissingData(BuildContext context) async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => MissingDataScreen(result: widget.result),
      ),
    );
  }

  Future<void> _continue(BuildContext context) async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => MatchSetupScreen(
          teams: _teams,
          competitionName: widget.result.competitionName,
        ),
      ),
    );
  }
}

String _formatDob(DateTime? dob) {
  if (dob == null) return '—';
  final String day = dob.day.toString().padLeft(2, '0');
  final String month = dob.month.toString().padLeft(2, '0');
  return '$day/$month/${dob.year}';
}

/// Linha editável de um atleta no `ExpansionTile`.
///
/// - Campo numérico (0-99) pro número da camiseta. Validação acontece em
///   `onChanged`; quando há erro (vazio/inválido/duplicado), a borda fica
///   vermelha e a mensagem aparece embaixo. Quando volta a ser válido,
///   chama [onShirtChanged] com o novo valor.
/// - Dropdown pra classe funcional (`kAcceptedPlayerClasses`).
class _EditablePlayerRow extends StatefulWidget {
  const _EditablePlayerRow({
    super.key,
    required this.player,
    required this.siblings,
    required this.onShirtChanged,
    required this.onClassChanged,
  });

  final Player player;
  final List<Player> siblings;
  final ValueChanged<int> onShirtChanged;
  final ValueChanged<double> onClassChanged;

  @override
  State<_EditablePlayerRow> createState() => _EditablePlayerRowState();
}

class _EditablePlayerRowState extends State<_EditablePlayerRow> {
  late TextEditingController _controller;
  String? _error;

  @override
  void initState() {
    super.initState();
    _controller =
        TextEditingController(text: widget.player.shirtNumber.toString());
  }

  @override
  void didUpdateWidget(_EditablePlayerRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Se o pai (Summary) commitou um novo shirt válido, sincronizamos o
    // controller — mas só quando o usuário não está digitando.
    final String latest = widget.player.shirtNumber.toString();
    if (_controller.text != latest && _error == null) {
      _controller.text = latest;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onShirtInput(String raw) {
    final String trimmed = raw.trim();
    if (trimmed.isEmpty) {
      setState(() => _error = 'Shirt number is required.');
      return;
    }
    final int? parsed = int.tryParse(trimmed);
    if (parsed == null || parsed < 0 || parsed > 99) {
      setState(() => _error = 'Use a number between 0 and 99.');
      return;
    }
    if (parsed == widget.player.shirtNumber) {
      setState(() => _error = null);
      return;
    }
    final bool duplicate = widget.siblings
        .any((Player p) => p.id != widget.player.id && p.shirtNumber == parsed);
    if (duplicate) {
      setState(() => _error = 'Shirt #$parsed is already in use.');
      return;
    }
    setState(() => _error = null);
    widget.onShirtChanged(parsed);
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final TextStyle subtitleStyle =
        theme.textTheme.bodySmall ?? const TextStyle(fontSize: 12);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 6, 12, 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              SizedBox(
                width: 56,
                child: TextField(
                  key: Key('shirt-input-${widget.player.id}'),
                  controller: _controller,
                  keyboardType: TextInputType.number,
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(2),
                  ],
                  textAlign: TextAlign.center,
                  decoration: InputDecoration(
                    isDense: true,
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
                    border: const OutlineInputBorder(),
                    enabledBorder: _error != null
                        ? const OutlineInputBorder(
                            borderSide:
                                BorderSide(color: IwbfColors.alertRed),
                          )
                        : null,
                    focusedBorder: _error != null
                        ? const OutlineInputBorder(
                            borderSide: BorderSide(
                                color: IwbfColors.alertRed, width: 2),
                          )
                        : null,
                  ),
                  style: const TextStyle(fontWeight: FontWeight.w700),
                  onChanged: _onShirtInput,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(
                      widget.player.displayName,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                    Text(
                      _formatDob(widget.player.dateOfBirth),
                      style: subtitleStyle,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: 72,
                child: DropdownButtonFormField<double>(
                  key: Key('class-dropdown-${widget.player.id}'),
                  initialValue: widget.player.playerClass,
                  isDense: true,
                  decoration: const InputDecoration(
                    isDense: true,
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 6, vertical: 8),
                    border: OutlineInputBorder(),
                  ),
                  items: kAcceptedPlayerClasses
                      .map((double v) => DropdownMenuItem<double>(
                            value: v,
                            child: Text(v.toStringAsFixed(1)),
                          ))
                      .toList(growable: false),
                  onChanged: (double? next) {
                    if (next != null) widget.onClassChanged(next);
                  },
                ),
              ),
            ],
          ),
          if (_error != null)
            Padding(
              padding: const EdgeInsets.only(top: 4, left: 4),
              child: Text(
                _error!,
                style: const TextStyle(
                  color: IwbfColors.alertRed,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.competitionName,
    required this.teamCount,
    required this.playerCount,
    required this.hasBlockingIssues,
  });

  final String? competitionName;
  final int teamCount;
  final int playerCount;
  final bool hasBlockingIssues;

  @override
  Widget build(BuildContext context) {
    final TextStyle? titleStyle = Theme.of(context).textTheme.titleMedium;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            if (competitionName != null && competitionName!.isNotEmpty) ...<Widget>[
              Text('Competition: $competitionName', style: titleStyle),
              const SizedBox(height: 4),
            ],
            Text('Teams found: $teamCount'),
            Text('Players found: $playerCount'),
            const SizedBox(height: 8),
            Row(
              children: <Widget>[
                Icon(
                  hasBlockingIssues
                      ? Icons.error_outline
                      : Icons.check_circle_outline,
                  color: hasBlockingIssues
                      ? IwbfColors.alertRed
                      : const Color(0xFF1B8A3A),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    hasBlockingIssues
                        ? 'Spreadsheet has errors — fix before continuing.'
                        : 'Spreadsheet loaded successfully.',
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

class _IssueBlock extends StatelessWidget {
  const _IssueBlock({
    required this.title,
    required this.color,
    required this.borderColor,
    required this.icon,
    required this.issues,
    this.trailing,
  });

  final String title;
  final Color color;
  final Color borderColor;
  final IconData icon;
  final List<ParseIssue> issues;
  final Widget? trailing;

  static const int _previewCount = 5;

  @override
  Widget build(BuildContext context) {
    final List<ParseIssue> preview =
        issues.length > _previewCount ? issues.sublist(0, _previewCount) : issues;
    final int remaining = issues.length - preview.length;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color,
        border: Border.all(color: borderColor),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Icon(icon, color: borderColor),
              const SizedBox(width: 8),
              Text(
                '$title (${issues.length})',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...preview.map((ParseIssue issue) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Text('• ${issue.message}'),
              )),
          if (remaining > 0)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                '… and $remaining more',
                style: const TextStyle(fontStyle: FontStyle.italic),
              ),
            ),
          if (trailing != null) ...<Widget>[
            const SizedBox(height: 8),
            trailing!,
          ],
        ],
      ),
    );
  }
}
