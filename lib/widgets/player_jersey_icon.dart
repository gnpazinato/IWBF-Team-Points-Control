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
/// `team-b-men.png` e `team-b-women.png`. Quando `gender` está ausente
/// cai no ícone masculino (default da equipe).
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
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          Image.asset(
            asset,
            fit: BoxFit.contain,
            semanticLabel:
                'Player ${player.shirtNumber} jersey (${isTeamA ? 'Team A' : 'Team B'})',
          ),
          Padding(
            padding: EdgeInsets.only(top: size * 0.10),
            child: Text(
              '${player.shirtNumber}',
              style: TextStyle(
                color: numberColor,
                fontWeight: FontWeight.w800,
                fontSize: size * 0.30,
                shadows: const <Shadow>[
                  Shadow(
                    blurRadius: 1.5,
                    color: Colors.black26,
                    offset: Offset(0, 1),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
