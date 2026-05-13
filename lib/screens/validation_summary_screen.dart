import 'package:flutter/material.dart';

import '../models/team.dart';
import '../services/cache_service.dart';
import '../services/spreadsheet_parser_service.dart';
import '../theme/iwbf_theme.dart';
import '../widgets/iwbf_logo_header.dart';
import 'match_setup_screen.dart';
import 'missing_data_screen.dart';

/// Resumo da planilha após o parser.
///
/// - Mostra contagem de equipes e atletas válidos.
/// - Lista warnings (não bloqueantes) e erros (bloqueantes).
/// - "Continue" só fica habilitado quando não há erros bloqueantes.
class ValidationSummaryScreen extends StatelessWidget {
  const ValidationSummaryScreen({
    super.key,
    required this.result,
    this.cache,
  });

  final SpreadsheetParseResult result;
  final CacheService? cache;

  List<ParseIssue> get _errors => result.issues
      .where((ParseIssue i) => i.severity == ParseIssueSeverity.error)
      .toList();

  List<ParseIssue> get _warnings => result.issues
      .where((ParseIssue i) => i.severity == ParseIssueSeverity.warning)
      .toList();

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
              competitionName: result.competitionName,
              teamCount: result.teams.length,
              playerCount: result.playerCount,
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
                  onPressed: errors.isEmpty && result.teams.isNotEmpty
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
    if (result.teams.isEmpty) return const <Widget>[];
    return <Widget>[
      const Padding(
        padding: EdgeInsets.symmetric(vertical: 8),
        child: Text(
          'Teams found',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
        ),
      ),
      ...result.teams.map((Team team) => Card(
            child: ListTile(
              leading: const Icon(Icons.groups_outlined),
              title: Text(team.displayName),
              subtitle:
                  Text('${team.players.length} player(s) imported'),
            ),
          )),
    ];
  }

  Future<void> _openMissingData(BuildContext context) async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => MissingDataScreen(result: result),
      ),
    );
  }

  Future<void> _continue(BuildContext context) async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => MatchSetupScreen(
          teams: result.teams,
          competitionName: result.competitionName,
        ),
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
