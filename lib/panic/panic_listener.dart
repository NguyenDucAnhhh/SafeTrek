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
  // Biến logic
  int _currentPressCount = 0;
  DateTime? _lastPressTime;
  DateTime? _lastEventTime;

  // 🚩 THAY VÌ GỌI DIALOG, TA DÙNG BIẾN NÀY ĐỂ HIỆN GIAO DIỆN
  bool _showOverlay = false;

  // Settings
  bool _isEnabled = false;
  String _method = 'volume';
  int _requiredPresses = 3;

  @override
  void initState() {
    super.initState();
    VolumeController().showSystemUI = false;
    VolumeController().setVolume(0.5);
    VolumeController().listener(_handleVolumeEvent);
    _updateSettingsFromBloc();
  }

  void _handleVolumeEvent(double volume) {
    // 1. Nếu đang hiện thông báo rồi thì THÔI KHÔNG ĐẾM NỮA (Chặn lỗi đếm lên 22/3)
    if (_showOverlay) {
      VolumeController().setVolume(0.5);
      return;
    }

    // Logic Mỏ neo (Anchor)
    if (volume > 0.48 && volume < 0.52) return;

    if (!_isEnabled || _method != 'volume') {
      VolumeController().setVolume(0.5);
      return;
    }

    final now = DateTime.now();
    // Debounce 150ms
    if (_lastEventTime != null &&
        now.difference(_lastEventTime!) < const Duration(milliseconds: 150)) {
      VolumeController().setVolume(0.5);
      return;
    }
    _lastEventTime = now;

    // Logic đếm
    if (_lastPressTime == null ||
        now.difference(_lastPressTime!) > const Duration(milliseconds: 1500)) {
      _currentPressCount = 1;
    } else {
      _currentPressCount++;
    }
    _lastPressTime = now;

    debugPrint("🔥 Panic Count: $_currentPressCount / $_requiredPresses");

    VolumeController().setVolume(0.5);

    // Kích hoạt
    if (_currentPressCount >= _requiredPresses) {
      _triggerEmergency();
    }
  }

  void _triggerEmergency() {
    debugPrint("🚨 KÍCH HOẠT OVERLAY!");
    // Thay vì showDialog, ta đổi biến state để UI tự vẽ ra
    if (mounted) {
      setState(() {
        _showOverlay = true;
        _currentPressCount = 0; // Reset đếm
      });

      // Tự động tắt sau 3 giây (Hoặc tùy bạn xử lý)
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) {
          setState(() {
            _showOverlay = false;
          });
        }
      });
    }
  }

  void _updateSettingsFromBloc() {
    final state = context.read<SettingsBloc>().state;
    if (state is HiddenPanicSettingsLoaded) {
      setState(() {
        _isEnabled = state.isEnabled;
        _method = state.method;
        _requiredPresses = state.pressCount;
      });
      if (_isEnabled && _method == 'volume') {
        VolumeController().setVolume(0.5);
      }
    }
  }

  @override
  void dispose() {
    VolumeController().removeListener();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<SettingsBloc, SettingsState>(
      listener: (context, state) {
        if (state is HiddenPanicSettingsLoaded) {
          setState(() {
            _isEnabled = state.isEnabled;
            _method = state.method;
            _requiredPresses = state.pressCount;
          });
          if (_isEnabled && _method == 'volume') {
            VolumeController().setVolume(0.5);
          }
        }
      },
      // ✅ SỬ DỤNG STACK: ĐÂY LÀ CHÌA KHÓA ĐỂ HIỆN LÊN TRÊN MỌI THỨ
      child: Stack(
        textDirection: TextDirection.ltr,
        children: [
          // Lớp dưới: App của bạn
          widget.child,

          // Lớp trên: Thông báo khẩn cấp (Chỉ hiện khi _showOverlay = true)
          if (_showOverlay)
            Positioned.fill(
              child: Container(
                color: Colors.black54, // Màu nền tối mờ
                child: Center(
                  // Dialog của bạn được đặt ở đây
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