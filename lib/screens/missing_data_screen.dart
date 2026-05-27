import 'package:flutter/material.dart';

import '../services/spreadsheet_parser_service.dart';
import '../theme/iwbf_theme.dart';
import '../widgets/iwbf_logo_header.dart';

/// Tela de diagnóstico para issues bloqueantes da planilha.
///
/// MVP da Fase 2: lista o que precisa ser corrigido na planilha de
/// origem e pede ao usuário para refazer o upload depois de corrigir.
/// Edição inline pode entrar como refinamento futuro (registrado no
/// AI_WORK_LOG).
class MissingDataScreen extends StatelessWidget {
  const MissingDataScreen({super.key, required this.result});

  final SpreadsheetParseResult result;

  @override
  Widget build(BuildContext context) {
    final Map<ParseIssueCategory, List<ParseIssue>> grouped =
        _groupBlockingIssuesByCategory(result.issues);
    final bool hasBlockingIssues = grouped.values.any((l) => l.isNotEmpty);

    return Scaffold(
      appBar: AppBar(
        title: const IwbfAppBarTitle(text: 'Missing Data'),
      ),
      body: SafeArea(
        child: hasBlockingIssues
            ? _IssuesList(grouped: grouped)
            : const _EmptyState(),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: FilledButton.icon(
            key: const Key('back-to-load-button'),
            onPressed: () =>
                Navigator.of(context).popUntil((Route<void> r) => r.isFirst),
            icon: const Icon(Icons.upload_file),
            label: const Text('Load Different Spreadsheet'),
          ),
        ),
      ),
    );
  }
}

Map<ParseIssueCategory, List<ParseIssue>> _groupBlockingIssuesByCategory(
    List<ParseIssue> issues) {
  final Map<ParseIssueCategory, List<ParseIssue>> grouped =
      <ParseIssueCategory, List<ParseIssue>>{};
  for (final ParseIssue issue in issues) {
    if (issue.severity != ParseIssueSeverity.error) continue;
    grouped.putIfAbsent(issue.category, () => <ParseIssue>[]).add(issue);
  }
  return grouped;
}

class _IssuesList extends StatelessWidget {
  const _IssuesList({required this.grouped});

  final Map<ParseIssueCategory, List<ParseIssue>> grouped;

  @override
  Widget build(BuildContext context) {
    final List<ParseIssueCategory> orderedCategories =
        grouped.keys.toList()..sort((a, b) => a.index.compareTo(b.index));

    return ListView(
      padding: const EdgeInsets.all(16),
      children: <Widget>[
        const Text(
          'Some players are missing required information.',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
        ),
        const SizedBox(height: 8),
        const Text(
          'Please complete the missing information before continuing. '
          'Update the spreadsheet and load it again.',
        ),
        const SizedBox(height: 16),
        ...orderedCategories.map((ParseIssueCategory cat) {
          final List<ParseIssue> issues = grouped[cat]!;
          return _CategoryBlock(category: cat, issues: issues);
        }),
      ],
    );
  }
}

class _CategoryBlock extends StatelessWidget {
  const _CategoryBlock({required this.category, required this.issues});

  final ParseIssueCategory category;
  final List<ParseIssue> issues;

  String get _categoryTitle {
    switch (category) {
      case ParseIssueCategory.missingShirtNumber:
        return 'Players missing shirt number';
      case ParseIssueCategory.missingPlayerName:
        return 'Players missing name';
      case ParseIssueCategory.missingPlayerClass:
        return 'Players missing class';
      case ParseIssueCategory.invalidPlayerClass:
        return 'Invalid player classes';
      case ParseIssueCategory.missingDateOfBirth:
        return 'Players missing date of birth';
      case ParseIssueCategory.missingRequiredColumn:
        return 'Required columns missing';
      case ParseIssueCategory.fileUnreadable:
        return 'File could not be read';
      case ParseIssueCategory.emptyFile:
        return 'Empty spreadsheet';
      case ParseIssueCategory.unknownTeam:
      case ParseIssueCategory.duplicateShirtNumber:
        return 'Other issues';
    }
  }

  String get _categoryHint {
    switch (category) {
      case ParseIssueCategory.missingShirtNumber:
        return 'Add a shirt number for each player in the spreadsheet.';
      case ParseIssueCategory.missingPlayerName:
        return 'Fill the surname and first name columns.';
      case ParseIssueCategory.missingPlayerClass:
        return 'Add player_class for each athlete (1.0, 1.5, 2.0, 2.5, 3.0, 3.5, 4.0, 4.5).';
      case ParseIssueCategory.invalidPlayerClass:
        return 'Use only the IWBF values: 1.0, 1.5, 2.0, 2.5, 3.0, 3.5, 4.0, 4.5.';
      case ParseIssueCategory.missingDateOfBirth:
        return 'Fill dob using YYYY-MM-DD or DD/MM/YYYY.';
      case ParseIssueCategory.missingRequiredColumn:
        return 'Make sure the required columns are present in the header row.';
      case ParseIssueCategory.fileUnreadable:
        return 'The file could not be parsed as .xlsx.';
      case ParseIssueCategory.emptyFile:
        return 'The spreadsheet has no data rows.';
      case ParseIssueCategory.unknownTeam:
      case ParseIssueCategory.duplicateShirtNumber:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                const Icon(Icons.error_outline, color: IwbfColors.alertRed),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '$_categoryTitle (${issues.length})',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            if (_categoryHint.isNotEmpty) ...<Widget>[
              const SizedBox(height: 8),
              Text(_categoryHint),
            ],
            const SizedBox(height: 12),
            ...issues.map((ParseIssue issue) => _IssueLine(issue: issue)),
          ],
        ),
      ),
    );
  }
}

class _IssueLine extends StatelessWidget {
  const _IssueLine({required this.issue});

  final ParseIssue issue;

  @override
  Widget build(BuildContext context) {
    final List<String> meta = <String>[];
    if (issue.sheetName != null) meta.add('Sheet: ${issue.sheetName}');
    if (issue.teamName != null) meta.add('Team: ${issue.teamName}');
    if (issue.playerLabel != null) meta.add('Player: ${issue.playerLabel}');
    if (issue.rowNumber != null) meta.add('Row: ${issue.rowNumber}');

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text('• ${issue.message}'),
          if (meta.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(left: 16, top: 2),
              child: Text(
                meta.join(' · '),
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Icon(Icons.check_circle_outline,
                size: 48, color: IwbfColors.successGreen),
            const SizedBox(height: 16),
            const Text(
              'No blocking issues to fix.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}
