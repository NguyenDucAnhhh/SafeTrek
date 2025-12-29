import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Thêm Firebase
import 'package:safetrek_project/core/widgets/secondary_header.dart';
import 'package:safetrek_project/feat/setting/domain/entity/user_setting.dart';

class SettingDuressPIN extends StatefulWidget {
  final UserSetting userSetting;
  const SettingDuressPIN({super.key, required this.userSetting});

  @override
  State<SettingDuressPIN> createState() => _SettingDuressPINState();
}

class _SettingDuressPINState extends State<SettingDuressPIN> {
  // Controller cho 3 trường nhập liệu
  late TextEditingController _oldPinController;
  late TextEditingController _newPinController;
  late TextEditingController _confirmPinController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _oldPinController = TextEditingController();
    _newPinController = TextEditingController();
    _confirmPinController = TextEditingController();
  }

  @override
  void dispose() {
    _oldPinController.dispose();
    _newPinController.dispose();
    _confirmPinController.dispose();
    super.dispose();
  }

  // Hàm xử lý lưu lên Firebase (Tương tự SafePIN)
  Future<void> _saveDuressPIN() async {
    final oldPin = _oldPinController.text;
    final newPin = _newPinController.text;
    final confirmPin = _confirmPinController.text;

    // --- Kiểm tra Logic (Validation) ---
    if (oldPin != widget.userSetting.duressPIN) {
      _showSnackBar("Mã PIN cũ không chính xác", isError: true);
      return;
    }
    if (newPin.length < 4 || confirmPin.length < 4) {
      _showSnackBar("Mã PIN phải đủ 4 chữ số", isError: true);
      return;
    }
    if (newPin != confirmPin) {
      _showSnackBar("Mã PIN mới không khớp", isError: true);
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Cập nhật Firestore trường 'duressPIN'
      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userSetting.userId)
          .update({'duressPIN': newPin});

      _showSnackBar("Cập nhật mã PIN bị ép buộc thành công!");

      // Trả về dữ liệu đã cập nhật
      final updatedProfile = widget.userSetting.copyWith(duressPIN: newPin);
      Navigator.pop(context, updatedProfile);

    } catch (e) {
      _showSnackBar("Lỗi: ${e.toString()}", isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
  }

  InputDecoration _inputStyle() {
    return InputDecoration(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFEF4444)), // Màu đỏ đặc trưng
      ),
      filled: true,
      fillColor: Colors.white,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: SecondaryHeader(title: 'Mã PIN Bị ép buộc'),
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFF7F9FF), Color(0xFFE3E9FF)],
          ),
        ),
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            children: [
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
                      _buildHeader(),
                      const SizedBox(height: 22),

                      _buildPinField("Mã PIN cũ (4 chữ số)", _oldPinController),
                      const SizedBox(height: 14),

                      _buildPinField("Mã PIN mới (4 chữ số)", _newPinController),
                      const SizedBox(height: 14),

                      _buildPinField("Xác nhận mã PIN mới", _confirmPinController),

                      const SizedBox(height: 20),

                      // Nút Lưu với trạng thái Loading
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _saveDuressPIN,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            backgroundColor: const Color(0xFFB91C1C),
                          ),
                          child: _isLoading
                              ? const SizedBox(
                            height: 20, width: 20,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                          )
                              : const Text("Lưu mã PIN", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
                        ),
                      ),
                      const SizedBox(height: 16),

                      _buildWarningBox(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPinField(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 13, color: Color(0xFF4B5563))),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          maxLength: 4,
          obscureText: true,
          textAlign: TextAlign.center,
          decoration: _inputStyle().copyWith(counterText: ""),
          style: const TextStyle(letterSpacing: 8, fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          width: 46, height: 46,
          decoration: BoxDecoration(color: const Color(0xFFFFE2E2), borderRadius: BorderRadius.circular(12)),
          child: const Icon(Icons.report_problem_outlined, size: 28, color: Color(0xFFB91C1C)),
        ),
        const SizedBox(width: 12),
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Mã PIN Bị ép buộc", style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
            Text("Khi bị ép buộc tắt app", style: TextStyle(fontSize: 13, color: Color(0xFF6B7280))),
          ],
        ),
      ],
    );
  }

  Widget _buildWarningBox() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFE2E2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFCA5A5)),
      ),
      child: const Row(
        children: [
          Icon(Icons.warning_amber_rounded, size: 20, color: Color(0xFFB91C1C)),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              "App sẽ giả vờ tắt nhưng gửi cảnh báo ngầm đến người bảo vệ",
              style: TextStyle(fontSize: 12, color: Color(0xFFB91C1C), fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}