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
/// - Mostra contagem de equipes e atletas válidos (badges) + status pill.
/// - Lista warnings (não bloqueantes) e erros (bloqueantes).
/// - "Continue" só fica habilitado quando não há erros bloqueantes e há
///   pelo menos uma equipe.
/// - Cada equipe vira um `ExpansionTile` com a lista de atletas em ordem
///   de camiseta. Dentro da lista, o usuário edita o roster inline:
///   - nome (campo de texto livre);
///   - número da camiseta (input numérico 0-99, com checagem de duplicata
///     dentro da equipe);
///   - data de nascimento (date picker, opcional);
///   - gênero (dropdown, opcional);
///   - classe funcional (dropdown com as 8 classes oficiais);
///   - excluir o atleta (com confirmação).
///   No cabeçalho de cada equipe é possível renomeá-la ou excluí-la (com
///   confirmação). Toda edição é commitada imediatamente; não há "salvar".
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

  /// Substitui um atleta na equipe aplicando [update], preservando o
  /// `player.id` (usado como `key` do widget) para não recriar o
  /// `_EditablePlayerRow` a cada tecla — o que faria os campos perderem foco.
  void _mutatePlayer(
      Team team, Player player, Player Function(Player) update) {
    final int teamIdx = _teams.indexWhere((Team t) => t.id == team.id);
    if (teamIdx == -1) return;
    final List<Player> updated = team.players
        .map((Player p) => p.id == player.id ? update(p) : p)
        .toList(growable: false);
    setState(() {
      _teams[teamIdx] = team.copyWith(players: updated);
    });
  }

  void _updateShirt(Team team, Player player, int newShirt) =>
      _mutatePlayer(team, player, (Player p) => p.copyWith(shirtNumber: newShirt));

  void _updateName(Team team, Player player, String newName) =>
      _mutatePlayer(team, player, (Player p) => p.copyWith(name: newName));

  void _updateClass(Team team, Player player, double newClass) =>
      _mutatePlayer(team, player, (Player p) => p.copyWith(playerClass: newClass));

  void _updateDob(Team team, Player player, DateTime newDob) =>
      _mutatePlayer(team, player, (Player p) => p.copyWith(dateOfBirth: newDob));

  void _updateGender(Team team, Player player, PlayerGender newGender) =>
      _mutatePlayer(team, player, (Player p) => p.copyWith(gender: newGender));

  void _deletePlayer(Team team, Player player) {
    final int teamIdx = _teams.indexWhere((Team t) => t.id == team.id);
    if (teamIdx == -1) return;
    final List<Player> updated = team.players
        .where((Player p) => p.id != player.id)
        .toList(growable: false);
    setState(() {
      _teams[teamIdx] = team.copyWith(players: updated);
    });
  }

  void _deleteTeam(Team team) {
    setState(() {
      _teams.removeWhere((Team t) => t.id == team.id);
    });
  }

  void _renameTeam(Team team, String newName) {
    final String trimmed = newName.trim();
    if (trimmed.isEmpty) return;
    final int teamIdx = _teams.indexWhere((Team t) => t.id == team.id);
    if (teamIdx == -1) return;
    setState(() {
      _teams[teamIdx] = team.copyWith(teamName: trimmed);
    });
  }

  Future<void> _confirmDeletePlayer(Team team, Player player) async {
    final bool? ok = await showDialog<bool>(
      context: context,
      builder: (BuildContext ctx) => AlertDialog(
        title: const Text('Remove player?'),
        content: Text(
          'Remove ${player.displayName} (#${player.shirtNumber}) '
          'from ${team.displayName}?',
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
    if (ok == true) _deletePlayer(team, player);
  }

  Future<void> _confirmDeleteTeam(Team team) async {
    final bool? ok = await showDialog<bool>(
      context: context,
      builder: (BuildContext ctx) => AlertDialog(
        title: const Text('Delete team?'),
        content: Text(
          'Delete ${team.displayName} and its '
          '${team.players.length} player(s)?',
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: IwbfColors.alertRed),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (ok == true) _deleteTeam(team);
  }

  Future<void> _promptRenameTeam(Team team) async {
    final TextEditingController controller =
        TextEditingController(text: team.teamName);
    final String? newName = await showDialog<String>(
      context: context,
      builder: (BuildContext ctx) => AlertDialog(
        title: const Text('Rename team'),
        content: TextField(
          controller: controller,
          autofocus: true,
          textCapitalization: TextCapitalization.words,
          decoration: const InputDecoration(labelText: 'Team name'),
          onSubmitted: (String v) => Navigator.of(ctx).pop(v),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(controller.text),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    controller.dispose();
    if (newName != null) _renameTeam(team, newName);
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
                  icon: const Icon(Icons.list_alt_outlined),
                  label: const Text('View Issues'),
                ),
              ),
            if (warnings.isNotEmpty)
              _IssueBlock(
                title: 'Warnings',
                color: IwbfColors.warningSurface,
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

    final List<Team> menTeams = <Team>[];
    final List<Team> womenTeams = <Team>[];
    final List<Team> mixedTeams = <Team>[];
    final List<Team> otherTeams = <Team>[];

    for (final Team t in _teams) {
      switch (t.gender) {
        case TeamGender.men:
          menTeams.add(t);
        case TeamGender.women:
          womenTeams.add(t);
        case TeamGender.mixed:
          mixedTeams.add(t);
        case TeamGender.unspecified:
          otherTeams.add(t);
      }
    }

    int alphaSort(Team a, Team b) =>
        a.displayName.toLowerCase().compareTo(b.displayName.toLowerCase());
    menTeams.sort(alphaSort);
    womenTeams.sort(alphaSort);
    mixedTeams.sort(alphaSort);
    otherTeams.sort(alphaSort);

    final List<Widget> tiles = <Widget>[
      const Padding(
        padding: EdgeInsets.symmetric(vertical: 8),
        child: Text(
          'Teams found',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
        ),
      ),
    ];
    if (menTeams.isNotEmpty) {
      tiles.add(const _SectionHeader(label: "Men's Teams"));
      tiles.addAll(menTeams.map(_teamCard));
    }
    if (womenTeams.isNotEmpty) {
      tiles.add(const _SectionHeader(label: "Women's Teams"));
      tiles.addAll(womenTeams.map(_teamCard));
    }
    if (mixedTeams.isNotEmpty) {
      tiles.add(const _SectionHeader(label: 'Mixed Teams'));
      tiles.addAll(mixedTeams.map(_teamCard));
    }
    if (otherTeams.isNotEmpty) {
      // Quando os outros grupos existem, distinguimos "Other". Quando só
      // este existe (planilha sem coluna gender), omitimos o header e
      // mostramos os times direto.
      final bool hasGenderedGroups = menTeams.isNotEmpty ||
          womenTeams.isNotEmpty ||
          mixedTeams.isNotEmpty;
      if (hasGenderedGroups) {
        tiles.add(const _SectionHeader(label: 'Other Teams'));
      }
      tiles.addAll(otherTeams.map(_teamCard));
    }
    return tiles;
  }

  Widget _teamCard(Team team) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: ExpansionTile(
        key: Key('team-tile-${team.id}'),
        leading: CountryFlag(rawName: team.teamName, size: 24),
        title: Text(team.displayName),
        subtitle: Text('${team.players.length} player(s) imported'),
        childrenPadding: EdgeInsets.zero,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                TextButton.icon(
                  key: Key('rename-team-${team.id}'),
                  onPressed: () => _promptRenameTeam(team),
                  icon: const Icon(Icons.edit_outlined, size: 18),
                  label: const Text('Rename'),
                ),
                TextButton.icon(
                  key: Key('delete-team-${team.id}'),
                  onPressed: () => _confirmDeleteTeam(team),
                  icon: const Icon(Icons.delete_outline, size: 18),
                  label: const Text('Delete'),
                  style: TextButton.styleFrom(
                    foregroundColor: IwbfColors.alertRed,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          ..._playerRows(team),
        ],
      ),
    );
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
      for (final Player p in sorted)
        _EditablePlayerRow(
          key: ValueKey<String>('player-row-${p.id}'),
          player: p,
          siblings: team.players,
          onShirtChanged: (int newShirt) => _updateShirt(team, p, newShirt),
          onNameChanged: (String newName) => _updateName(team, p, newName),
          onClassChanged: (double newClass) => _updateClass(team, p, newClass),
          onDobChanged: (DateTime dob) => _updateDob(team, p, dob),
          onGenderChanged: (PlayerGender g) => _updateGender(team, p, g),
          onDelete: () => _confirmDeletePlayer(team, p),
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
/// Layout em duas linhas para caber em telas estreitas:
/// - Linha 1: nome (campo de texto que ocupa a largura) + botão de excluir.
/// - Linha 2: número da camiseta, data de nascimento, gênero e classe.
///
/// O número valida em `onChanged` (vazio/inválido/duplicado → borda e
/// mensagem vermelhas compactas). Classe inválida pinta o dropdown de
/// vermelho-claro (`alertRedSurface`). Data de nascimento e gênero são
/// opcionais.
class _EditablePlayerRow extends StatefulWidget {
  const _EditablePlayerRow({
    super.key,
    required this.player,
    required this.siblings,
    required this.onShirtChanged,
    required this.onNameChanged,
    required this.onClassChanged,
    required this.onDobChanged,
    required this.onGenderChanged,
    required this.onDelete,
  });

  final Player player;
  final List<Player> siblings;
  final ValueChanged<int> onShirtChanged;
  final ValueChanged<String> onNameChanged;
  final ValueChanged<double> onClassChanged;
  final ValueChanged<DateTime> onDobChanged;
  final ValueChanged<PlayerGender> onGenderChanged;
  final VoidCallback onDelete;

  @override
  State<_EditablePlayerRow> createState() => _EditablePlayerRowState();
}

class _EditablePlayerRowState extends State<_EditablePlayerRow> {
  late TextEditingController _shirtController;
  late TextEditingController _nameController;
  String? _error;

  @override
  void initState() {
    super.initState();
    _shirtController =
        TextEditingController(text: widget.player.shirtNumber.toString());
    _nameController = TextEditingController(text: widget.player.name);
  }

  @override
  void didUpdateWidget(_EditablePlayerRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Sincroniza os controllers se o pai commitou um valor novo — mas só
    // quando difere do que está no campo (evita resetar o cursor enquanto
    // o usuário digita, já que o valor commitado iguala o digitado).
    final String latestShirt = widget.player.shirtNumber.toString();
    if (_shirtController.text != latestShirt && _error == null) {
      _shirtController.text = latestShirt;
    }
    if (_nameController.text != widget.player.name) {
      _nameController.text = widget.player.name;
    }
  }

  @override
  void dispose() {
    _shirtController.dispose();
    _nameController.dispose();
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
    final bool classValid = isAcceptedPlayerClass(widget.player.playerClass);
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 6, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // Linha 1: nome (ocupa a largura) + excluir.
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Expanded(
                child: TextField(
                  key: Key('name-input-${widget.player.id}'),
                  controller: _nameController,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                    isDense: true,
                    labelText: 'Name',
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  ),
                  style: const TextStyle(fontWeight: FontWeight.w600),
                  onChanged: widget.onNameChanged,
                ),
              ),
              IconButton(
                key: Key('delete-player-${widget.player.id}'),
                visualDensity: VisualDensity.compact,
                tooltip: 'Remove player',
                color: IwbfColors.alertRed,
                icon: const Icon(Icons.close, size: 20),
                onPressed: widget.onDelete,
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Linha 2: número, nascimento, gênero, classe.
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              SizedBox(
                width: 56,
                child: TextField(
                  key: Key('shirt-input-${widget.player.id}'),
                  controller: _shirtController,
                  keyboardType: TextInputType.number,
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(2),
                  ],
                  textAlign: TextAlign.center,
                  decoration: InputDecoration(
                    isDense: true,
                    labelText: '#',
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 4, vertical: 10),
                    errorText: _error,
                    errorStyle: const TextStyle(
                      fontSize: 10,
                      height: 0.6,
                      color: IwbfColors.alertRed,
                    ),
                  ),
                  style: const TextStyle(fontWeight: FontWeight.w700),
                  onChanged: _onShirtInput,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 5,
                child: _DobField(
                  dob: widget.player.dateOfBirth,
                  onChanged: widget.onDobChanged,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 5,
                child: _GenderDropdown(
                  gender: widget.player.gender,
                  onChanged: widget.onGenderChanged,
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: 72,
                child: DropdownButtonFormField<double>(
                  key: Key('class-dropdown-${widget.player.id}'),
                  initialValue: classValid ? widget.player.playerClass : null,
                  isDense: true,
                  isExpanded: true,
                  decoration: InputDecoration(
                    isDense: true,
                    labelText: 'Cls',
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 6, vertical: 10),
                    filled: !classValid,
                    fillColor: classValid ? null : IwbfColors.alertRedSurface,
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
        ],
      ),
    );
  }
}

/// Campo de data de nascimento — abre um `showDatePicker` ao tocar.
/// Opcional: quando nulo mostra "—".
class _DobField extends StatelessWidget {
  const _DobField({required this.dob, required this.onChanged});

  final DateTime? dob;
  final ValueChanged<DateTime> onChanged;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () async {
        final DateTime now = DateTime.now();
        final DateTime first = DateTime(now.year - 80);
        DateTime initial = dob ?? DateTime(now.year - 20, now.month, now.day);
        if (initial.isAfter(now)) initial = now;
        if (initial.isBefore(first)) initial = first;
        final DateTime? picked = await showDatePicker(
          context: context,
          initialDate: initial,
          firstDate: first,
          lastDate: now,
        );
        if (picked != null) onChanged(picked);
      },
      child: InputDecorator(
        decoration: const InputDecoration(
          isDense: true,
          labelText: 'Birth date',
          contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          suffixIcon: Icon(Icons.calendar_today_outlined, size: 16),
        ),
        child: Text(
          _formatDob(dob),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 13),
        ),
      ),
    );
  }
}

/// Dropdown de gênero (opcional). Compacto para caber na linha de atributos.
class _GenderDropdown extends StatelessWidget {
  const _GenderDropdown({required this.gender, required this.onChanged});

  final PlayerGender gender;
  final ValueChanged<PlayerGender> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<PlayerGender>(
      initialValue: gender,
      isDense: true,
      isExpanded: true,
      decoration: const InputDecoration(
        isDense: true,
        labelText: 'Gender',
        contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      ),
      items: const <DropdownMenuItem<PlayerGender>>[
        DropdownMenuItem<PlayerGender>(
          value: PlayerGender.male,
          child: Text('Male'),
        ),
        DropdownMenuItem<PlayerGender>(
          value: PlayerGender.female,
          child: Text('Female'),
        ),
        DropdownMenuItem<PlayerGender>(
          value: PlayerGender.unspecified,
          child: Text('—'),
        ),
      ],
      onChanged: (PlayerGender? next) {
        if (next != null) onChanged(next);
      },
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
    final bool hasCompetition =
        competitionName != null && competitionName!.isNotEmpty;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            if (hasCompetition) ...<Widget>[
              Text('Competition: $competitionName', style: titleStyle),
              const SizedBox(height: 12),
            ],
            Row(
              children: <Widget>[
                _StatBadge(
                  icon: Icons.groups_outlined,
                  count: teamCount,
                  label: 'Teams',
                ),
                const SizedBox(width: 12),
                _StatBadge(
                  icon: Icons.person_outline,
                  count: playerCount,
                  label: 'Players',
                ),
              ],
            ),
            const SizedBox(height: 12),
            _StatusPill(hasBlockingIssues: hasBlockingIssues),
          ],
        ),
      ),
    );
  }
}

/// Badge com a contagem de equipes / atletas. O texto é uma única string
/// (`"$count $label"`) para ficar estável em testes e leitura.
class _StatBadge extends StatelessWidget {
  const _StatBadge({
    required this.icon,
    required this.count,
    required this.label,
  });

  final IconData icon;
  final int count;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: IwbfColors.slate100,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: IwbfColors.slate200),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, size: 18, color: IwbfColors.goldDeep),
          const SizedBox(width: 8),
          Text(
            '$count $label',
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

/// Pílula de status: verde "loaded successfully" ou vermelha "fix before
/// continuing". As strings são preservadas para os testes.
class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.hasBlockingIssues});

  final bool hasBlockingIssues;

  @override
  Widget build(BuildContext context) {
    final Color accent =
        hasBlockingIssues ? IwbfColors.alertRed : IwbfColors.successGreen;
    final Color bg = hasBlockingIssues
        ? IwbfColors.alertRedSurface
        : IwbfColors.successGreen.withValues(alpha: 0.12);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: accent.withValues(alpha: 0.5)),
      ),
      child: Row(
        children: <Widget>[
          Icon(
            hasBlockingIssues
                ? Icons.error_outline
                : Icons.check_circle_outline,
            color: accent,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              hasBlockingIssues
                  ? 'Spreadsheet has errors — fix before continuing.'
                  : 'Spreadsheet loaded successfully.',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
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

    // Borda-acento à esquerda: barra colorida de 4px + borda uniforme suave.
    // (Não dá pra usar `Border(left:)` com `borderRadius` — o Flutter exige
    // borda uniforme quando há raio; daí a barra como filho.)
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: borderColor.withValues(alpha: 0.4)),
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Container(width: 4, color: borderColor),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
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
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Cabeçalho de subseção em "Teams found" — separa Men's / Women's /
/// Mixed / Other quando a planilha tem atletas de gêneros diferentes.
class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 12, 4, 4),
      child: Text(
        label,
        style: const TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 14,
          letterSpacing: 0.4,
        ),
      ),
    );
  }
}
