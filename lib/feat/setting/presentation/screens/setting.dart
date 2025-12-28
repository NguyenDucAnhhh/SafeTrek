import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/widgets/setting_card.dart';
import '../../../../core/widgets/action_card.dart';
import '../../../../core/widgets/show_success_snack_bar.dart';
import '../../../home/presentation/login/login.dart';
import '../bloc/setting_bloc.dart';
import '../bloc/setting_event.dart';
import '../bloc/setting_state.dart';
import 'setting_profile.dart';
import 'setting_password.dart';
import 'setting_safePIN.dart';
import 'setting_duressPIN.dart';
import 'setting_hidden_panic.dart';

class Setting extends StatelessWidget {
  const Setting({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SettingBloc(settingRepository: context.read())..add(LoadUserProfile()),
      child: const SettingView(),
    );
  }
}

class SettingView extends StatelessWidget {
  const SettingView({super.key});

  void _handleLogout(BuildContext context) async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFFFEF2F2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Colors.red.shade200, width: 1),
        ),
        title: const Text(
          'Đăng xuất',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: Color(0xFFB91C1C),
          ),
        ),
        content: const Text(
          'Bạn có chắc chắn muốn đăng xuất không?',
          style: TextStyle(
            fontSize: 16,
            color: Color(0xFF991B1B),
          ),
        ),
        actions: [
          OutlinedButton(
            onPressed: () => Navigator.pop(context, false),
            style: OutlinedButton.styleFrom(
              backgroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 35, vertical: 10),
              side: BorderSide(color: Colors.grey.shade400),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            child: const Text(
              'Hủy',
              style: TextStyle(color: Colors.black87, fontSize: 16),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFDC2626),
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            child: const Text(
              'Đồng ý',
              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ],
        actionsAlignment: MainAxisAlignment.spaceEvenly,
        actionsPadding: const EdgeInsets.only(bottom: 16, top: 8),
      ),
    );

    if (confirm != true || !context.mounted) return;

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<SettingBloc, SettingState>(
        listener: (context, state) {
          if (state is SettingFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          } else if (state is SettingLoaded) {
            // Cân nhắc hiển thị SnackBar thành công ở đây nếu cần
          }
        },
        builder: (context, state) {
          if (state is SettingLoading || state is SettingInitial) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is SettingLoaded) {
            final userProfile = state.userProfile;
            return Container(
              width: double.infinity,
              height: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment(0.00, 0.30),
                  end: Alignment(1.00, 0.70),
                  colors: [Color(0xFFEFF6FF), Color(0xFFE0E7FF)],
                ),
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    SettingCard(
                      icon: Icons.person_outlined,
                      iconColor: const Color(0xFF1B388E),
                      iconBgColor: const Color(0xFFDBEAFE),
                      title: 'Thông tin cá nhân',
                      onTap: () async {
                        // Chuyển đến màn hình chỉnh sửa và chờ kết quả
                      },
                    ),
                    SettingCard(
                      icon: Icons.lock_outlined,
                      iconColor: const Color(0xFF8B5CF6),
                      iconBgColor: const Color(0xFFF5F3FF),
                      title: 'Đổi mật khẩu',
                      onTap: () { /* ... */ },
                    ),
                    SettingCard(
                      icon: Icons.shield_outlined,
                      iconColor: const Color(0xFF0B7A4A),
                      iconBgColor: const Color(0xFFDCFCE7),
                      title: 'Mã PIN An toàn',
                      onTap: () { /* ... */ },
                    ),
                    SettingCard(
                      icon: Icons.report_problem_outlined,
                      iconColor: const Color(0xFFB91C1C),
                      iconBgColor: const Color(0xFFFFE2E2),
                      title: 'Mã PIN Bị ép buộc',
                      onTap: () { /* ... */ },
                    ),
                    SettingCard(
                      icon: Icons.flash_on_outlined,
                      iconColor: const Color(0xFFB91C1C),
                      iconBgColor: const Color(0xFFFFE2E2),
                      title: 'Nút Hoảng loạn Ẩn',
                      onTap: () { /* ... */ },
                    ),
                    // ... (Lời khuyên bảo mật)
                    ActionCard(
                      icon: Icons.logout,
                      iconColor: const Color(0xFFEF4444),
                      iconBgColor: const Color(0xFFFEE2E2),
                      title: 'Đăng xuất',
                      subtitle: 'Thoát khỏi tài khoản',
                      onTap: () => _handleLogout(context),
                    ),
                  ],
                ),
              ),
            );
          }
          return const Center(child: Text('Đã có lỗi xảy ra. Vui lòng thử lại.'));
        },
      ),
    );
  }
}

