import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:safetrek_project/feat/trip/presentation/start_trip.dart';
import 'package:safetrek_project/feat/trip/presentation/trip_history.dart';
import 'package:safetrek_project/core/widgets/action_card.dart';
import 'package:safetrek_project/core/widgets/emergency_button.dart';
import 'package:safetrek_project/feat/trip/presentation/trip_monitoring.dart';
import 'package:safetrek_project/feat/trip/domain/repository/trip_repository.dart';
import 'package:safetrek_project/feat/guardians/domain/repository/guardian_repository.dart';
import 'package:safetrek_project/feat/trip/presentation/bloc/trip_bloc.dart';
import 'package:safetrek_project/feat/trip/presentation/bloc/trip_event.dart';
import 'package:safetrek_project/feat/trip/presentation/bloc/trip_state.dart';

class Trip extends StatefulWidget {
  const Trip({super.key});

  @override
  State<Trip> createState() => _TripState();
}

class _TripState extends State<Trip> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => TripBloc(
        repository: context.read<TripRepository>(),
        guardianRepository: context.read<GuardianRepository>(),
      )..add(CheckResumeActiveTripEvent()),
      child: BlocListener<TripBloc, TripState>(
        listener: (context, state) {
          if (state is TripResumeReady) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => TripMonitoring(
                  durationInMinutes: state.remainingMinutes,
                  tripId: state.tripId,
                ),
              ),
            );
          }

          if (state is TripAlertSent) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }

          if (state is TripError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: Scaffold(
          body: Container(
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
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  ActionCard(
                    icon: Icons.location_on,
                    iconColor: Colors.pinkAccent,
                    iconBgColor: Colors.pink.shade50,
                    title: "Bắt đầu Chuyến đi Mới",
                    subtitle: "Theo dõi hành trình an toàn",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const StartTrip(),
                        ),
                      );
                    },
                  ),
                  ActionCard(
                    icon: Icons.history,
                    iconColor: Colors.blue,
                    iconBgColor: Colors.blue.shade50,
                    title: "Lịch sử Chuyến đi",
                    subtitle: "Xem tất cả chuyến đi",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const TripHistory(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 40),
                  BlocBuilder<TripBloc, TripState>(
                    builder: (context, state) {
                      final isSending = state is TripAlertSending;
                      return Column(
                        children: [
                          EmergencyButton(
                            onPressed: isSending
                                ? null
                                : () => context.read<TripBloc>().add(
                                    TriggerInstantAlertEvent(),
                                  ),
                          ),
                          const SizedBox(height: 15),
                          if (isSending)
                            const Padding(
                              padding: EdgeInsets.all(8.0),
                              child: CircularProgressIndicator(),
                            ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 15),
                  const Text(
                    'Nhấn nút này để gửi cảnh báo khẩn cấp ngay lập tức đến tất cả người bảo vệ của bạn',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                  const SizedBox(height: 60),
                  Container(
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
                            Icon(
                              Icons.lightbulb_outline,
                              color: Colors.orange,
                              size: 20,
                            ),
                            SizedBox(width: 8),
                            Text(
                              "Hướng dẫn sử dụng",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF004085),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        _buildBulletPoint(
                          "Bắt đầu chuyến đi mới khi đi ra ngoài",
                        ),
                        _buildBulletPoint("Xem lại lịch sử các chuyến đi"),
                        _buildBulletPoint(
                          "Nhấn nút khẩn cấp khi gặp nguy hiểm",
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
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
          const Text(
            "• ",
            style: TextStyle(
              color: Color(0xFF004085),
              fontWeight: FontWeight.bold,
            ),
          ),
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
