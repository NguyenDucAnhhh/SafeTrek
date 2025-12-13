import 'package:flutter/material.dart';
import 'package:safetrek_project/widgets/app_bar.dart';
import 'package:safetrek_project/widgets/bottom_navigation.dart';
import 'package:safetrek_project/widgets/action_card.dart';
import 'package:safetrek_project/screens/setting/setting_profile.dart';
import 'package:safetrek_project/screens/setting/setting_safePIN.dart';
import 'package:safetrek_project/screens/setting/setting_duressPIN.dart';
import 'package:safetrek_project/screens/setting/setting_hidden_panic.dart';

class Setting extends StatefulWidget {
  const Setting({super.key});

  @override
  State<Setting> createState() => _SettingState();
}

class _SettingState extends State<Setting> {
  bool _hasProfile = false;
  bool _hasSafePin = false;
  bool _hasDuressPin = false;
  bool _isStealthPanicOn = false;

  int _selectedIndex = 2;
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: const Alignment(0.00, 0.30),
            end: const Alignment(1.00, 0.70),
            colors: [const Color(0xFFEFF6FF), const Color(0xFFE0E7FF)],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ActionCard(
                icon: Icons.person_outlined,
                iconColor: const Color(0xFF1B388E),
                iconBgColor: const Color(0xFFDBEAFE),
                title: 'Thông tin cá nhân',
                subtitle: _hasProfile ? 'Đã cài đặt' : 'Chưa cài đặt',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const SettingProfile()),
                  );
                },
              ),

              ActionCard(
                icon: Icons.shield_outlined,
                iconColor: const Color(0xFF0B7A4A),
                iconBgColor: const Color(0xFFDCFCE7),
                title: 'Mã PIN An toàn',
                subtitle: _hasSafePin ? 'Đã cài đặt' : 'Chưa cài đặt',
                onTap: (){
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const SettingSafePIN()),
                  );
                },
              ),

              ActionCard(
                icon: Icons.report_problem_outlined,
                iconColor: const Color(0xFFB91C1C),
                iconBgColor: const Color(0xFFFFE2E2),
                title: 'Mã PIN Bị ép buộc',
                subtitle: _hasDuressPin ? 'Đã cài đặt' : 'Chưa cài đặt',
                onTap: (){
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const SettingDuressPIN()),
                  );
                },
              ),

              ActionCard(
                icon: Icons.flash_on_outlined,
                iconColor: const Color(0xFFB91C1C),
                iconBgColor: const Color(0xFFFFE2E2),
                title: 'Nút Hoảng loạn Ẩn',
                subtitle: _isStealthPanicOn ? 'Đang bật' : 'Chưa bật',
                onTap: (){
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const SettingHiddenPanic()),
                  );
                },
              ),

              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFEBF5FF),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Colors.blue.shade100),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: const [
                        Icon(Icons.lightbulb_outline,
                            color: Colors.orange, size: 20),
                        SizedBox(width: 8),
                        Text(
                          "Lời khuyên bảo mật",
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF004085)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    _buildBulletPoint("Chọn mã PIN dễ nhớ nhưng khó đoán"),
                    _buildBulletPoint("Không dùng mã quá đơn giản (1111, 1234)"),
                    _buildBulletPoint("Ghi nhớ cả hai mã PIN"),
                    _buildBulletPoint("Không chia sẻ mã PIN với ai"),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigation(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }

  Widget _buildBulletPoint(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("• ",
              style: TextStyle(color: Color(0xFF004085), fontWeight: FontWeight.bold)),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(color: Color(0xFF004085), fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}
