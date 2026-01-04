import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:safetrek_project/feat/setting/presentation/bloc/settings_bloc.dart';
import 'package:safetrek_project/feat/setting/presentation/bloc/settings_event.dart';
import 'package:safetrek_project/feat/setting/presentation/bloc/settings_state.dart';
import 'package:volume_controller/volume_controller.dart';

import '../../../../core/widgets/emergency_dialog.dart';
import '../../../../core/widgets/secondary_header.dart';

enum ActivationMethod { volume, power }

class SettingHiddenPanic extends StatelessWidget {
  const SettingHiddenPanic({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: BlocProvider.of<SettingsBloc>(context)..add(LoadHiddenPanicSettingsEvent()),
      child: const HiddenPanicView(),
    );
  }
}

class HiddenPanicView extends StatefulWidget {
  const HiddenPanicView({super.key});

  @override
  State<HiddenPanicView> createState() => _HiddenPanicViewState();
}

class _HiddenPanicViewState extends State<HiddenPanicView> {
  // int _pressCount = 0;
  // Timer? _resetTimer;
  // DateTime? _lastPressTime;
  //
  // DateTime? _lastAcceptedPressTime;
  // bool _isDialogShowing = false;
  // bool _ignoreFirstVolumeEvent = true;

  // @override
  // void initState() {
  //   super.initState();
  //
  //   VolumeController().listener((volume) {
  //     if (_ignoreFirstVolumeEvent) {
  //       _ignoreFirstVolumeEvent = false;
  //       return;
  //     }
  //
  //     final state = context.read<SettingsBloc>().state;
  //
  //     if (state is HiddenPanicSettingsLoaded &&
  //         state.isEnabled &&
  //         state.method == 'volume') {
  //       _handleVolumePress(state.pressCount);
  //     }
  //   });
  // }
  //
  // void _handleVolumePress(int requiredPresses) {
  //   final now = DateTime.now();
  //
  //   // 🔒 1 LẦN BẤM = 1 CALLBACK (CHẶN SPAM)
  //   if (_lastAcceptedPressTime != null &&
  //       now.difference(_lastAcceptedPressTime!) <
  //           const Duration(milliseconds: 400)) {
  //     return;
  //   }
  //   _lastAcceptedPressTime = now;
  //
  //   // ⏱ reset nếu ngắt quãng > 2s
  //   if (_lastPressTime == null ||
  //       now.difference(_lastPressTime!) > const Duration(seconds: 2)) {
  //     _pressCount = 1;
  //   } else {
  //     _pressCount++;
  //   }
  //
  //   _lastPressTime = now;
  //
  //   if (_pressCount == requiredPresses && !_isDialogShowing) {
  //     _isDialogShowing = true;
  //     _pressCount = 0;
  //
  //     showDialog(
  //       context: context,
  //       barrierDismissible: false,
  //       builder: (_) => const EmergencyDialog(),
  //     ).then((_) {
  //       Future.delayed(const Duration(seconds: 2), () {
  //         _isDialogShowing = false;
  //       });
  //     });
  //   }
  // }
  //
  // @override
  // void dispose() {
  //   VolumeController().removeListener();
  //   _resetTimer?.cancel();
  //   super.dispose();
  // }

  void _saveSettings(BuildContext context, {
    required bool isEnabled,
    required String method,
    required int pressCount,
  }) {
    context.read<SettingsBloc>().add(SaveHiddenPanicSettingsEvent(
      isEnabled: isEnabled,
      method: method,
      pressCount: pressCount,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F5FF),
      appBar: SecondaryHeader(title: 'Nút hoảng loạn ẩn'),
      body: BlocConsumer<SettingsBloc, SettingsState>(
        listener: (context, state) {
          if (state is SettingsError) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
        builder: (context, state) {
          if (state is HiddenPanicSettingsLoaded) {
            return _buildContent(context, state);
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  Widget _buildContent(BuildContext context, HiddenPanicSettingsLoaded state) {
    return Stack(
      children: [
        SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 24),
              _buildToggleCard(context, state),
              const SizedBox(height: 16),
              _buildInfoCard(),
              if (state.isEnabled) ...[
                const SizedBox(height: 24),
                const Text(
                  'Chọn Cách Kích hoạt',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F2937),
                  ),
                ),
                const SizedBox(height: 16),
                _buildActivationOption(
                  context,
                  state,
                  icon: Icons.volume_up,
                  title: 'Phím Âm lượng',
                  subtitle: 'Nhấn phím tăng/giảm âm lượng trong 2 giây',
                  value: 'volume',
                ),
                const SizedBox(height: 16),
                _buildActivationOption(
                  context,
                  state,
                  icon: Icons.power_settings_new,
                  title: 'Nút Power',
                  subtitle: 'Nhấn nút Power trong 2 giây',
                  value: 'power',
                ),
                const SizedBox(height: 24),
                _buildImportantNoteCard(),
              ]
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Row(children: [
      Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
              color: const Color(0xFFFFE8E8),
              borderRadius: BorderRadius.circular(12)),
          child: const Icon(Icons.flash_on,
              color: Color(0xFFF53E3E), size: 28)),
      const SizedBox(width: 16),
      const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Nút Hoảng loạn Ẩn',
                style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF101828))),
            SizedBox(height: 4),
            Text('Kích hoạt cảnh báo bí mật',
                style: TextStyle(fontSize: 15, color: Color(0xFF6A7282)))
          ])
    ]);
  }

  Widget _buildToggleCard(
      BuildContext context, HiddenPanicSettingsLoaded state) {
    return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                  color: Colors.grey.withOpacity(0.05), blurRadius: 10)
            ]),
        child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Bật Nút Hoảng loạn Ẩn',
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF101828))),
                        SizedBox(height: 4),
                        Text(
                            'Kích hoạt cảnh báo khẩn cấp mà không cần mở ứng dụng',
                            style: TextStyle(
                                fontSize: 14, color: Color(0xFF6A7282)))
                      ])),
              const SizedBox(width: 16),
              Switch(
                  value: state.isEnabled,
                  onChanged: (value) => _saveSettings(context,
                      isEnabled: value,
                      method: state.method,
                      pressCount: state.pressCount),
                  activeTrackColor: const Color(0xFF6366F1),
                  activeColor: Colors.white,
                  inactiveTrackColor: Colors.grey.shade300,
                  inactiveThumbColor: Colors.white)
            ]));
  }

  Widget _buildInfoCard() {
    return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
            color: const Color(0xFFEEF2FF),
            borderRadius: BorderRadius.circular(12)),
        child: const Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.info_outline, color: Color(0xFF4F46E5)),
              SizedBox(width: 12),
              Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Nút hoảng loạn ẩn là gì?',
                            style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF3730A3))),
                        SizedBox(height: 6),
                        Text(
                            'Cho phép bạn kích hoạt cảnh báo khẩn cấp một cách bí mật thông qua các thao tác đặc biệt, rất hữu ích khi bạn không thể mở ứng dụng một cách rõ ràng.',
                            style: TextStyle(
                                fontSize: 14,
                                color: Color(0xFF4338CA),
                                height: 1.4))
                      ]))
            ]));
  }

  Widget _buildActivationOption(
      BuildContext context, HiddenPanicSettingsLoaded state,
      {required IconData icon,
        required String title,
        required String subtitle,
        required String value}) {
    final bool isSelected = state.method == value;
    return GestureDetector(
        onTap: () => _saveSettings(context,
            isEnabled: state.isEnabled,
            method: value,
            pressCount: state.pressCount),
        child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: isSelected
                    ? Border.all(color: const Color(0xFF4F46E5), width: 1.5)
                    : null,
                boxShadow: [
                  BoxShadow(
                      color: Colors.grey.withOpacity(0.05), blurRadius: 10)
                ]),
            child: Column(children: [
              Row(children: [
                Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                        color: const Color(0xFFEEF2FF),
                        borderRadius: BorderRadius.circular(10)),
                    child:
                    Icon(icon, color: const Color(0xFF4F46E5), size: 24)),
                const SizedBox(width: 12),
                Expanded(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(title,
                              style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF101828))),
                          const SizedBox(height: 4),
                          Text(subtitle,
                              style: const TextStyle(
                                  fontSize: 14, color: Color(0xFF6A7282)))
                        ])),
                Radio<String>(
                    value: value,
                    groupValue: state.method,
                    onChanged: (newValue) {
                      if (newValue != null)
                        _saveSettings(context,
                            isEnabled: state.isEnabled,
                            method: newValue,
                            pressCount: state.pressCount);
                    },
                    activeColor: const Color(0xFF4F46E5))
              ]),
              if (isSelected) ...[
                const SizedBox(height: 16),
                Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Số lần nhấn:',
                              style: TextStyle(
                                  fontSize: 15, color: Color(0xFF374151))),
                          Row(
                              children: [3, 5, 7]
                                  .map((count) =>
                                  _buildCountButton(context, state, count))
                                  .toList())
                        ]))
              ]
            ])));
  }

  Widget _buildCountButton(
      BuildContext context, HiddenPanicSettingsLoaded state, int count) {
    final bool isSelected = state.pressCount == count;
    return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: ElevatedButton(
            onPressed: () => _saveSettings(context,
                isEnabled: state.isEnabled,
                method: state.method,
                pressCount: count),
            style: ElevatedButton.styleFrom(
                backgroundColor: isSelected
                    ? const Color(0xFF4F46E5)
                    : const Color(0xFFF3F4F6),
                foregroundColor:
                isSelected ? Colors.white : const Color(0xFF374151),
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
                padding:
                const EdgeInsets.symmetric(horizontal: 24, vertical: 12)),
            child: Text('${count}x',
                style:
                const TextStyle(fontWeight: FontWeight.bold, fontSize: 14))));
  }

  Widget _buildImportantNoteCard() {
    return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
            color: const Color(0xFFFEFCE8),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFFDE047).withOpacity(0.8))),
        child: const Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                  padding: EdgeInsets.only(top: 2.0),
                  child: Icon(Icons.warning_amber_rounded,
                      color: Color(0xFFB45309), size: 20)),
              SizedBox(width: 12),
              Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Lưu ý quan trọng:',
                            style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFB45309))),
                        SizedBox(height: 8),
                        Text(
                            '• Cảnh báo sẽ được gửi ngay lập tức khi kích hoạt',
                            style: TextStyle(
                                fontSize: 14,
                                color: Color(0xFF92400E),
                                height: 1.5)),
                        Text(
                            '• Không có xác nhận, hãy cẩn thận tránh kích hoạt nhầm',
                            style: TextStyle(
                                fontSize: 14,
                                color: Color(0xFF92400E),
                                height: 1.5)),
                        Text(
                            '• Hoạt động ngay cả khi ứng dụng đang chạy nền',
                            style: TextStyle(
                                fontSize: 14,
                                color: Color(0xFF92400E),
                                height: 1.5))
                      ]))
            ]));
  }
}
