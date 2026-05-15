import 'package:wakelock_plus/wakelock_plus.dart';

/// Wrapper mockável para `wakelock_plus`.
///
/// Mantido como classe (em vez de chamada direta a `WakelockPlus`) para
/// permitir widget tests sem `MissingPluginException` no ambiente de
/// teste — basta injetar uma subclasse no-op.
class WakelockController {
  const WakelockController();

  Future<void> enable() async {
    try {
      await WakelockPlus.enable();
    } catch (_) {
      // Sem plataforma (test env, web headless) — no-op.
    }
  }

  Future<void> disable() async {
    try {
      await WakelockPlus.disable();
    } catch (_) {
      // Sem plataforma (test env, web headless) — no-op.
    }
  }
}
