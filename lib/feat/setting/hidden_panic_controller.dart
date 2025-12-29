import 'package:volume_controller/volume_controller.dart';

class HiddenPanicController {
  final int requiredPressCount;
  final void Function()? onTriggered;

  int _pressCount = 0;
  DateTime? _lastPressTime;
  double _lastVolume = 0;
  bool _isListening = false;

  static const int _timeoutMs = 2000;

  HiddenPanicController({
    required this.requiredPressCount,
    this.onTriggered,
  });

  /// Bắt đầu lắng nghe
  Future<void> start() async {
    if (_isListening) return;
    _isListening = true;

    // Lấy âm lượng hiện tại làm mốc
    _lastVolume = await VolumeController().getVolume();

    VolumeController().listener((volume) {
      _onVolumeChanged(volume);
    });
  }

  /// Ngừng lắng nghe
  void stop() {
    VolumeController().removeListener();
    _isListening = false;
    _reset();
  }

  void _onVolumeChanged(double volume) {
    if (volume == _lastVolume) return;

    final now = DateTime.now();

    if (_lastPressTime == null ||
        now.difference(_lastPressTime!).inMilliseconds > _timeoutMs) {
      _pressCount = 0;
    }

    _pressCount++;
    _lastPressTime = now;
    _lastVolume = volume;

    if (_pressCount >= requiredPressCount) {
      _triggerSOS();
      _reset();
    }
  }

  void _triggerSOS() {
    onTriggered?.call();
  }

  void _reset() {
    _pressCount = 0;
    _lastPressTime = null;
  }
}