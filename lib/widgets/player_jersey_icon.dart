import 'package:flutter/material.dart';

import '../models/player.dart';
import '../theme/iwbf_theme.dart';

/// Ícone vetorial de uma camiseta de basquete (tank top) com o número
/// da camiseta sobre o peito.
///
/// Desenhada com `CustomPainter` para ficar nítida em qualquer tamanho.
/// Substitui os antigos PNGs de cadeira-de-rodas, que eram pesados e
/// disputavam atenção com o número.
///
/// Convenção visual oficial IWBF:
/// - Team A: camiseta clara → preenchimento branco com número preto.
/// - Team B: camiseta escura → preenchimento preto com número branco.
///
/// O `gender` do `Player` é mantido na API por compatibilidade, mas o
/// desenho é neutro de gênero. Não há mais distinção masculino/feminino
/// no ícone (a regra original era condicional ao dado opcional `gender`,
/// e a camiseta vetorial fica mais limpa sem variação).
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
    final Color fill = isTeamA ? Colors.white : IwbfColors.textPrimary;
    final Color text = isTeamA ? IwbfColors.textPrimary : Colors.white;
    const Color border = IwbfColors.goldDeep;

    return SizedBox(
      width: size,
      height: size,
      child: Semantics(
        label: 'Player ${player.shirtNumber} jersey '
            '(${isTeamA ? 'Team A' : 'Team B'})',
        child: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            CustomPaint(
              painter: _JerseyPainter(
                fillColor: fill,
                borderColor: border,
                strokeWidth: size * 0.04,
              ),
            ),
            // Número no peito da camiseta — área entre a base do decote
            // e a barra inferior. `FittedBox` escala para qualquer largura
            // de dígitos (1, 2 ou 3 dígitos) sem cortar. Área generosa
            // para deixar o número como elemento visual dominante.
            Positioned(
              left: size * 0.18,
              right: size * 0.18,
              top: size * 0.38,
              bottom: size * 0.14,
              child: FittedBox(
                fit: BoxFit.contain,
                child: Text(
                  '${player.shirtNumber}',
                  style: TextStyle(
                    color: text,
                    fontWeight: FontWeight.w900,
                    height: 1,
                    letterSpacing: -1,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _JerseyPainter extends CustomPainter {
  _JerseyPainter({
    required this.fillColor,
    required this.borderColor,
    required this.strokeWidth,
  });

  final Color fillColor;
  final Color borderColor;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;

    // Tank top com decote em V e alças sobre os ombros. Pontos em
    // coordenadas normalizadas (0..1) sobre o quadrado do ícone.
    final Path body = Path()
      ..moveTo(w * 0.18, h * 0.22) // ombro esquerdo, lado externo
      ..lineTo(w * 0.35, h * 0.10) // alça esquerda, topo interno
      ..lineTo(w * 0.42, h * 0.22) // decote, topo esquerdo
      ..quadraticBezierTo(
          w * 0.50, h * 0.42, w * 0.58, h * 0.22) // curva do V-neck
      ..lineTo(w * 0.65, h * 0.10) // alça direita, topo interno
      ..lineTo(w * 0.82, h * 0.22) // ombro direito, lado externo
      ..quadraticBezierTo(
          w * 0.83, h * 0.30, w * 0.80, h * 0.40) // cava direita
      ..lineTo(w * 0.90, h * 0.92) // lateral direita, ligeiramente em A-line
      ..lineTo(w * 0.10, h * 0.92) // barra inferior (lado esquerdo)
      ..lineTo(w * 0.20, h * 0.40) // lateral esquerda, A-line
      ..quadraticBezierTo(
          w * 0.17, h * 0.30, w * 0.18, h * 0.22) // cava esquerda
      ..close();

    final Paint fillPaint = Paint()
      ..color = fillColor
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;
    canvas.drawPath(body, fillPaint);

    final Paint borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeJoin = StrokeJoin.round
      ..strokeCap = StrokeCap.round
      ..isAntiAlias = true;
    canvas.drawPath(body, borderPaint);
  }

  @override
  bool shouldRepaint(_JerseyPainter old) =>
      old.fillColor != fillColor ||
      old.borderColor != borderColor ||
      old.strokeWidth != strokeWidth;
}
