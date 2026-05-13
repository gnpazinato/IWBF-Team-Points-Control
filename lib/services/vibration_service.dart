import 'package:vibration/vibration.dart';

/// Disparador de vibração leve usado pela tela de partida quando uma
/// equipe cruza o limite de pontos.
///
/// É instanciada como serviço (não acesso estático) para que widget
/// tests injetem uma fake e contem chamadas sem tocar no plugin.
class VibrationService {
  const VibrationService();

  /// Vibra por aproximadamente 1.5s, suficiente para chamar atenção
  /// sem assustar. Engole erros silenciosamente — em alvos sem
  /// vibrador (web, emuladores, ambiente de teste) é no-op.
  Future<void> shortBuzz() async {
    try {
      final bool hasVibrator = await Vibration.hasVibrator();
      if (hasVibrator) {
        await Vibration.vibrate(duration: 1500);
      }
    } catch (_) {
      // Plugin indisponível (web, test env) — silencioso por design.
    }
  }
}
