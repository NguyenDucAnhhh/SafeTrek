import 'package:flutter/material.dart';
import 'package:safetrek_project/widgets/app_bar.dart';
import 'package:safetrek_project/widgets/bottom_navigation.dart';

class SettingDuressPIN extends StatefulWidget {
  const SettingDuressPIN({super.key});

  @override
  State<SettingDuressPIN> createState() => _SettingDuressPINState();
}

class _SettingDuressPINState extends State<SettingDuressPIN> {

  int _selectedIndex = 2;
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  InputDecoration _inputStyle() {
    return InputDecoration(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFB91C1C)),
      ),
      filled: true,
      fillColor: Colors.white,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(),
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFF7F9FF),
              Color(0xFFE3E9FF),
            ],
          ),
        ),
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            children: [
              // Back row
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

              Center(
                child: Container(
                  padding: const EdgeInsets.all(20),
                  constraints: const BoxConstraints(maxWidth: 520),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.07),
                        blurRadius: 25,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 46,
                            height: 46,
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFE2E2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.report_problem_outlined,
                                size: 28, color: Color(0xFFB91C1C)),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text(
                                "Mã PIN Bị ép buộc",
                                style: TextStyle(
                                    fontSize: 17, fontWeight: FontWeight.w600),
                              ),
                              SizedBox(height: 2),
                              Text(
                                "Khi bị ép buộc tắt app",
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Color(0xFF6B7280),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),

                      const SizedBox(height: 22),

                      const Text(
                        "Tạo mã PIN mới (4 chữ số)",
                        style: TextStyle(
                          fontSize: 13,
                          color: Color(0xFF4B5563),
                        ),
                      ),

                      const SizedBox(height: 8),

                      TextField(
                        keyboardType: TextInputType.number,
                        maxLength: 4,
                        textAlign: TextAlign.center,
                        decoration: _inputStyle().copyWith(counterText: ""),
                        style: const TextStyle(letterSpacing: 4, fontSize: 20, fontWeight: FontWeight.w600,),
                      ),

                      const SizedBox(height: 14),

                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: (){},
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                            backgroundColor: const Color(0xFFB91C1C),
                            elevation: 3,
                            shadowColor: Colors.black26,
                          ),
                          child: const Text(
                            "Lưu mã PIN",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFE2E2),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFF472B6)),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.report_problem_outlined,
                                size: 18, color: Color(0xFFB91C1C)),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                "App sẽ giả vờ tắt nhưng gửi cảnh báo ngầm đến người bảo vệ",
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Color(0xFFB91C1C),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
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
}
