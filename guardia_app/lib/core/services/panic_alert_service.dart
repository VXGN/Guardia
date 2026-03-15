import 'package:vibration/vibration.dart';
import 'dart:async';

class PanicAlertService {
  bool _isAlerting = false;

  Future<void> start() async {
    if (_isAlerting) return;
    _isAlerting = true;

    // Start vibration with a repeating emergency pattern
    // [wait, vibrate, wait, vibrate, ...]
    _startVibration();
  }

  void _startVibration() async {
    if (await Vibration.hasVibrator() ?? false) {
      // Emergency pattern: 500ms vibrate, 200ms pause, 500ms vibrate, 1000ms pause
      Vibration.vibrate(
        pattern: [0, 500, 200, 500, 200, 500, 1000],
        repeat: 0, // repeat indefinitely
      );
    }
  }

  Future<void> stop() async {
    _isAlerting = false;
    Vibration.cancel();
  }

  void dispose() {
    Vibration.cancel();
  }
}
