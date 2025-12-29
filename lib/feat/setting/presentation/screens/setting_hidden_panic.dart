import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:volume_watcher/volume_watcher.dart';
import 'package:safetrek_project/core/widgets/secondary_header.dart';

import '../../../../core/widgets/emergency_dialog.dart';

enum ActivationMethod {
  volumeUp,
  volumeDown,
}

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
  int? _volumeListenerId;
  bool _dialogShowing = false;
  static const int _timeoutMs = 2000;

  static const _keyEnabled = 'hidden_panic_enabled';
  static const _keyMethod = 'hidden_panic_method';
  static const _keyCount = 'hidden_panic_count';

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  @override
  void dispose() {
    _stopListening();
    super.dispose();
  }

  // ================= STORAGE =================

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      _isEnabled = prefs.getBool(_keyEnabled) ?? false;

      final methodIndex = prefs.getInt(_keyMethod);
      if (methodIndex != null &&
          methodIndex < ActivationMethod.values.length) {
        _selectedMethod = ActivationMethod.values[methodIndex];
      }

      _selectedCount = prefs.getInt(_keyCount) ?? 5;
    });

    if (_isEnabled) {
      _startListening();
    }
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyEnabled, _isEnabled);
    await prefs.setInt(_keyMethod, _selectedMethod.index);
    await prefs.setInt(_keyCount, _selectedCount);
  }

  // ================= VOLUME LISTENER =================

  void _startListening() async {
    if (_isListening) return;

    _lastVolume = await VolumeWatcher.getCurrentVolume;
    _volumeListenerId = VolumeWatcher.addListener(_onVolumeChanged);

    _isListening = true;
  }

  void _stopListening() {
    if (!_isListening) return;

    if (_volumeListenerId != null) {
      VolumeWatcher.removeListener(_volumeListenerId);
      _volumeListenerId = null;
    }

    _isListening = false;
    _resetCounter();
  }

  void _onVolumeChanged(double volume) {
    debugPrint('🔊 Volume changed: $volume');

    if (!_isEnabled) return;

    final isVolumeUp = volume > _lastVolume;
    final isVolumeDown = volume < _lastVolume;

    debugPrint('⬆️ Up: $isVolumeUp | ⬇️ Down: $isVolumeDown');

    _lastVolume = volume;

    if (_selectedMethod == ActivationMethod.volumeUp && !isVolumeUp) return;
    if (_selectedMethod == ActivationMethod.volumeDown && !isVolumeDown) return;

    final now = DateTime.now();

    if (_lastPressTime == null ||
        now.difference(_lastPressTime!).inMilliseconds > _timeoutMs) {
      _pressCount = 0;
    }

    _pressCount++;
    _lastPressTime = now;

    debugPrint('🔢 Count: $_pressCount');

    if (_pressCount >= _selectedCount) {
      _triggerSOS();
      _resetCounter();
    }
  }


  void _resetCounter() {
    _pressCount = 0;
    _lastPressTime = null;
  }

  void _triggerSOS() {
    if (!mounted || _dialogShowing) return;

    _dialogShowing = true;

    debugPrint('🚨 SOS TRIGGERED');

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const EmergencyDialog(),
    ).then((_) {
      _dialogShowing = false;
    });
  }


  // ================= UI =================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F5FF),
      appBar: SecondaryHeader(title: 'Nút hoảng loạn ẩn'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: [
            const SizedBox(height: 8),
            _buildToggleCard(),
            const SizedBox(height: 16),
            if (_isEnabled) ...[
              _buildActivationOption(
                icon: Icons.volume_up,
                title: 'Tăng âm lượng',
                subtitle: 'Nhấn tăng âm lượng liên tục',
                value: ActivationMethod.volumeUp,
              ),
              const SizedBox(height: 16),
              _buildActivationOption(
                icon: Icons.volume_down,
                title: 'Giảm âm lượng',
                subtitle: 'Nhấn giảm âm lượng liên tục',
                value: ActivationMethod.volumeDown,
              ),
            ],
          ],
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
      ),
      child: Row(
        children: [
          const Expanded(
            child: Text(
              'Bật nút hoảng loạn ẩn',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          Switch(
            value: _isEnabled,
            onChanged: (value) async {
              setState(() => _isEnabled = value);
              await _saveSettings();
              value ? _startListening() : _stopListening();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildActivationOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required ActivationMethod value,
  }) {
    final isSelected = _selectedMethod == value;

    return GestureDetector(
      onTap: () async {
        setState(() => _selectedMethod = value);
        await _saveSettings();
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: isSelected
              ? Border.all(color: const Color(0xFF4F46E5), width: 1.5)
              : null,
        ),
        child: Column(
          children: [
            Row(
              children: [
                Icon(icon),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title,
                          style:
                          const TextStyle(fontWeight: FontWeight.bold)),
                      Text(subtitle,
                          style: const TextStyle(fontSize: 13)),
                    ],
                  ),
                ),
                Radio<ActivationMethod>(
                  value: value,
                  groupValue: _selectedMethod,
                  onChanged: (_) async {
                    setState(() => _selectedMethod = value);
                    await _saveSettings();
                  },
                ),
              ],
            ),
            if (isSelected) ...[
              const SizedBox(height: 12),
              Row(
                children: [3, 5, 7].map(_buildCountButton).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCountButton(int count) {
    final isSelected = _selectedCount == count;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ElevatedButton(
        onPressed: () async {
          setState(() => _selectedCount = count);
          await _saveSettings();
        },
        style: ElevatedButton.styleFrom(
          backgroundColor:
          isSelected ? const Color(0xFF4F46E5) : Colors.grey.shade300,
        ),
        child: Text('${count}x'),
      ),
    );
  }
}
