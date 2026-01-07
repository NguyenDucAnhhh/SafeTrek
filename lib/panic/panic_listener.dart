import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:volume_controller/volume_controller.dart';

import '../feat/setting/presentation/bloc/settings_bloc.dart';
import '../feat/setting/presentation/bloc/settings_state.dart';
import '../core/widgets/emergency_dialog.dart';

class PanicListener extends StatefulWidget {
  final Widget child;
  const PanicListener({super.key, required this.child});

  @override
  State<PanicListener> createState() => _PanicListenerState();
}

class _PanicListenerState extends State<PanicListener> {
  // ===== Logic đếm =====
  int _currentPressCount = 0;
  DateTime? _lastPressTime;
  DateTime? _lastEventTime;

  // ===== Power Button =====
  StreamSubscription? _powerSubscription;
  static const _powerChannel = EventChannel('com.example.safetrek_project/power_button');

  // ===== Overlay =====
  bool _showOverlay = false;

  // ===== Settings =====
  bool _isEnabled = false;
  String _method = 'volume';
  int _requiredPresses = 3;

  @override
  void initState() {
    super.initState();

    // ❗ Không khóa volume nữa
    VolumeController().showSystemUI = false;

    VolumeController().listener(_handleVolumeEvent);

    // Lắng nghe sự kiện nút nguồn (Screen ON/OFF)
    _powerSubscription = _powerChannel.receiveBroadcastStream().listen(
      _handlePowerEvent,
      onError: (dynamic error) {
        debugPrint('Power Button Channel Error: $error');
      },
    );

    _updateSettingsFromBloc();
  }

  // ================== HANDLE EVENT ==================
  void _registerPress() {
    if (_showOverlay) return;

    final now = DateTime.now();

    // debounce 150ms
    if (_lastEventTime != null &&
        now.difference(_lastEventTime!) < const Duration(milliseconds: 150)) {
      return;
    }
    _lastEventTime = now;

    // reset nếu quá lâu (2 giây)
    if (_lastPressTime == null ||
        now.difference(_lastPressTime!) > const Duration(milliseconds: 2000)) {
      _currentPressCount = 1;
    } else {
      _currentPressCount++;
    }
    _lastPressTime = now;

    debugPrint(
        "🔥 Panic Count: $_currentPressCount / $_requiredPresses (Method: $_method)");

    if (_currentPressCount >= _requiredPresses) {
      _triggerEmergency();
    }
  }

  void _handleVolumeEvent(double volume) {
    if (!_isEnabled || _method != 'volume') return;
    _registerPress();
  }

  void _handlePowerEvent(dynamic event) {
    if (!_isEnabled || _method != 'power') return;
    // event là 'android.intent.action.SCREEN_OFF' hoặc 'ON'
    _registerPress();
  }

  // ================== EMERGENCY ==================
  void _triggerEmergency() {
    debugPrint("🚨 KÍCH HOẠT PANIC!");

    if (_method == 'volume') {
      // 👉 Reset volume 1 LẦN DUY NHẤT khi panic
      VolumeController().setVolume(0.5);
    }

    if (!mounted) return;

    setState(() {
      _showOverlay = true;
      _currentPressCount = 0;
    });

  }

  // ================== SETTINGS ==================
  void _updateSettingsFromBloc() {
    final state = context.read<SettingsBloc>().state;
    if (state is HiddenPanicSettingsLoaded) {
      _applySettings(state);
    }
  }

  void _applySettings(HiddenPanicSettingsLoaded state) {
    setState(() {
      _isEnabled = state.isEnabled;
      _method = state.method;
      _requiredPresses = state.pressCount;
    });
  }

  @override
  void dispose() {
    VolumeController().removeListener();
    _powerSubscription?.cancel();
    super.dispose();
  }

  // ================== UI ==================
  @override
  Widget build(BuildContext context) {
    return BlocListener<SettingsBloc, SettingsState>(
      listener: (context, state) {
        if (state is HiddenPanicSettingsLoaded) {
          _applySettings(state);
        }
      },
      child: Stack(
        children: [
          widget.child,

          if (_showOverlay)
            Positioned.fill(
              child: Container(
                color: Colors.black54,
                child: Center(
                  child: Material(
                    color: Colors.transparent,
                    // ✅ Cập nhật: Truyền callback onDismiss để tắt overlay
                    child: EmergencyDialog(
                      onDismiss: () {
                        setState(() {
                          _showOverlay = false;
                        });
                      },
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
