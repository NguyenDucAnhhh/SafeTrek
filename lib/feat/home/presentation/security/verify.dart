import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:safetrek_project/core/widgets/secondary_header.dart';

class Verify extends StatefulWidget {
  const Verify({super.key});

  @override
  State<Verify> createState() => _VerifyState();
}

class _VerifyState extends State<Verify> {
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _onVerify() async {
    final email = _emailController.text.trim();
    final phone = _phoneController.text.trim();
    if (email.isEmpty || phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Vui lòng nhập email và số điện thoại')));
      return;
    }
    setState(() => _loading = true);
    try {
      // 1. Kiểm tra xem Email và Số điện thoại có khớp trong hệ thống không
      final q = await FirebaseFirestore.instance.collection('users')
        .where('email', isEqualTo: email)
        .where('phone', isEqualTo: phone)
        .limit(1)
        .get();

      if (q.docs.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Thông tin xác thực không chính xác')));
        }
        return;
      }

      // 2. Nếu khớp, gửi email reset mật khẩu của Firebase
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Yêu cầu thành công! Vui lòng kiểm tra email để đặt lại mật khẩu'))
        );
        // 3. Quay về màn hình Login (thường là màn hình đầu tiên)
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi: $e')));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const SecondaryHeader(title: 'Quên mật khẩu'),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFEFF6FF), Color(0xFFE0E7FF)],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
            child: Column(
              children: [
                const SizedBox(height: 20),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: const BoxDecoration(
                            color: Color(0xFFEBF5FF),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.vpn_key_outlined,
                            size: 40,
                            color: Color(0xFF1877F2),
                          ),
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          'Xác thực danh tính',
                          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF1F2937)),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Nhập thông tin để xác nhận tài khoản của bạn',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
                        ),
                        const SizedBox(height: 32),

                        const Align(
                          alignment: Alignment.centerLeft,
                          child: Text('Email đã đăng ký', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF374151))),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            hintText: 'your.email@example.com',
                            filled: true,
                            fillColor: const Color(0xFFF9FAFB),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
                            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
                          ),
                        ),
                        const SizedBox(height: 20),

                        const Align(
                          alignment: Alignment.centerLeft,
                          child: Text('Số điện thoại', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF374151))),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                          decoration: InputDecoration(
                            hintText: '0912345678',
                            filled: true,
                            fillColor: const Color(0xFFF9FAFB),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
                            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
                          ),
                        ),
                        const SizedBox(height: 32),

                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _loading ? null : _onVerify,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF1877F2),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              elevation: 2,
                              shadowColor: const Color(0xFF1877F2).withOpacity(0.5),
                            ),
                            child: _loading 
                              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) 
                              : const Text('Xác thực', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                          ),
                        ),
                        const SizedBox(height: 24),

                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(color: const Color(0xFFF0F7FF), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFD1E9FF))),
                          child: const Row(
                            children: [
                              Icon(Icons.lock_outline, size: 16, color: Color(0xFF1877F2)),
                              SizedBox(width: 8),
                              Expanded(child: Text('Thông tin của bạn được bảo mật và chỉ dùng để xác thực danh tính', style: TextStyle(fontSize: 12, color: Color(0xFF1877F2)))),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 100),
                const Text('© 2025 SafeTrek. Bảo vệ an toàn của bạn.', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
