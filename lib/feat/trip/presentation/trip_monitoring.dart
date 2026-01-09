import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:safetrek_project/core/widgets/app_bar.dart';
import 'package:safetrek_project/core/widgets/emergency_button.dart';
import 'package:safetrek_project/core/widgets/pin_input_dialog.dart';
import 'package:safetrek_project/feat/home/presentation/main_screen.dart';
import 'package:safetrek_project/feat/trip/domain/repository/trip_repository.dart';
import 'package:safetrek_project/feat/guardians/domain/repository/guardian_repository.dart';
import 'package:safetrek_project/feat/trip/presentation/bloc/trip_monitoring_bloc.dart';
import 'package:safetrek_project/feat/trip/presentation/bloc/trip_monitoring_event.dart';
import 'package:safetrek_project/feat/trip/presentation/bloc/trip_monitoring_state.dart';

class TripMonitoring extends StatelessWidget {
  final int durationInMinutes;
  final String tripId;

  const TripMonitoring({
    super.key,
    required this.durationInMinutes,
    required this.tripId,
  });
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          TripMonitoringBloc(
            tripRepository: context.read<TripRepository>(),
            guardianRepository: context.read<GuardianRepository>(),
          )..add(
            TripMonitoringStarted(
              durationInMinutes: durationInMinutes,
              tripId: tripId,
            ),
          ),
      child: const _TripMonitoringView(),
    );
  }
}

class _TripMonitoringView extends StatelessWidget {
  const _TripMonitoringView();

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    final twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "$twoDigitMinutes:$twoDigitSeconds";
  }

  Future<void> _showPinDialog(BuildContext context) async {
    final enteredPin = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const PinInputDialog();
      },
    );

    if (!context.mounted) return;
    if (enteredPin == null) return;
    context.read<TripMonitoringBloc>().add(
      TripMonitoringPinSubmitted(enteredPin),
    );
  }

  void _handleEffect(BuildContext context, TripMonitoringEffect effect) {
    if (effect is TripMonitoringShowSnackBar) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(effect.message),
          backgroundColor: effect.backgroundColor,
        ),
      );
    }

    if (effect is TripMonitoringNavigateHome) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const MainScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<TripMonitoringBloc, TripMonitoringState>(
      listenWhen: (previous, current) =>
          current.effect != null && previous.effect != current.effect,
      listener: (context, state) {
        final effect = state.effect;
        if (effect == null) return;
        _handleEffect(context, effect);
      },
      builder: (context, state) {
        return PopScope<void>(
          canPop: false,
          onPopInvokedWithResult: (bool didPop, _) {
            if (!didPop) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const MainScreen()),
              );
            }
          },
          child: Scaffold(
            appBar: const CustomAppBar(),
            body: Container(
              height: double.infinity,
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFFF1F4FF), Color(0xFFE2E9FF)],
                ),
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    _buildTimerCard(
                      context,
                      remainingTime: state.remainingTime,
                    ),
                    const SizedBox(height: 40),
                    EmergencyButton(
                      onPressed: state.isSendingAlert
                          ? null
                          : () => context.read<TripMonitoringBloc>().add(
                              TripMonitoringPanicPressed(),
                            ),
                    ),
                    const SizedBox(height: 15),
                    const Text(
                      'Nhấn nút này để gửi cảnh báo khẩn cấp ngay lập tức đến tất cả người bảo vệ của bạn',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey, fontSize: 13),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTimerCard(
    BuildContext context, {
    required Duration remainingTime,
  }) {
    return Card(
      elevation: 4,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.blue.shade100, width: 4),
              ),
              child: Column(
                children: [
                  Text(
                    _formatDuration(remainingTime),
                    style: const TextStyle(
                      color: Color(0xFF8A76F3),
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Text(
                    'còn lại',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.location_on, color: Colors.pink, size: 16),
                SizedBox(width: 8),
                Text(
                  'Hà Nội, Việt Nam',
                  style: TextStyle(fontSize: 16, color: Colors.black54),
                ),
              ],
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => _showPinDialog(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF007BFF),
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
              child: const Text(
                'Tôi đã An toàn - Check-in',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
