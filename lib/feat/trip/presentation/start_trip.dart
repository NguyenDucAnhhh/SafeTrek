import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:safetrek_project/feat/trip/presentation/trip_monitoring.dart';
import 'package:safetrek_project/core/widgets/secondary_header.dart';
import 'package:safetrek_project/feat/trip/domain/repository/trip_repository.dart';
import 'package:safetrek_project/feat/guardians/domain/repository/guardian_repository.dart';
import 'package:safetrek_project/feat/trip/presentation/bloc/trip_bloc.dart';
import 'package:safetrek_project/feat/trip/presentation/bloc/trip_event.dart';
import 'package:safetrek_project/feat/trip/presentation/bloc/trip_state.dart';

class StartTrip extends StatefulWidget {
  const StartTrip({super.key});

  @override
  State<StartTrip> createState() => _StartTripState();
}

class _StartTripState extends State<StartTrip> {
  final TextEditingController _destinationController = TextEditingController();
  final TextEditingController _timeController = TextEditingController(
    text: '15',
  );
  int? _selectedTime;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _selectedTime = 15;
  }

  @override
  void dispose() {
    _destinationController.dispose();
    _timeController.dispose();
    super.dispose();
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
          if (state is TripCheckingActive || state is TripStarting) {
            if (mounted) setState(() => _isLoading = true);
          }

          if (state is TripNoActiveTrip) {
            if (mounted) setState(() => _isLoading = false);
          }

          if (state is TripResumeReady) {
            if (mounted) {
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
          }

          if (state is TripStartSuccess) {
            if (mounted) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => TripMonitoring(
                    durationInMinutes: state.durationMinutes,
                    tripId: state.tripId,
                  ),
                ),
              ).then((_) {
                context.read<TripBloc>().add(CheckResumeActiveTripEvent());
              });
            }
          }

          if (state is TripError) {
            if (mounted) setState(() => _isLoading = false);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: Scaffold(
          appBar: const SecondaryHeader(title: 'Chọn chuyến đi'),
          body: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Container(
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
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _buildDestinationCard(),
                          const SizedBox(height: 20),
                          _buildTimeCard(),
                          const SizedBox(height: 20),
                          _buildInfoCard(),
                          const SizedBox(height: 32),
                          Builder(
                            builder: (innerContext) {
                              return ElevatedButton(
                                onPressed: () {
                                  final destination =
                                      _destinationController.text.isNotEmpty
                                      ? _destinationController.text
                                      : 'Chuyến đi không tên';
                                  final durationMinutes =
                                      int.tryParse(_timeController.text) ?? 15;

                                  innerContext.read<TripBloc>().add(
                                    StartOrResumeTripRequested(
                                      destination: destination,
                                      durationMinutes: durationMinutes,
                                    ),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF8A76F3),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(25),
                                  ),
                                  elevation: 5,
                                ),
                                child: const Text(
                                  'Bắt đầu Giám sát',
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildDestinationCard() {
    return Card(
      elevation: 2,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.location_on_outlined, color: Colors.black54),
                SizedBox(width: 8),
                Text(
                  'Đích đến (Tùy chọn)',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _destinationController,
              decoration: InputDecoration(
                hintText: 'Ví dụ: Nhà bạn, Văn phòng...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Color(0xFF4B65D8)),
                ),
                filled: true,
                fillColor: Colors.grey.shade50,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeCard() {
    return Card(
      elevation: 2,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.timer_outlined, color: Colors.black54),
                SizedBox(width: 8),
                Text(
                  'Thời gian dự kiến',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                5,
                10,
                15,
                30,
                60,
              ].map((time) => _buildTimeChip(time)).toList(),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _timeController,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.start,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Color(0xFF4B65D8)),
                      ),
                      filled: true,
                      fillColor: Colors.grey.shade50,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    onChanged: (value) {
                      int? newTime = int.tryParse(value);
                      setState(() {
                        if (newTime != null &&
                            [5, 10, 15, 30, 60].contains(newTime)) {
                          _selectedTime = newTime;
                        } else {
                          _selectedTime = null;
                        }
                      });
                    },
                  ),
                ),
                const SizedBox(width: 10),
                const Text(
                  'phút',
                  style: TextStyle(fontSize: 16, color: Colors.black54),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeChip(int time) {
    final isSelected = _selectedTime == time;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedTime = time;
          _timeController.text = time.toString();
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF4B65D8) : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          time.toString(),
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF9C4),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.orange.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.warning_amber_rounded,
                color: Colors.orange.shade700,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                "Sau khi bắt đầu chuyến đi:",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.orange.shade800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _buildBulletPoint(
            "Ứng dụng sẽ theo dõi vị trí của bạn",
            Colors.orange.shade800,
          ),
          _buildBulletPoint(
            "Bạn phải check-in bằng PIN trước khi hết giờ",
            Colors.orange.shade800,
          ),
          _buildBulletPoint(
            "Nếu không check-in, cảnh báo sẽ tự động gửi đi",
            Colors.orange.shade800,
          ),
        ],
      ),
    );
  }

  Widget _buildBulletPoint(String text, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "• ",
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          Expanded(
            child: Text(text, style: TextStyle(color: color, fontSize: 13)),
          ),
        ],
      ),
    );
  }
}
