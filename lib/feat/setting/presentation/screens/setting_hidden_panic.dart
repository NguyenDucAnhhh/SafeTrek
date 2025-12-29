import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:volume_controller/volume_controller.dart';
import 'package:safetrek_project/core/widgets/secondary_header.dart';

import '../../../../core/widgets/emergency_dialog.dart';
import '../bloc/settings_bloc.dart';
import '../bloc/settings_event.dart';
import '../bloc/settings_state.dart';

enum ActivationMethod { volumeUp, volumeDown }

class SettingHiddenPanic extends StatefulWidget {
  const SettingHiddenPanic({super.key});

  @override
  State<SettingHiddenPanic> createState() => _SettingHiddenPanicState();
}

class _SettingHiddenPanicState extends State<SettingHiddenPanic> {
  bool _isEnabled = false;
  ActivationMethod _selectedMethod = ActivationMethod.volumeUp;
  int _selectedCount = 5;

  int _pressCount = 0;
  DateTime? _lastPressTime;
  double _lastVolume = 0;
  bool _isListening = false;
  bool _dialogShowing = false;
  static const int _timeoutMs = 2000;

  static const _keyMethod = 'hidden_panic_method';
  static const _keyCount = 'hidden_panic_count';

  @override
  void initState() {
    super.initState();
    context.read<SettingsBloc>().add(LoadHiddenPanicEvent());
    _loadExtraSettings();
  }

  @override
  void dispose() {
    _stopListening();
    super.dispose();
  }

  Future<void> _loadExtraSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _selectedCount = prefs.getInt(_keyCount) ?? 5;
      final methodStr = prefs.getString(_keyMethod) ?? 'volumeUp';
      _selectedMethod = methodStr == 'volumeUp'
          ? ActivationMethod.volumeUp
          : ActivationMethod.volumeDown;
    });
  }

  Future<void> _saveExtraSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyCount, _selectedCount);
    await prefs.setString(_keyMethod, _selectedMethod.name);
  }

  // ================= VOLUME LISTENER =================

  Future<void> _startListening() async {
    if (_isListening) return;
    _isListening = true;
    _lastVolume = await VolumeController().getVolume();
    VolumeController().listener((volume) => _onVolumeChanged(volume));
  }

  void _stopListening() {
    VolumeController().removeListener();
    _isListening = false;
    _pressCount = 0;
    _lastPressTime = null;
  }

  void _onVolumeChanged(double volume) {
    if (!_isEnabled || _dialogShowing) return;

    final bool isUp = volume > _lastVolume || (volume == 1.0 && _lastVolume == 1.0);
    final bool isDown = volume < _lastVolume || (volume == 0.0 && _lastVolume == 0.0);
    _lastVolume = volume;

    bool isCorrectMethod = (_selectedMethod == ActivationMethod.volumeUp && isUp) ||
        (_selectedMethod == ActivationMethod.volumeDown && isDown);

    if (!isCorrectMethod) return;

    final now = DateTime.now();
    if (_lastPressTime == null || now.difference(_lastPressTime!).inMilliseconds > _timeoutMs) {
      _pressCount = 0;
    }

    _pressCount++;
    _lastPressTime = now;

    if (_pressCount >= _selectedCount) {
      _triggerSOS();
      _pressCount = 0;
    }
  }

  void _triggerSOS() {
    if (_dialogShowing) return;
    _dialogShowing = true;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => EmergencyDialog(
        onDismiss: () => _dialogShowing = false,
      ),
    ).then((_) => _dialogShowing = false);
  }

  // ================= UI BUILDERS =================

  @override
  Widget build(BuildContext context) {
    return BlocListener<SettingsBloc, SettingsState>(
      listener: (context, state) {
        if (state is HiddenPanicLoaded) {
          if (_isEnabled != state.enabled) {
            setState(() => _isEnabled = state.enabled);
            state.enabled ? _startListening() : _stopListening();
          }
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF3F5FF),
        appBar: const SecondaryHeader(title: 'Nút hoảng loạn ẩn'),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              _buildToggleCard(),
              const SizedBox(height: 16),
              _buildImportantNoteCard(),
              const SizedBox(height: 24),
              if (_isEnabled) _buildActivationOptions(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildToggleCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 46, height: 46,
            decoration: BoxDecoration(
              color: const Color(0xFFFFE8E8),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.flash_on_outlined, color: Color(0xFFF53E3E), size: 26),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Nút Hoảng Loạn Ẩn', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF111827))),
                SizedBox(height: 4),
                Text('Kích hoạt cảnh báo bí mật', style: TextStyle(fontSize: 13, color: Color(0xFF6A7282))),
              ],
            ),
          ),
          Switch(
            value: _isEnabled,
            activeColor: const Color(0xFFF53E3E),
            onChanged: (value) {
              setState(() => _isEnabled = value);
              context.read<SettingsBloc>().add(ToggleHiddenPanicEvent(value));
              value ? _startListening() : _stopListening();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildActivationOptions() {
    return Column(
      children: [
        _buildMethodTile('Phím Tăng âm lượng', ActivationMethod.volumeUp),
        const SizedBox(height: 16),
        _buildMethodTile('Phím Giảm âm lượng', ActivationMethod.volumeDown),
      ],
    );
  }

  Widget _buildMethodTile(String title, ActivationMethod method) {
    final isSelected = _selectedMethod == method;
    return GestureDetector(
      onTap: () {
        setState(() => _selectedMethod = method);
        _saveExtraSettings();
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isSelected ? const Color(0xFFF53E3E) : Colors.transparent, width: 1.5),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Icon(isSelected ? Icons.radio_button_checked : Icons.radio_button_off, color: isSelected ? const Color(0xFFF53E3E) : Colors.grey),
                const SizedBox(width: 12),
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
            if (isSelected) ...[
              const Divider(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [3, 5, 7].map((count) => ChoiceChip(
                  label: Text('${count}x'),
                  selected: _selectedCount == count,
                  selectedColor: const Color(0xFFFFE8E8),
                  labelStyle: TextStyle(color: _selectedCount == count ? const Color(0xFFF53E3E) : Colors.black),
                  onSelected: (_) {
                    setState(() => _selectedCount = count);
                    _saveExtraSettings();
                  },
                )).toList(),
              )
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildImportantNoteCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFEFCE8),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFDE047).withOpacity(0.8)),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline, color: Color(0xFFB45309), size: 20),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Lưu ý quan trọng:', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                SizedBox(height: 8),
                Text('• Cảnh báo sẽ được gửi ngay lập tức khi kích hoạt', style: TextStyle(fontSize: 13, height: 1.5)),
                Text('• Không có xác nhận, hãy cẩn thận tránh kích hoạt nhầm', style: TextStyle(fontSize: 13, height: 1.5)),
                Text('• Hoạt động ngay cả khi ứng dụng đang chạy nền', style: TextStyle(fontSize: 13, height: 1.5)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}