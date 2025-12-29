import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:safetrek_project/feat/setting/presentation/bloc/settings_bloc.dart';
import 'package:safetrek_project/feat/setting/presentation/bloc/settings_event.dart';
import 'package:safetrek_project/feat/setting/presentation/bloc/settings_state.dart';
import '../../../../core/widgets/secondary_header.dart';
import '../../domain/entity/user_setting.dart';

class SettingPassword extends StatefulWidget {
  final UserSetting userSetting;
  const SettingPassword({super.key, required this.userSetting});

  @override
  State<SettingPassword> createState() => _SettingPasswordState();
}

class _SettingPasswordState extends State<SettingPassword> {
  final _oldPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isLoading = false;
  bool _obscureOld = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // Style input giống hệt mã PIN (viền nhạt, nền trắng)
  InputDecoration _inputStyle({required bool obscure, required VoidCallback onToggle}) {
    return InputDecoration(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      suffixIcon: IconButton(
        icon: Icon(obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
            color: const Color(0xFF9CA3AF), size: 20),
        onPressed: onToggle,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF3B82F6)), // Màu xanh chủ đạo
      ),
      filled: true,
      fillColor: Colors.white,
    );
  }

  void _savePassword() {
    if (_newPasswordController.text != _confirmPasswordController.text) {
      _showSnackBar("Mật khẩu xác nhận không khớp", isError: true);
      return;
    }
    if (_newPasswordController.text.length < 6) {
      _showSnackBar("Mật khẩu phải từ 6 ký tự trở lên", isError: true);
      return;
    }

    setState(() => _isLoading = true);
    context.read<SettingsBloc>().add(
        ChangePasswordEvent(_oldPasswordController.text, _newPasswordController.text)
    );
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: SecondaryHeader(title: 'Đổi mật khẩu'),
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
              BlocListener<SettingsBloc, SettingsState>(
                listener: (context, state) {
                  if (state is SettingsSuccess || state is SettingsError) {
                    setState(() => _isLoading = false);
                  }
                  if (state is SettingsSuccess) {
                    _showSnackBar("Cập nhật mật khẩu thành công!");
                    Navigator.pop(context);
                  } else if (state is SettingsError) {
                    _showSnackBar(state.message, isError: true);
                  }
                },
                child: Center(
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

                        _buildField("Mật khẩu cũ", _oldPasswordController, _obscureOld,
                                () => setState(() => _obscureOld = !_obscureOld)),
                        const SizedBox(height: 14),

                        _buildField("Mật khẩu mới", _newPasswordController, _obscureNew,
                                () => setState(() => _obscureNew = !_obscureNew)),
                        const SizedBox(height: 14),

                        _buildField("Xác nhận mật khẩu mới", _confirmPasswordController, _obscureConfirm,
                                () => setState(() => _obscureConfirm = !_obscureConfirm)),

                        const SizedBox(height: 24),

                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _savePassword,
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              backgroundColor: const Color(0xFF2F80ED),
                            ),
                            child: _isLoading
                                ? const SizedBox(height: 20, width: 20,
                                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                : const Text("Lưu mật khẩu",
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField(String label, TextEditingController controller, bool obscure, VoidCallback onToggle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 13, color: Color(0xFF4B5563), fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: obscure,
          decoration: _inputStyle(obscure: obscure, onToggle: onToggle),
          style: const TextStyle(fontSize: 16),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          width: 46, height: 46,
          decoration: BoxDecoration(
              color: const Color(0xFFF3E8FF),
              borderRadius: BorderRadius.circular(12)
          ),
          child: const Icon(Icons.lock_outline, size: 26, color: Color(0xFF8B5CF6)),
        ),
        const SizedBox(width: 12),
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Mật khẩu tài khoản", style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
            Text("Thay đổi mật khẩu đăng nhập", style: TextStyle(fontSize: 13, color: Color(0xFF6B7280))),
          ],
        ),
      ],
    );
  }
}