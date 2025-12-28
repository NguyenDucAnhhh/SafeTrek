import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:safetrek_project/core/widgets/setting_card.dart';
import 'package:safetrek_project/core/widgets/action_card.dart';
import 'package:safetrek_project/core/widgets/show_success_snack_bar.dart';
import 'package:safetrek_project/feat/setting/domain/repository/settings_repository.dart';
import 'package:safetrek_project/feat/setting/presentation/bloc/settings_bloc.dart';
import 'package:safetrek_project/feat/setting/presentation/bloc/settings_event.dart';
import 'package:safetrek_project/feat/setting/presentation/bloc/settings_state.dart';
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
    // ... (logic logout)
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
                      // ... (Các SettingCard khác tương tự)
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
}
