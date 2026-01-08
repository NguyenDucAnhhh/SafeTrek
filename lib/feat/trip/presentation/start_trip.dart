import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:safetrek_project/feat/trip/presentation/trip_monitoring.dart';
import 'package:safetrek_project/core/widgets/secondary_header.dart';
import 'package:safetrek_project/feat/trip/data/data_source/trip_remote_data_source.dart';
import 'package:safetrek_project/feat/trip/data/repository/trip_repository_impl.dart';
import 'package:safetrek_project/feat/trip/domain/entity/trip.dart';
import 'package:safetrek_project/feat/trip/presentation/bloc/trip_bloc.dart';
import 'package:safetrek_project/feat/trip/presentation/bloc/trip_event.dart';
import 'package:safetrek_project/feat/trip/presentation/bloc/trip_state.dart';
import 'package:safetrek_project/feat/trip/data/services/location_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:safetrek_project/background_service.dart';

class StartTrip extends StatefulWidget {
  const StartTrip({super.key});

  @override
  State<StartTrip> createState() => _StartTripState();
}

class _StartTripState extends State<StartTrip> {
  final TextEditingController _destinationController = TextEditingController();
  final TextEditingController _timeController = TextEditingController(text: '15');
  int? _selectedTime;
  late TripBloc _tripBloc;
  late final TripRepositoryImpl _tripRepository;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _selectedTime = 15;
    _tripRepository = TripRepositoryImpl(TripRemoteDataSource(FirebaseFirestore.instance));
    _tripBloc = TripBloc(_tripRepository);
    _checkAndResumeActiveTrip();
  }

  Future<void> _saveTripToPrefs(String tripId, DateTime startedAt) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('current_trip_id', tripId);
    await prefs.setInt('trip_start_time', startedAt.millisecondsSinceEpoch);
    final duration = int.tryParse(_timeController.text) ?? 15;
    await prefs.setInt('trip_duration', duration * 60); // lưu duration (giây)
  }

  Future<void> _checkAndResumeActiveTrip() async {
    try {
      final activeTrips = await _tripRepository.getActiveTrips();
      if (activeTrips.isNotEmpty) {
        activeTrips.sort((a, b) => (b.startedAt).compareTo(a.startedAt));
        final activeTrip = activeTrips.first;
        final now = DateTime.now();
        final remaining = activeTrip.expectedEndTime.isAfter(now)
            ? activeTrip.expectedEndTime.difference(now)
            : Duration.zero;

        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => TripMonitoring(
                durationInMinutes: remaining.inMinutes,
                tripId: activeTrip.id!,
              ),
            ),
          );
        }
      } else {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    } catch (e) {
      debugPrint('Error checking active trip: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _destinationController.dispose();
    _timeController.dispose();
    _tripBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<TripBloc, TripState>(
      bloc: _tripBloc,
      listener: (context, state) async {
        if (state is TripAddedSuccess) {
          final duration = int.tryParse(_timeController.text) ?? 15;
          // Lưu tripId và startTime vào SharedPreferences
          await _saveTripToPrefs(state.tripId, DateTime.now());
          // Ensure background service is running to track in background
          try {
            await initializeService();
          } catch (_) {}
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  TripMonitoring(durationInMinutes: duration, tripId: state.tripId),
            ),
          ).then((_) => _checkAndResumeActiveTrip());
        } else if (state is TripError) {
          if(mounted) setState(() => _isLoading = false);
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
                        ElevatedButton(
                          onPressed: () async {
                            final location = await LocationService.getCurrentLocation();
                            if (location == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Vui lòng cấp quyền truy cập vị trí để bắt đầu.'), backgroundColor: Colors.red),
                              );
                              return;
                            }

                            if (mounted) setState(() => _isLoading = true);

                            // If there's an active trip persisted, resume its monitoring instead of creating a new one
                            try {
                              final prefs = await SharedPreferences.getInstance();
                              final existingTripId = prefs.getString('current_trip_id');
                              if (existingTripId != null) {
                                final doc = await FirebaseFirestore.instance.collection('trips').doc(existingTripId).get();
                                final data = doc.data();
                                final status = data?['status'] as String?;
                                if (status != null && status == 'Đang tiến hành') {
                                  // compute remaining from expectedEndTime if available
                                  int remainingMinutes = 0;
                                  final ts = data?['expectedEndTime'];
                                  if (ts is Timestamp) {
                                    final expected = ts.toDate();
                                    final now = DateTime.now();
                                    final remaining = expected.isAfter(now) ? expected.difference(now) : Duration.zero;
                                    remainingMinutes = remaining.inMinutes;
                                  } else {
                                    final start = prefs.getInt('trip_start_time');
                                    final durationSec = prefs.getInt('trip_duration');
                                    if (start != null && durationSec != null) {
                                      final nowMs = DateTime.now().millisecondsSinceEpoch;
                                      final elapsed = ((nowMs - start) / 1000).round();
                                      final remainingSec = durationSec - elapsed;
                                      remainingMinutes = remainingSec > 0 ? (remainingSec / 60).ceil() : 0;
                                    }
                                  }

                                  // Ensure background service is running
                                  try {
                                    await initializeService();
                                  } catch (_) {}

                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => TripMonitoring(durationInMinutes: remainingMinutes, tripId: existingTripId),
                                    ),
                                  );
                                  return;
                                }
                              }
                            } catch (e) {
                              debugPrint('Error checking existing trip: $e');
                              // fall through to create a new trip
                            }

                            final destination = _destinationController.text.isNotEmpty
                                ? _destinationController.text
                                : 'Chuyến đi không tên';
                            final durationMinutes = int.tryParse(_timeController.text) ?? 15;
                            final now = DateTime.now();

                            final trip = Trip(
                              name: destination,
                              startedAt: now,
                              expectedEndTime: now.add(Duration(minutes: durationMinutes)),
                              status: 'Đang tiến hành',
                              lastLocation: location,
                            );
                            _tripBloc.add(AddTripEvent(trip));
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF8A76F3),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                            elevation: 5,
                          ),
                          child: const Text(
                            'Bắt đầu Giám sát',
                            style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
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
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _destinationController,
              decoration: InputDecoration(
                hintText: 'Ví dụ: Nhà bạn, Văn phòng...',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade300)),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade300)),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFF4B65D8))),
                filled: true,
                fillColor: Colors.grey.shade50,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [5, 10, 15, 30, 60].map((time) => _buildTimeChip(time)).toList(),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _timeController,
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.start,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        decoration: InputDecoration(
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade300)),
                          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade300)),
                          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFF4B65D8))),
                          filled: true,
                          fillColor: Colors.grey.shade50,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        ),
                        onChanged: (value) {
                          int? newTime = int.tryParse(value);
                          setState(() {
                            if (newTime != null && [5, 10, 15, 30, 60].contains(newTime)) {
                              _selectedTime = newTime;
                            } else {
                              _selectedTime = null;
                            }
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Text('phút', style: TextStyle(fontSize: 16, color: Colors.black54)),
                  ],
                ),
              ],
            )));
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
          style: TextStyle(color: isSelected ? Colors.white : Colors.black87, fontWeight: FontWeight.bold),
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
              Icon(Icons.warning_amber_rounded, color: Colors.orange.shade700, size: 20),
              const SizedBox(width: 8),
              Text(
                "Sau khi bắt đầu chuyến đi:",
                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange.shade800),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _buildBulletPoint("Ứng dụng sẽ theo dõi vị trí của bạn", Colors.orange.shade800),
          _buildBulletPoint("Bạn phải check-in bằng PIN trước khi hết giờ", Colors.orange.shade800),
          _buildBulletPoint("Nếu không check-in, cảnh báo sẽ tự động gửi đi", Colors.orange.shade800),
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
          Text("• ", style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 16)),
          Expanded(
            child: Text(text, style: TextStyle(color: color, fontSize: 13)),
          ),
        ],
      ),
    );
  }
}
