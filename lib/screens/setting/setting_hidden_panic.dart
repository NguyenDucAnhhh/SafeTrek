import 'package:flutter/material.dart';
import 'package:safetrek_project/widgets/app_bar.dart';
import 'package:safetrek_project/widgets/bottom_navigation.dart';

// Enum for activation methods to avoid using raw strings
enum ActivationMethod { volume, power }

class SettingHiddenPanic extends StatefulWidget {
  const SettingHiddenPanic({super.key});

  @override
  State<SettingHiddenPanic> createState() => _SettingHiddenPanicState();
}

class _SettingHiddenPanicState extends State<SettingHiddenPanic> {

  int _selectedIndex = 2;
  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
  }

  // --- STATE ---
  bool _isEnabled = false;
  ActivationMethod _selectedMethod = ActivationMethod.volume;
  int _selectedCount = 5;

  // --- BUILD METHOD ---
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F5FF),
      appBar: const CustomAppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            _buildHeader(),
            const SizedBox(height: 24),
            _buildToggleCard(),

            // Conditionally show the rest of the settings
            if (_isEnabled) ...[
              const SizedBox(height: 16),
              _buildInfoCard(),
              const SizedBox(height: 24),
              const Text(
                'Chọn Cách Kích hoạt',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1F2937),
                ),
              ),
              const SizedBox(height: 16),
              _buildActivationOption(
                icon: Icons.volume_up,
                title: 'Phím Âm lượng',
                subtitle: 'Nhấn phím tăng/giảm âm lượng trong 2 giây',
                value: ActivationMethod.volume,
              ),
              const SizedBox(height: 16),
              _buildActivationOption(
                icon: Icons.power_settings_new,
                title: 'Nút Power',
                subtitle: 'Nhấn nút Power trong 2 giây',
                value: ActivationMethod.power,
              ),
              const SizedBox(height: 24),
              _buildImportantNoteCard(),
            ],
            const SizedBox(height: 20), // Spacer for bottom button
          ],
        ),
      ),
    );
  }
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () => Navigator.maybePop(context),
            child: Row(
              children: const [
                Icon(Icons.arrow_back_ios_new,
                    size: 18, color: Color(0xFFF472B6)),
                SizedBox(width: 6),
                Text(
                  "Quay lại",
                  style: TextStyle(
                    color: Color(0xFFF472B6),
                    fontWeight: FontWeight.w500,
                  ),
                )
              ],
            ),
          ),
          const SizedBox(height: 14),

          Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFE8E8),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.flash_on_outlined,
                  color: Color(0xFFF53E3E),
                  size: 26,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Nút Hoảng Loạn Ẩn',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF111827),
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Kích hoạt cảnh báo bí mật',
                      style: TextStyle(
                        fontSize: 13,
                        color: Color(0xFF6A7282),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildToggleCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Bật Nút Hoảng loạn Ẩn',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF101828),
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Kích hoạt cảnh báo khẩn cấp mà không cần mở ứng dụng',
                  style: TextStyle(fontSize: 14, color: Color(0xFF6A7282)),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Switch(
            value: _isEnabled,
            onChanged: (value) {
              setState(() {
                _isEnabled = value;
              });
            },
            activeTrackColor: const Color(0xFF6366F1),
            activeColor: Colors.white,
            inactiveTrackColor: Colors.grey.shade300,
            inactiveThumbColor: Colors.white,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFEEF2FF),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline, color: Color(0xFF4F46E5)),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Nút hoảng loạn ẩn là gì?',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF3730A3),
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'Cho phép bạn kích hoạt cảnh báo khẩn cấp một cách bí mật thông qua các thao tác đặc biệt, rất hữu ích khi bạn không thể mở ứng dụng một cách rõ ràng.',
                  style: TextStyle(fontSize: 14, color: Color(0xFF4338CA), height: 1.4),
                ),
              ],
            ),
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
    final bool isSelected = _selectedMethod == value;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedMethod = value;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: isSelected ? Border.all(color: const Color(0xFF4F46E5), width: 1.5) : null,
          boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.05), blurRadius: 10)],
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEEF2FF),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: const Color(0xFF4F46E5), size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF101828))),
                      const SizedBox(height: 4),
                      Text(subtitle, style: const TextStyle(fontSize: 14, color: Color(0xFF6A7282))),
                    ],
                  ),
                ),
                Radio<ActivationMethod>(
                  value: value,
                  groupValue: _selectedMethod,
                  onChanged: (ActivationMethod? newValue) {
                    setState(() {
                      if (newValue != null) _selectedMethod = newValue;
                    });
                  },
                  activeColor: const Color(0xFF4F46E5),
                ),
              ],
            ),
            if (isSelected) ...[
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Số lần nhấn:', style: TextStyle(fontSize: 15, color: Color(0xFF374151))),
                    Row(
                      children: [
                        _buildCountButton(3),
                        const SizedBox(width: 8),
                        _buildCountButton(5),
                        const SizedBox(width: 8),
                        _buildCountButton(7),
                      ],
                    ),
                  ],
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }

  Widget _buildCountButton(int count) {
    final bool isSelected = _selectedCount == count;
    return ElevatedButton(
      onPressed: () {
        setState(() {
          _selectedCount = count;
        });
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected ? const Color(0xFF4F46E5) : const Color(0xFFF3F4F6),
        foregroundColor: isSelected ? Colors.white : const Color(0xFF374151),
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      ),
      child: Text('${count}x', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
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
          Padding(
            padding: EdgeInsets.only(top: 2.0),
            child: Icon(Icons.info_outline, color: Color(0xFFB45309), size: 20),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Lưu ý quan trọng:',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 8),
                Text('• Cảnh báo sẽ được gửi ngay lập tức khi kích hoạt', style: TextStyle(fontSize: 14, color: Colors.black, height: 1.5)),
                Text('• Không có xác nhận, hãy cẩn thận tránh kích hoạt nhầm', style: TextStyle(fontSize: 14, color: Colors.black, height: 1.5)),
                Text('• Hoạt động ngay cả khi ứng dụng đang chạy nền', style: TextStyle(fontSize: 14, color: Colors.black, height: 1.5)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
