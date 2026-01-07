import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:safetrek_project/core/widgets/app_bar.dart';
import 'package:safetrek_project/feat/auth/presentation/bloc/auth_bloc.dart';
import 'package:safetrek_project/feat/auth/presentation/bloc/auth_event.dart';
import 'package:safetrek_project/feat/auth/presentation/bloc/auth_state.dart';
import '../main_screen.dart';
import 'otp_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  int _currentStep = 1;

  // EmailJS Config
  final String _serviceId = 'service_3wb3qkw';
  final String _templateId = 'template_rc6gjcc';
  final String _publicKey = '3BxtO5pqgnd6tCeFf';

  // State
  bool _isSendingOtp = false;
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  
  // Controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _pinController = TextEditingController();
  final TextEditingController _duressPinController = TextEditingController();

  String _generateOtp() {
    return (Random().nextInt(900000) + 100000).toString();
  }

  Future<String> _sendOtpToEmail() async {
    final email = _emailController.text.trim();
    final otp = _generateOtp();

    final response = await http.post(
      Uri.parse('https://api.emailjs.com/api/v1.0/email/send'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'service_id': _serviceId,
        'template_id': _templateId,
        'user_id': _publicKey,
        'template_params': {
          'to_email': email,
          'otp_code': otp,
        },
      }),
    );

    if (response.statusCode == 200) {
      return otp;
    } else {
      throw Exception('Gửi mail thất bại: ${response.body}');
    }
  }

  void _handleNextStep1() async {
    final email = _emailController.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Vui lòng nhập email hợp lệ')));
      return;
    }

    setState(() => _isSendingOtp = true);
    try {
      final otp = await _sendOtpToEmail();
      if (!mounted) return;
      
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => OtpScreen(
            email: email,
            generatedOtp: otp,
            onVerified: () {
              setState(() => _currentStep = 2);
            },
            onResend: _sendOtpToEmail,
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi: $e')));
    } finally {
      setState(() => _isSendingOtp = false);
    }
  }

  void _previousStep() {
    setState(() => _currentStep = 1);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _pinController.dispose();
    _duressPinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.white, Color(0xFFE0E7FF)],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
            child: BlocListener<AuthBloc, AuthState>(
              listener: (context, state) {
                if (state is AuthFailure) {
                  ScaffoldMessenger.of(context)
                    ..hideCurrentSnackBar()
                    ..showSnackBar(SnackBar(content: Text(state.message)));
                }
                if (state is Authenticated) {
                  Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const MainScreen()));
                }
              },
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildProgressIndicator(),
                  const SizedBox(height: 20),
                  _currentStep == 1 ? _buildStep1Form() : _buildStep2Form(),
                  const SizedBox(height: 24),
                  _buildFooter(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Container(
                height: 8,
                decoration: const BoxDecoration(
                  color: Color(0xFF1877F2),
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(4), bottomLeft: Radius.circular(4)),
                ),
              ),
            ),
            const SizedBox(width: 4),
            Expanded(
              child: Container(
                height: 8,
                decoration: BoxDecoration(
                  color: _currentStep == 2 ? const Color(0xFF1877F2) : Colors.grey[300],
                  borderRadius: const BorderRadius.only(topRight: Radius.circular(4), bottomRight: Radius.circular(4)),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Center(
          child: Text(
            'Bước $_currentStep/2',
            style: const TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  Widget _buildStep1Form() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 20, spreadRadius: 2, offset: const Offset(0, 8))]
      ),
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Row(
            children: [
              Icon(Icons.person_add_alt_1_outlined, color: Color(0xFF1877F2)),
              SizedBox(width: 8),
              Text('Thông tin cá nhân', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 8),
          Text('Nhập thông tin của bạn để tạo tài khoản', style: TextStyle(fontSize: 14, color: Colors.grey[600])),
          const SizedBox(height: 24),
          _TextFieldWithIcon(controller: _nameController, icon: Icons.person_outline, label: 'Họ và tên', hint: 'Nguyễn Văn A'),
          const SizedBox(height: 16),
          _TextFieldWithIcon(controller: _emailController, icon: Icons.email_outlined, label: 'Email', hint: 'your.email@example.com', keyboardType: TextInputType.emailAddress),
          const SizedBox(height: 16),
          _TextFieldWithIcon(controller: _phoneController, icon: Icons.phone_outlined, label: 'Số điện thoại', hint: '0901234567', keyboardType: TextInputType.phone),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _isSendingOtp ? null : _handleNextStep1,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1877F2),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 0,
            ),
            child: _isSendingOtp 
              ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
              : const Text('Tiếp theo', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildStep2Form() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 20, spreadRadius: 2, offset: const Offset(0, 8))]
      ),
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.lock_outline_rounded, color: Color(0xFF1877F2)),
              SizedBox(width: 8),
              Text('Bảo mật tài khoản', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 8),
          Text('Thiết lập mật khẩu và mã PIN bảo vệ', style: TextStyle(fontSize: 14, color: Colors.grey[600])),
          const SizedBox(height: 24),
          const Text('Mật khẩu', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          TextField(
            controller: _passwordController,
            obscureText: !_isPasswordVisible,
            decoration: _buildInputDecoration(
              hintText: 'Ít nhất 6 ký tự',
              onVisibilityToggle: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
              isPasswordVisible: _isPasswordVisible,
            ),
          ),
          const SizedBox(height: 16),
          const Text('Xác nhận mật khẩu', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          TextField(
            controller: _confirmPasswordController,
            obscureText: !_isConfirmPasswordVisible,
            decoration: _buildInputDecoration(
              hintText: 'Nhập lại mật khẩu',
              onVisibilityToggle: () => setState(() => _isConfirmPasswordVisible = !_isConfirmPasswordVisible),
              isPasswordVisible: _isConfirmPasswordVisible,
            ),
          ),
          const SizedBox(height: 16),
          const Text('Mã PIN an toàn (4 chữ số)', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          TextField(
            controller: _pinController,
            obscureText: true,
            keyboardType: TextInputType.number,
            maxLength: 4,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: _buildInputDecoration(hintText: '••••').copyWith(counterText: ""),
          ),
          const Text('Dùng để tắt cảnh báo và kết thúc chuyến đi an toàn', style: TextStyle(color: Colors.grey, fontSize: 12)),
          const SizedBox(height: 16),
          const Text('Mã PIN bị ép buộc (4 chữ số)', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          TextField(
            controller: _duressPinController,
            obscureText: true,
            keyboardType: TextInputType.number,
            maxLength: 4,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: _buildInputDecoration(hintText: '••••').copyWith(counterText: ""),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: const Color(0xFFFFF7ED), borderRadius: BorderRadius.circular(8)),
            child: const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.warning_amber_rounded, color: Color(0xFFF97316), size: 20),
                SizedBox(width: 8),
                Expanded(child: Text('Khi nhập mã này, app sẽ giả vờ tắt nhưng gửi cảnh báo ngầm', style: TextStyle(color: Color(0xFFD97706), fontSize: 13))),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _previousStep,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: BorderSide(color: Colors.grey.shade300),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Quay lại', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: _onFinish,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1877F2),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  child: const Text('Hoàn tất', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _onFinish() {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final phone = _phoneController.text.trim();
    final password = _passwordController.text;
    final confirm = _confirmPasswordController.text;
    final pin = _pinController.text;
    final duressPin = _duressPinController.text;

    if (name.isEmpty || email.isEmpty || password.isEmpty || pin.isEmpty || duressPin.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Vui lòng điền đủ thông tin')));
      return;
    }
    context.read<AuthBloc>().add(SignUpRequested(email: email, password: password, additionalData: {'name': name, 'phone': phone, 'safePIN': pin, 'duressPIN': duressPin}));
  }

  Widget _buildFooter() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Đã có tài khoản?', style: TextStyle(color: Colors.grey)),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Đăng nhập ngay', style: TextStyle(color: Color(0xFF1877F2), fontWeight: FontWeight.bold)),
            ),
          ],
        ),
        const SizedBox(height: 20),
        const Text('© 2025 SafeTrek. Bảo vệ an toàn của bạn.', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey, fontSize: 12)),
      ],
    );
  }

  InputDecoration _buildInputDecoration({required String hintText, VoidCallback? onVisibilityToggle, bool? isPasswordVisible}) {
    return InputDecoration(
      hintText: hintText,
      filled: true,
      fillColor: const Color(0xFFF3F4F6),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      suffixIcon: onVisibilityToggle != null
          ? IconButton(
              icon: Icon(isPasswordVisible! ? Icons.visibility_outlined : Icons.visibility_off_outlined, color: Colors.grey),
              onPressed: onVisibilityToggle,
            )
          : null,
    );
  }
}

class _TextFieldWithIcon extends StatelessWidget {
  final IconData icon;
  final String label;
  final String hint;
  final TextInputType? keyboardType;
  final TextEditingController? controller;
  const _TextFieldWithIcon({this.controller, required this.icon, required this.label, required this.hint, this.keyboardType});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [Icon(icon, color: Colors.grey[700], size: 20), const SizedBox(width: 8), Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14))]),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: const Color(0xFFF3F4F6),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          ),
          keyboardType: keyboardType,
        ),
      ],
    );
  }
}
