import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:volume_controller/volume_controller.dart';

import '../feat/setting/presentation/bloc/settings_bloc.dart';
import '../feat/setting/presentation/bloc/settings_state.dart';
import '../core/utils/emergency_utils.dart';

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
  static const _powerChannel =
      EventChannel('com.example.safetrek_project/power_button');

  // ===== Settings =====
  bool _isEnabled = false;
  String _method = 'volume';
  int _requiredPresses = 3;

  // ===== Processing Flag =====
  bool _isProcessingEmergency = false;

  @override
  void initState() {
    super.initState();

    VolumeController().showSystemUI = false;
    VolumeController().listener(_handleVolumeEvent);

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
    // Nếu đang xử lý emergency thì bỏ qua
    if (_isProcessingEmergency) return;

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
    _registerPress();
  }

  // ================== EMERGENCY ==================
  Future<void> _triggerEmergency() async {
    if (_isProcessingEmergency) return; // Prevent double trigger

    debugPrint("🚨 KÍCH HOẠT PANIC!");
    setState(() {
      _isProcessingEmergency = true;
    });

    if (_method == 'volume') {
      VolumeController().setVolume(0.5);
    }

    try {
      // Sử dụng EmergencyUtils để xử lý logic
      await EmergencyUtils.sendTripAlert(context, triggerMethod: 'PanicButton');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('ĐÃ GỬI CẢNH BÁO KHẨN CẤP!'),
          backgroundColor: Colors.red,
        ),
      );
      _currentPressCount = 0;
    } catch (e) {
      debugPrint("Lỗi PanicListener: $e");
    } finally {
      if (mounted) {
        setState(() {
          _isProcessingEmergency = false;
        });
      }
    }
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
      child: widget.child,
    );
  }
}
