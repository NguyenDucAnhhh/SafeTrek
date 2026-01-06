import 'dart:async';
import 'package:flutter/material.dart';
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
    _updateSettingsFromBloc();
  }

  // ================== HANDLE VOLUME ==================
  void _handleVolumeEvent(double volume) {
    if (!_isEnabled || _method != 'volume') return;
    if (_showOverlay) return;

    final now = DateTime.now();

    // debounce 150ms
    if (_lastEventTime != null &&
        now.difference(_lastEventTime!) < const Duration(milliseconds: 150)) {
      return;
    }
    _lastEventTime = now;

    // reset nếu quá lâu
    if (_lastPressTime == null ||
        now.difference(_lastPressTime!) > const Duration(milliseconds: 1500)) {
      _currentPressCount = 1;
    } else {
      _currentPressCount++;
    }
    _lastPressTime = now;

    debugPrint(
        "🔥 Panic Count: $_currentPressCount / $_requiredPresses");

    if (_currentPressCount >= _requiredPresses) {
      _triggerEmergency();
    }
  }

  // ================== EMERGENCY ==================
  void _triggerEmergency() {
    debugPrint("🚨 KÍCH HOẠT PANIC!");

    // 👉 Reset volume 1 LẦN DUY NHẤT khi panic
    VolumeController().setVolume(0.5);

    if (!mounted) return;

    setState(() {
      _showOverlay = true;
      _currentPressCount = 0;
    });

    // Auto hide sau 3s (tùy chỉnh)
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() => _showOverlay = false);
      }
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
                    child: const EmergencyDialog(),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
