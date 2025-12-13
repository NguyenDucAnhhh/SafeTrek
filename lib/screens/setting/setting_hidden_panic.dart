import 'package:flutter/material.dart';
import 'package:safetrek_project/widgets/app_bar.dart';
import 'package:safetrek_project/widgets/bottom_navigation.dart';

class SettingHiddenPanic extends StatefulWidget {
  const SettingHiddenPanic({super.key});

  @override
  State<SettingHiddenPanic> createState() => _SettingHiddenPanicState();
}

class _SettingHiddenPanicState extends State<SettingHiddenPanic> {
  bool _isEnabled = false;

  int _selectedIndex = 2;
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(16.0);

    return Scaffold(
      appBar: const CustomAppBar(),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFF7F9FF), Color(0xFFE8EEFF)],
          ),
        ),
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
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
              const SizedBox(height: 6),

              // Header card (icon + title + subtitle)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: radius,
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 14, offset: const Offset(0, 8)),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(colors: [Color(0xFFFFECEA), Color(0xFFFFF1F0)]),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Center(
                        child: Icon(Icons.flash_on, color: Color(0xFFEF4444), size: 26),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'Nút Hoảng loạn Ẩn',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Color(0xFF101828)),
                          ),
                          SizedBox(height: 6),
                          Text(
                            'Kích hoạt cảnh báo bí mật',
                            style: TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Card with toggle
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: radius,
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 18, offset: const Offset(0, 8)),
                  ],
                ),
                child: Row(
                  children: [
                    // left column: label + description
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'Bật Nút Hoảng loạn Ẩn',
                            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFF101828)),
                          ),
                          SizedBox(height: 6),
                          Text(
                            'Kích hoạt cảnh báo khẩn cấp mà không cần mở ứng dụng',
                            style: TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
                          ),
                        ],
                      ),
                    ),

                    // Switch
                    Container(
                      padding: const EdgeInsets.only(left: 12),
                      child: Switch(
                        value: _isEnabled,
                        onChanged: (v) => setState(() => _isEnabled = v),
                        activeColor: Colors.white,
                        activeTrackColor: const Color(0xFF6EE7B7),
                        inactiveTrackColor: const Color(0xFFE6E6E6),
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Info box (blue)
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFCCE7FF)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(top: 2, right: 8),
                      child: Icon(Icons.info_outline, color: Color(0xFF1E88E5), size: 20),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'Nút hoảng loạn ẩn là gì?',
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF1E3A8A)),
                          ),
                          SizedBox(height: 6),
                          Text(
                            'Cho phép bạn kích hoạt cảnh báo khẩn cấp một cách bí mật thông qua các thao tác đặc biệt, rất hữu ích khi bạn không thể mở ứng dụng một cách rõ ràng.',
                            style: TextStyle(fontSize: 13, color: Color(0xFF1E3A8A), height: 1.35),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 120), // space so content not hidden behind button
            ],
          ),
        ),
      ),

      // Bottom fixed save button (like in screenshot)
      bottomSheet: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        color: Colors.transparent,
        child: SizedBox(
          height: 56,
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              // TODO: lưu cài đặt
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(_isEnabled ? 'Đã bật Nút Hoảng loạn Ẩn' : 'Đã tắt Nút Hoảng loạn Ẩn')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6D28D9), // purple
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 6,
            ),
            child: const Text(
              'Lưu Cài đặt',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigation(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
