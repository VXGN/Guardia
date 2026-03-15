import 'package:vibration/vibration.dart';
import 'dart:async';
import 'package:flutter/services.dart';

class PanicAlertService {
  bool _isAlerting = false;

  Future<void> start() async {
    if (_isAlerting) return;
    _isAlerting = true;

    await _startVibration();
  }

  Future<void> _startVibration() async {
    try {
      if (await Vibration.hasVibrator() ?? false) {
        // Emergency pattern: 500ms vibrate, 200ms pause, 500ms vibrate, 1000ms pause
        await Vibration.vibrate(
          pattern: [0, 500, 200, 500, 200, 500, 1000],
          repeat: 0, // repeat indefinitely
        );
      }
    } on MissingPluginException {
      _isAlerting = false;
    } catch (_) {
      _isAlerting = false;
    }
  }

  Future<void> stop() async {
    _isAlerting = false;
    try {
      await Vibration.cancel();
    } on MissingPluginException {
      // Safe fallback for platforms/builds where vibration plugin is unavailable.
    } catch (_) {
      // Keep stop best-effort; alert shutdown should never throw.
    }
  }

  Future<void> dispose() async {
    await stop();
  }
}
