import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:safetrek_project/feat/trip/presentation/trip_monitoring.dart';
import 'package:safetrek_project/core/widgets/app_bar.dart';
import 'package:safetrek_project/core/widgets/bottom_navigation.dart';
import 'package:safetrek_project/core/widgets/secondary_header.dart';
import 'package:safetrek_project/feat/trip/data/data_source/trip_remote_data_source.dart';
import 'package:safetrek_project/feat/trip/data/repository/trip_repository_impl.dart';
import 'package:safetrek_project/feat/trip/domain/entity/trip.dart';
import 'package:safetrek_project/feat/trip/presentation/bloc/trip_bloc.dart';
import 'package:safetrek_project/feat/trip/presentation/bloc/trip_event.dart';
import 'package:safetrek_project/feat/trip/presentation/bloc/trip_state.dart';
import 'package:safetrek_project/feat/trip/data/services/location_service.dart';

class StartTrip extends StatefulWidget {
  const StartTrip({super.key});

  @override
  State<StartTrip> createState() => _StartTripState();
}

class _StartTripState extends State<StartTrip> {
  int _selectedIndex = 0;
  final TextEditingController _destinationController = TextEditingController();
  final TextEditingController _timeController = TextEditingController(text: '15');
  int? _selectedTime;
  late TripBloc _tripBloc;
  bool _hasActiveTip = false;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  void initState() {
    super.initState();
    _selectedTime = 15;
    _tripBloc = TripBloc(
      TripRepositoryImpl(
        TripRemoteDataSource(FirebaseFirestore.instance),
      ),
    );
    _checkActiveTrip();
  }

  Future<void> _checkActiveTrip() async {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) return;

      final snapshot = await FirebaseFirestore.instance
          .collection('trips')
          .where('userId', isEqualTo: uid)
          .where('status', isEqualTo: 'Đang tiến hành')
          .get();

      if (mounted) {
        setState(() {
          _hasActiveTip = snapshot.docs.isNotEmpty;
        });
      }
    } catch (e) {
      debugPrint('Error checking active trip: $e');
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
      listener: (context, state) {
        if (state is TripAddedSuccess) {
          // Trip saved to Firestore, navigate to monitoring
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
          final duration = int.tryParse(_timeController.text) ?? 15;
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  TripMonitoring(durationInMinutes: duration),
            ),
          );
        } else if (state is TripError) {
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20,),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (_hasActiveTip)
                      Container(
                        padding: const EdgeInsets.all(16),
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: Colors.orange.shade100,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.orange.shade300),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.warning_amber_rounded,
                                color: Colors.orange.shade700, size: 24),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Đang có chuyến đi hoạt động',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFFB8860B)),
                                  ),
                                  const SizedBox(height: 4),
                                  const Text(
                                    'Vui lòng hoàn thành hoặc hủy chuyến đi hiện tại',
                                    style: TextStyle(
                                        fontSize: 12,
                                        color: Color(0xFF8B6914)),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    _buildDestinationCard(),
                    const SizedBox(height: 20),
                    _buildTimeCard(),
                    const SizedBox(height: 20),
                    _buildInfoCard(),
                    const SizedBox(height: 32),
                    ElevatedButton(
                      onPressed: _hasActiveTip
                          ? null
                          : () async {
                              final destination = _destinationController.text.isNotEmpty
                                  ? _destinationController.text
                                  : 'Chuyến đi';
                              
                              // Lấy vị trí hiện tại
                              final location = await LocationService.getCurrentLocation();
                              
                              final trip = Trip(
                                name: destination,
                                startedAt: DateTime.now(),
                                status: 'Đang tiến hành',
                                lastLocation: location,
                              );
                              _tripBloc.add(AddTripEvent(trip));
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF8A76F3),
                        padding: const EdgeInsets.symmetric(vertical: 16),
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
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ), 
              ),
            ],
          ),
        ),
      ),
    )
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
                      color: Colors.black87),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _destinationController,
                    decoration: InputDecoration(
                      hintText: 'Ví dụ: Nhà bạn, Văn phòng...',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: Colors.grey.shade300)),
                      enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: Colors.grey.shade300)),
                      focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: Color(0xFF4B65D8))),
                      filled: true,
                      fillColor: Colors.grey.shade50,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Tính năng này đang phát triển'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                  icon: const Icon(Icons.map_outlined, color: Colors.white),
                  label: const Text('Bản đồ',
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4B65D8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    elevation: 3,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'Nhập địch đến để tăng độ chính xác của cảnh báo',
              style: TextStyle(color: Colors.black54, fontSize: 12),
            )
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
                          color: Colors.black87),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [5, 10, 15, 30, 60]
                      .map((time) => _buildTimeChip(time))
                      .toList(),
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
                            fontSize: 16, fontWeight: FontWeight.bold),
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(color: Colors.grey.shade300)),
                          enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(color: Colors.grey.shade300)),
                          focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide:
                                  const BorderSide(color: Color(0xFF4B65D8))),
                          filled: true,
                          fillColor: Colors.grey.shade50,
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
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
                    const Text('phút',
                        style: TextStyle(fontSize: 16, color: Colors.black54)),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Ứng dụng sẽ đếm ngược từ ${_timeController.text} phút. Bạn cần check-in trước khi hết giờ.',
                  style: const TextStyle(color: Colors.black54, fontSize: 12),
                )
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
          style: TextStyle(
              color: isSelected ? Colors.white : Colors.black87,
              fontWeight: FontWeight.bold),
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
              Icon(Icons.warning_amber_rounded,
                  color: Colors.orange.shade700, size: 20),
              const SizedBox(width: 8),
              Text(
                "Sau khi bắt đầu chuyến đi:",
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.orange.shade800),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _buildBulletPoint(
              "Ứng dụng sẽ theo dõi vị trí của bạn", Colors.orange.shade800),
          _buildBulletPoint(
              "Bạn phải check-in bằng PIN trước khi hết giờ", Colors.orange.shade800),
          _buildBulletPoint(
              "Nếu không check-in, cảnh báo sẽ tự động gửi đi",
              Colors.orange.shade800),
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
          Text("• ",
              style: TextStyle(
                  color: color, fontWeight: FontWeight.bold, fontSize: 16)),
          Expanded(
            child: Text(
              text,
              style: TextStyle(color: color, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}
