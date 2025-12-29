import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:safetrek_project/core/widgets/setting_card.dart';
import 'package:safetrek_project/core/widgets/action_card.dart';
import 'package:safetrek_project/core/widgets/show_success_snack_bar.dart';
import 'package:safetrek_project/feat/setting/domain/repository/settings_repository.dart';
import 'package:safetrek_project/feat/setting/presentation/bloc/settings_bloc.dart';
import 'package:safetrek_project/feat/setting/presentation/bloc/settings_event.dart';
import 'package:safetrek_project/feat/setting/presentation/bloc/settings_state.dart';
import '../../../home/presentation/login/login.dart';
import '../../../home/presentation/setting/setting_profile.dart';
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
      create: (context) => SettingsBloc(
        RepositoryProvider.of<SettingsRepository>(context),
      )..add(LoadUserSettingsEvent()),
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
              backgroundColor: Colors.grey.shade200,
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
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold),
            ),
          ),
        ],
        actionsAlignment: MainAxisAlignment.spaceEvenly,
        actionsPadding: const EdgeInsets.only(bottom: 16, top: 8),
      ),
    );

    if (confirm != true) return;

    try {
      await FirebaseAuth.instance.signOut();

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
            (route) => false,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Đăng xuất thành công'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Đăng xuất thất bại: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<SettingsBloc, SettingsState>(
        listener: (context, state) {
          if (state is SettingsError) {
            showSuccessSnackBar(context, state.message, isError: true);
          } else if (state is SettingsSuccess) {
            showSuccessSnackBar(context, state.message);
          }
        },
        child: BlocBuilder<SettingsBloc, SettingsState>(
          builder: (context, state) {
            if (state is SettingsLoading || state is SettingsInitial) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is SettingsLoaded) {
              final userSetting = state.userSetting;
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
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => BlocProvider.value(
                                value: BlocProvider.of<SettingsBloc>(context),
                                child: SettingProfile(userSetting: userSetting),
                              ),
                            ),
                          );
                        },
                      ),
                      SettingCard(
                        icon: Icons.lock_outlined,
                        iconColor: const Color(0xFF8B5CF6),
                        iconBgColor: const Color(0xFFF5F3FF),
                        title: 'Đổi mật khẩu',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => BlocProvider.value(
                                value: BlocProvider.of<SettingsBloc>(context),
                                child: SettingPassword(userSetting: userSetting),
                              ),
                            ),
                          );
                        },
                      ),
                      SettingCard(
                        icon: Icons.shield_outlined,
                        iconColor: const Color(0xFF0B7A4A),
                        iconBgColor: const Color(0xFFDCFCE7),
                        title: 'Mã PIN An toàn',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => BlocProvider.value(
                                value: BlocProvider.of<SettingsBloc>(context),
                                child: SettingSafePIN(userSetting: userSetting),
                              ),
                            ),
                          );
                        },
                      ),
                      SettingCard(
                        icon: Icons.report_problem_outlined,
                        iconColor: const Color(0xFFB91C1C),
                        iconBgColor: const Color(0xFFFFE2E2),
                        title: 'Mã PIN Bị ép buộc',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => BlocProvider.value(
                                value: BlocProvider.of<SettingsBloc>(context),
                                child: SettingDuressPIN(userSetting: userSetting),
                              ),
                            ),
                          );
                        },
                      ),
                      SettingCard(
                        icon: Icons.flash_on_outlined,
                        iconColor: const Color(0xFFB91C1C),
                        iconBgColor: const Color(0xFFFFE2E2),
                        title: 'Nút Hoảng loạn Ẩn',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const SettingHiddenPanic()),
                          );
                        },
                      ),
                      Container(
                        margin: const EdgeInsets.symmetric(vertical: 8.0),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEBF5FF),
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(color: Colors.blue.shade100),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(
                              children: [
                                Icon(Icons.lightbulb_outline, color: Colors.orange, size: 20),
                                SizedBox(width: 8),
                                Text(
                                  "Lời khuyên bảo mật",
                                  style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF004085)),
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
                      ),
                      ActionCard(
                        icon: Icons.logout,
                        iconColor: const Color(0xFFEF4444),
                        iconBgColor: const Color(0xFFFEE2E2),
                        title: 'Đăng xuất',
                        subtitle: 'Thoát khỏi tài khoản',
                        onTap: () {
                          _handleLogout(context);
                        },
                      ),
                    ],
                  ),
                ),
              );
            }
            return const Center(child: Text('Đã có lỗi xảy ra'));
          },
        ),
      ),
    );
  }

  Widget _buildBulletPoint(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("• ", style: TextStyle(color: Color(0xFF004085), fontWeight: FontWeight.bold)),
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