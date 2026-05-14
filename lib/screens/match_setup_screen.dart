import 'package:flutter/material.dart';

import '../constants/point_limits.dart';
import '../models/match_state.dart';
import '../models/team.dart';
import '../theme/iwbf_theme.dart';
import '../widgets/country_flag.dart';
import '../widgets/iwbf_logo_header.dart';
import 'lineup_control_screen.dart';

/// Configuração da partida: escolhe Team A, Team B e Point Limit.
///
/// Aceita dois caminhos de entrada:
/// - lista de [teams] vinda da `ValidationSummaryScreen`;
/// - [restored] vindo do cache, ao restaurar sessão anterior.
///
/// "Start Match" só fica habilitado quando há duas equipes selecionadas
/// e elas são diferentes. Em retrato (uso principal), os dropdowns ficam
/// empilhados para acomodar tablet e celular.
class MatchSetupScreen extends StatefulWidget {
  const MatchSetupScreen({
    super.key,
    this.teams,
    this.competitionName,
    this.restored,
  });

  final List<Team>? teams;
  final String? competitionName;
  final MatchState? restored;

  @override
  State<MatchSetupScreen> createState() => _MatchSetupScreenState();
}

class _MatchSetupScreenState extends State<MatchSetupScreen> {
  Team? _teamA;
  Team? _teamB;
  double _pointLimit = kDefaultPointLimit;

  @override
  void initState() {
    super.initState();
    final MatchState? restored = widget.restored;
    if (restored != null) {
      _teamA = restored.teamA;
      _teamB = restored.teamB;
      _pointLimit = restored.pointLimit;
    }
  }

  List<Team> get _availableTeams {
    final List<Team>? raw = widget.teams;
    final List<Team> source;
    if (raw != null) {
      source = raw;
    } else {
      final MatchState? r = widget.restored;
      if (r != null) {
        source = <Team>[r.teamA, r.teamB];
      } else {
        return const <Team>[];
      }
    }
    return <Team>[...source]
      ..sort((Team a, Team b) =>
          a.displayName.toLowerCase().compareTo(b.displayName.toLowerCase()));
  }

  String? get _competitionName =>
      widget.competitionName ?? widget.restored?.competitionName;

  bool get _teamsAreSame =>
      _teamA != null && _teamB != null && _teamA == _teamB;

  bool get _canStart =>
      _teamA != null && _teamB != null && !_teamsAreSame;

  /// Pareamento oficial IWBF: Men vs Men, Women vs Women. Se o usuario
  /// monta Men x Women (ou Women x Men), o app pergunta antes de seguir.
  /// Casos com `mixed` ou `unspecified` nao disparam o alerta porque
  /// nao da pra afirmar conflito sem dados.
  bool get _hasGenderMismatch {
    final Team? a = _teamA;
    final Team? b = _teamB;
    if (a == null || b == null) return false;
    if (a == b) return false;
    final TeamGender ga = a.gender;
    final TeamGender gb = b.gender;
    return (ga == TeamGender.men && gb == TeamGender.women) ||
        (ga == TeamGender.women && gb == TeamGender.men);
  }

  Future<void> _onStartPressed() async {
    if (!_canStart) return;
    if (_hasGenderMismatch) {
      final bool? confirm = await _showGenderMismatchDialog();
      if (confirm != true) return;
    }
    _startMatch();
  }

  Future<bool?> _showGenderMismatchDialog() {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) => AlertDialog(
        key: const Key('gender-mismatch-dialog'),
        title: const Text('Gender mismatch'),
        content: Text(
          'You selected ${_teamA!.displayName} vs ${_teamB!.displayName}. '
          "Official IWBF matches are played between teams of the same "
          "gender (Men vs Men or Women vs Women). Do you want to continue "
          "anyway?",
        ),
        actions: <Widget>[
          TextButton(
            key: const Key('gender-mismatch-cancel'),
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            key: const Key('gender-mismatch-continue'),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Continue anyway'),
          ),
        ],
      ),
    );
  }

  void _startMatch() {
    final Team a = _teamA!;
    final Team b = _teamB!;
    final MatchState state = MatchState(
      teamA: a,
      teamB: b,
      pointLimit: _pointLimit,
      competitionName: _competitionName,
    );
    Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => LineupControlScreen(initialState: state),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<Team> teams = _availableTeams;
    final String? compName = _competitionName;

    return Scaffold(
      appBar: AppBar(
        title: const IwbfAppBarTitle(text: 'Match Setup'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              if (compName != null && compName.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Text(
                    'Competition: $compName',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
              _TeamDropdown(
                key: const Key('team-a-dropdown'),
                label: 'Select Team A',
                value: _teamA,
                teams: teams,
                onChanged: (Team? value) => setState(() => _teamA = value),
              ),
              const SizedBox(height: 16),
              _TeamDropdown(
                key: const Key('team-b-dropdown'),
                label: 'Select Team B',
                value: _teamB,
                teams: teams,
                onChanged: (Team? value) => setState(() => _teamB = value),
              ),
              const SizedBox(height: 16),
              _PointLimitDropdown(
                value: _pointLimit,
                onChanged: (double next) =>
                    setState(() => _pointLimit = next),
              ),
              if (_teamsAreSame)
                const Padding(
                  padding: EdgeInsets.only(top: 12),
                  child: Text(
                    'Team A and Team B must be different.',
                    key: Key('teams-equal-error'),
                    style: TextStyle(color: IwbfColors.alertRed),
                  ),
                ),
              if (_hasGenderMismatch)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Container(
                    key: const Key('gender-mismatch-warning'),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: IwbfColors.alertRed.withValues(alpha: 0.08),
                      border: Border.all(
                        color: IwbfColors.alertRed.withValues(alpha: 0.6),
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        const Icon(
                          Icons.warning_amber_rounded,
                          color: IwbfColors.alertRed,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'You picked a Men\'s team against a Women\'s team. '
                            'Official IWBF matches are same-gender. '
                            'You can continue, but a confirmation will be asked.',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              const Spacer(),
              if (teams.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Text(
                    'No teams loaded. Go back and import a spreadsheet.',
                  ),
                ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: FilledButton.icon(
            key: const Key('start-match-button'),
            onPressed: _canStart ? _onStartPressed : null,
            icon: const Icon(Icons.play_arrow),
            label: const Text('Start Match'),
          ),
        ),
      ),
    );
  }
}

class _TeamDropdown extends StatelessWidget {
  const _TeamDropdown({
    super.key,
    required this.label,
    required this.value,
    required this.teams,
    required this.onChanged,
  });

  final String label;
  final Team? value;
  final List<Team> teams;
  final ValueChanged<Team?> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<Team>(
      initialValue: value,
      isExpanded: true,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      items: teams
          .map(
            (Team t) => DropdownMenuItem<Team>(
              value: t,
              child: Row(
                children: <Widget>[
                  CountryFlag(rawName: t.teamName, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      t.displayName,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          )
          .toList(),
      onChanged: teams.isEmpty ? null : onChanged,
    );
  }
}

class _PointLimitDropdown extends StatelessWidget {
  const _PointLimitDropdown({
    required this.value,
    required this.onChanged,
  });

  final double value;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<double>(
      key: const Key('point-limit-dropdown'),
      initialValue: value,
      isExpanded: true,
      decoration: const InputDecoration(
        labelText: 'Point Limit',
        border: OutlineInputBorder(),
      ),
      items: kAcceptedPointLimits
          .map(
            (double v) => DropdownMenuItem<double>(
              value: v,
              child: Text(v.toStringAsFixed(1)),
            ),
          )
          .toList(),
      onChanged: (double? next) {
        if (next != null) onChanged(next);
      },
    );
  }
}
