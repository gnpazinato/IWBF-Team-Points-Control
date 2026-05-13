import 'package:flutter/material.dart';

import '../models/player.dart';
import '../theme/iwbf_theme.dart';

const String kTeamAMenAsset = 'assets/images/team-a-men.png';
const String kTeamAWomenAsset = 'assets/images/team-a-women.png';
const String kTeamBMenAsset = 'assets/images/team-b-men.png';
const String kTeamBWomenAsset = 'assets/images/team-b-women.png';

/// Resolve o asset do uniforme com base no time (claro/escuro) e gênero.
///
/// Quando `gender` é `PlayerGender.unspecified` cai no ícone masculino
/// (decisão registrada no `AI_WORK_LOG`: o "padrão da equipe" é masculino).
String resolveJerseyAsset({
  required bool isTeamA,
  required PlayerGender gender,
}) {
  if (gender == PlayerGender.female) {
    return isTeamA ? kTeamAWomenAsset : kTeamBWomenAsset;
  }
  return isTeamA ? kTeamAMenAsset : kTeamBMenAsset;
}

/// Ícone do uniforme de um atleta com número da camiseta sobreposto.
///
/// Reaproveita os assets `team-a-men.png`, `team-a-women.png`,
/// `team-b-men.png` e `team-b-women.png` (256x256, sem número embutido).
/// Quando `gender` está ausente cai no ícone masculino (default da equipe).
///
/// O número aparece centrado horizontalmente sobre o peito da camiseta:
/// preto em camisetas claras (Team A) e branco em camisetas escuras
/// (Team B), com `FilterQuality.high` para reduzir a percepção de blur.
class PlayerJerseyIcon extends StatelessWidget {
  const PlayerJerseyIcon({
    super.key,
    required this.player,
    required this.isTeamA,
    this.size = 40,
  });

  final Player player;
  final bool isTeamA;
  final double size;

  @override
  Widget build(BuildContext context) {
    final String asset =
        resolveJerseyAsset(isTeamA: isTeamA, gender: player.gender);
    final Color numberColor =
        isTeamA ? IwbfColors.textPrimary : Colors.white;
    // O peito da camiseta nos PNGs fica em y ≈ 0.40 (Alignment y ≈ -0.20).
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          Image.asset(
            asset,
            fit: BoxFit.contain,
            filterQuality: FilterQuality.high,
            semanticLabel:
                'Player ${player.shirtNumber} jersey '
                '(${isTeamA ? 'Team A' : 'Team B'})',
          ),
          Align(
            alignment: const Alignment(0, -0.20),
            child: Text(
              '${player.shirtNumber}',
              style: TextStyle(
                color: numberColor,
                fontWeight: FontWeight.w900,
                fontSize: size * 0.32,
                height: 1,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
