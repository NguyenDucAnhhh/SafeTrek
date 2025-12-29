import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:safetrek_project/core/widgets/secondary_header.dart';
import 'package:safetrek_project/feat/setting/domain/entity/user_setting.dart';
import 'package:safetrek_project/feat/setting/presentation/bloc/settings_bloc.dart';
import 'package:safetrek_project/feat/setting/presentation/bloc/settings_event.dart';

class SettingProfile extends StatefulWidget {
  final UserSetting userSetting;
  const SettingProfile({super.key, required this.userSetting});

  @override
  State<SettingProfile> createState() => _SettingProfileState();
}

class _SettingProfileState extends State<SettingProfile> {
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.userSetting.name);
    _phoneController = TextEditingController(text: widget.userSetting.phone);
    _emailController = TextEditingController(text: widget.userSetting.email);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _saveProfile() {
    // Gửi dữ liệu đã sửa đổi qua BLoC
    context.read<SettingsBloc>().add(
      UpdateProfileEvent(
        name: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
        email: _emailController.text.trim(),
      ),
    );
    Navigator.pop(context);
  }

  InputDecoration _inputDecoration({required String hint}) {
    return InputDecoration(
      hintText: hint,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFDFE8F8)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF3B82F6)),
      ),
      fillColor: Colors.white,
      filled: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: SecondaryHeader(title: 'Thông tin cá nhân'),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment(-0.1, -0.5),
            end: Alignment(1.0, 1.0),
            colors: [Color(0xFFEFF6FF), Color(0xFFE0E7FF)],
          ),
        ),
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
            children: [
              Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 520),
                  child: Container(
                    margin: const EdgeInsets.only(top: 6),
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.06),
                          blurRadius: 18,
                          spreadRadius: 2,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // --- Profile Header ---
                        Row(
                          children: [
                            Container(
                              width: 46, height: 46,
                              decoration: BoxDecoration(
                                color: const Color(0xFFDBEAFE),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(Icons.person_outlined, color: Colors.blue, size: 26),
                            ),
                            const SizedBox(width: 12),
                            const Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Thông tin cá nhân', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                                Text('Cập nhật thông tin liên hệ', style: TextStyle(fontSize: 13, color: Color(0xFF6A7282))),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // --- Form Fields ---
                        Form(
                          child: Column(
                            children: [
                              _buildLabel(Icons.person_outline, 'Họ tên'),
                              const SizedBox(height: 6),
                              TextFormField(
                                controller: _nameController,
                                decoration: _inputDecoration(hint: 'Nhập họ tên'),
                              ),
                              const SizedBox(height: 16),

                              _buildLabel(Icons.phone_outlined, 'Số điện thoại'),
                              const SizedBox(height: 6),
                              TextFormField(
                                controller: _phoneController,
                                keyboardType: TextInputType.phone,
                                decoration: _inputDecoration(hint: 'Nhập số điện thoại'),
                              ),
                              const SizedBox(height: 16),

                              _buildLabel(Icons.email_outlined, 'Email'),
                              const SizedBox(height: 6),
                              TextFormField(
                                controller: _emailController,
                                keyboardType: TextInputType.emailAddress,
                                decoration: _inputDecoration(hint: 'Nhập email'),
                              ),

                              const SizedBox(height: 24),

                              // --- Save Button ---
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: _saveProfile,
                                  style: ElevatedButton.styleFrom(
                                    padding: EdgeInsets.zero,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                  ),
                                  child: Ink(
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(colors: [Color(0xFF2F80ED), Color(0xFF2563EB)]),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Container(
                                      alignment: Alignment.center,
                                      constraints: const BoxConstraints(minHeight: 48),
                                      child: const Text(
                                        'Lưu thông tin',
                                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
                                      ),
                                    ),
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
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(IconData icon, String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.blue),
          const SizedBox(width: 8),
          Text(title, style: const TextStyle(fontSize: 13, color: Color(0xFF4B5563))),
        ],
      ),
    );
  }
}