import 'package:flutter/material.dart';

import '../models/match_state.dart';
import '../models/team.dart';

/// Placeholder da Fase 3.
///
/// Aceita dois caminhos de entrada:
/// - lista de `teams` (vindo da `ValidationSummaryScreen`);
/// - `restored` (vindo do cache, ao restaurar sessão anterior).
///
/// Renderiza apenas o estado básico recebido. A Fase 3 substitui esta
/// tela pelo fluxo real de seleção de Team A / Team B / Point Limit.
class MatchSetupScreen extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final List<Team> teamsToShow = teams ??
        <Team>[
          if (restored != null) restored!.teamA,
          if (restored != null) restored!.teamB,
        ];
    final String? compName = competitionName ?? restored?.competitionName;

    return Scaffold(
      appBar: AppBar(title: const Text('Match Setup')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              if (compName != null && compName.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    'Competition: $compName',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
              Card(
                color: Colors.amber.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: <Widget>[
                      Icon(Icons.construction, color: Colors.amber.shade800),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: Text(
                          'Match setup will be implemented in Phase 3. '
                          'Below is the data successfully loaded.',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Teams available: ${teamsToShow.length}',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: ListView.builder(
                  itemCount: teamsToShow.length,
                  itemBuilder: (BuildContext context, int index) {
                    final Team team = teamsToShow[index];
                    return Card(
                      child: ListTile(
                        title: Text(team.displayName),
                        subtitle:
                            Text('${team.players.length} player(s)'),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
