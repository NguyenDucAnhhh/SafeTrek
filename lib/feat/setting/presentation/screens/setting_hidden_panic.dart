import 'package:flutter/material.dart';
import 'package:safetrek_project/core/widgets/secondary_header.dart';

enum ActivationMethod { volume, power }

class SettingHiddenPanic extends StatefulWidget {
  const SettingHiddenPanic({super.key});

  @override
  State<SettingHiddenPanic> createState() => _SettingHiddenPanicState();
}

class _SettingHiddenPanicState extends State<SettingHiddenPanic> {
  bool _isEnabled = false;
  ActivationMethod _selectedMethod = ActivationMethod.volume;
  int _selectedCount = 5;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FF),
      appBar: SecondaryHeader(title: 'Nút hoảng loạn ẩn'),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _headerCard(),
          const SizedBox(height: 16),
          _toggleCard(),
          if (_isEnabled) ...[
            const SizedBox(height: 16),
            _infoCard(),
            const SizedBox(height: 24),
            _sectionTitle('Cách kích hoạt'),
            const SizedBox(height: 12),
            _activationCard(
              icon: Icons.volume_up_rounded,
              title: 'Phím âm lượng',
              subtitle: 'Nhấn tăng/giảm âm lượng liên tục',
              value: ActivationMethod.volume,
            ),
            const SizedBox(height: 12),
            _activationCard(
              icon: Icons.power_settings_new_rounded,
              title: 'Nút nguồn (Power)',
              subtitle: 'Nhấn nút Power liên tục',
              value: ActivationMethod.power,
            ),
            const SizedBox(height: 20),
            _warningCard(),
          ],
        ],
      ),
    );
  }

  // ================= UI COMPONENTS =================

  Widget _headerCard() {
    return _card(
      child: Row(
        children: [
          _iconBox(Icons.flash_on_rounded, Colors.red.shade100, Colors.red),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Nút hoảng loạn ẩn',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                SizedBox(height: 4),
                Text(
                  'Kích hoạt cảnh báo bí mật trong tình huống nguy hiểm',
                  style: TextStyle(fontSize: 13, color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _toggleCard() {
    return _card(
      child: Row(
        children: [
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Bật tính năng',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                SizedBox(height: 4),
                Text(
                  'Kích hoạt nhanh mà không cần mở ứng dụng',
                  style: TextStyle(fontSize: 13, color: Colors.grey),
                ),
              ],
            ),
          ),
          Switch.adaptive(
            value: _isEnabled,
            onChanged: (v) => setState(() => _isEnabled = v),
            activeColor: const Color(0xFF4F46E5),
          ),
        ],
      ),
    );
  }

  Widget _infoCard() {
    return _card(
      color: const Color(0xFFEEF2FF),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Icon(Icons.info_outline, color: Color(0xFF4F46E5)),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'Tính năng này cho phép gửi cảnh báo khẩn cấp '
                  'một cách kín đáo khi bạn không thể mở ứng dụng.',
              style: TextStyle(height: 1.4, color: Color(0xFF3730A3)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _activationCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required ActivationMethod value,
  }) {
    final selected = _selectedMethod == value;

    return GestureDetector(
      onTap: () => setState(() => _selectedMethod = value),
      child: _card(
        border: selected
            ? Border.all(color: const Color(0xFF4F46E5), width: 1.5)
            : null,
        child: Column(
          children: [
            Row(
              children: [
                _iconBox(icon, const Color(0xFFEEF2FF),
                    const Color(0xFF4F46E5)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title,
                          style: const TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 4),
                      Text(subtitle,
                          style: const TextStyle(
                              fontSize: 13, color: Colors.grey)),
                    ],
                  ),
                ),
                Radio(
                  value: value,
                  groupValue: _selectedMethod,
                  onChanged: (_) =>
                      setState(() => _selectedMethod = value),
                  activeColor: const Color(0xFF4F46E5),
                ),
              ],
            ),
            if (selected) ...[
              const Divider(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Số lần nhấn',
                      style: TextStyle(fontWeight: FontWeight.w500)),
                  Row(
                    children: [3, 5, 7].map(_countButton).toList(),
                  ),
                ],
              ),
            ]
          ],
        ),
      ),
    );
  }

  Widget _countButton(int count) {
    final selected = _selectedCount == count;
    return Padding(
      padding: const EdgeInsets.only(left: 8),
      child: OutlinedButton(
        onPressed: () => setState(() => _selectedCount = count),
        style: OutlinedButton.styleFrom(
          backgroundColor:
          selected ? const Color(0xFF4F46E5) : Colors.white,
          foregroundColor:
          selected ? Colors.white : Colors.grey.shade800,
          side: BorderSide(
              color: selected
                  ? const Color(0xFF4F46E5)
                  : Colors.grey.shade300),
        ),
        child: Text('$count x'),
      ),
    );
  }

  Widget _warningCard() {
    return _card(
      color: const Color(0xFFFFFBEB),
      border: Border.all(color: Colors.amber.shade300),
      child: const Text(
        '⚠️ Cảnh báo được gửi ngay lập tức khi kích hoạt.\n'
            'Hãy cẩn thận tránh thao tác nhầm.',
        style: TextStyle(height: 1.5),
      ),
    );
  }

  // ================= HELPERS =================

  Widget _sectionTitle(String text) => Text(
    text,
    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
  );

  Widget _card({
    required Widget child,
    Color color = Colors.white,
    Border? border,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
        border: border,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _iconBox(IconData icon, Color bg, Color color) {
    return Container(
      width: 44,
      height: 44,
      decoration:
      BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12)),
      child: Icon(icon, color: color),
    );
  }
}
