import 'package:volume_watcher/volume_watcher.dart';

class HiddenPanicController {
  final int requiredPressCount;

  int _pressCount = 0;
  DateTime? _lastPressTime;
  bool _isListening = false;

  int? _listenerId; // ✅ FIX

  static const int _timeoutMs = 2000;

  HiddenPanicController({required this.requiredPressCount});

  // ================= START / STOP =================

  void start() {
    if (_isListening) return;
    _isListening = true;

    _listenerId = VolumeWatcher.addListener(_onVolumeChanged);
  }

  void stop() {
    if (!_isListening) return;
    _isListening = false;

    if (_listenerId != null) {
      VolumeWatcher.removeListener(_listenerId);
      _listenerId = null;
    }

    _reset();
  }

  // ================= LISTENER =================

  void _onVolumeChanged(double volume) {
    final now = DateTime.now();

    if (_lastPressTime == null ||
        now.difference(_lastPressTime!).inMilliseconds > _timeoutMs) {
      _pressCount = 0;
    }

    _pressCount++;
    _lastPressTime = now;

    if (_pressCount >= requiredPressCount) {
      _triggerSOS();
      _reset();
    }
  }

  // ================= ACTION =================

  void _triggerSOS() {
    print('🚨 HIDDEN PANIC SOS TRIGGERED');
    // TODO: Firebase / Notification / API
  }

  void _reset() {
    _pressCount = 0;
    _lastPressTime = null;
  }
}
