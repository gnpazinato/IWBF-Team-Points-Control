import 'package:flutter/material.dart';

import '../models/match_state.dart';

/// Placeholder do segundo passo da Fase 3.
///
/// A tela real de controle entra no próximo incremento (quadra central,
/// listas laterais / abas, seleção até 5, alerta de limite, vibração,
/// botões operacionais e wakelock). Por enquanto, apenas confirma que o
/// fluxo Match Setup → Lineup Control chegou ao destino certo.
class LineupControlScreen extends StatelessWidget {
  const LineupControlScreen({super.key, required this.initialState});

  final MatchState initialState;

  @override
  Widget build(BuildContext context) {
    final TextStyle? titleStyle = Theme.of(context).textTheme.titleMedium;
    return Scaffold(
      appBar: AppBar(title: const Text('Lineup Control')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              if (initialState.competitionName != null &&
                  initialState.competitionName!.isNotEmpty)
                Text(
                  'Competition: ${initialState.competitionName}',
                  style: titleStyle,
                ),
              const SizedBox(height: 8),
              Text('Team A: ${initialState.teamA.displayName}',
                  style: titleStyle),
              Text('Team B: ${initialState.teamB.displayName}',
                  style: titleStyle),
              Text(
                'Point Limit: ${initialState.pointLimit.toStringAsFixed(1)}',
              ),
              const SizedBox(height: 16),
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
                          'Lineup control comes next: court, side lists, '
                          'selection up to 5 players, point sum, over-limit '
                          'alert and operational buttons.',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
