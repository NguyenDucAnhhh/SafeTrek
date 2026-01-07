import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:safetrek_project/core/widgets/app_bar.dart';
import 'package:safetrek_project/core/widgets/bottom_navigation.dart';
import 'package:safetrek_project/core/widgets/secondary_header.dart';
import 'package:safetrek_project/feat/trip/data/data_source/trip_remote_data_source.dart';
import 'package:safetrek_project/feat/trip/data/repository/trip_repository_impl.dart';
import 'package:safetrek_project/feat/trip/presentation/bloc/trip_bloc.dart';
import 'package:safetrek_project/feat/trip/presentation/bloc/trip_event.dart';
import 'package:safetrek_project/feat/trip/presentation/bloc/trip_state.dart';

class TripHistory extends StatelessWidget {
  const TripHistory({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => TripBloc(
        TripRepositoryImpl(
          TripRemoteDataSource(FirebaseFirestore.instance),
        ),
      )..add(LoadTripsEvent()),
      child: const _TripHistoryView(),
    );
  }
}

class _TripHistoryView extends StatefulWidget {
  const _TripHistoryView();

  @override
  State<_TripHistoryView> createState() => _TripHistoryViewState();
}

class _TripHistoryViewState extends State<_TripHistoryView> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const SecondaryHeader(title: 'Lịch sử chuyến đi',),
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
              children: [
            const SizedBox(height: 20),
            Card(
              elevation: 2,
              color: Colors.white,
              margin: const EdgeInsets.symmetric(horizontal: 16),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: BlocBuilder<TripBloc, TripState>(
                  builder: (context, state) {
                    int count = 0;
                    if (state is TripLoaded) {
                      count = state.trips.length;
                    }
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.blue.shade50,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.history, color: Colors.blue),
                            ),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Lịch sử Chuyến đi',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold, fontSize: 16),
                                ),
                                Text(
                                  '$count chuyến đi',
                                  style: TextStyle(
                                      fontSize: 14, color: Colors.grey.shade600),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        if (state is TripLoading)
                          const Center(child: CircularProgressIndicator())
                        else if (state is TripLoaded)
                          state.trips.isEmpty
                              ? _buildEmptyState()
                              : _buildHistoryList(state.trips)
                        else if (state is TripError)
                          Center(
                            child: Text(state.message,
                                style: const TextStyle(color: Colors.red)),
                          )
                      ],
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
      )
    );
  }
  
  Widget _buildHistoryList(List trips) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: trips.length,
      separatorBuilder: (context, index) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final trip = trips[index];
        return _buildTripHistoryItem(trip);
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.info_outline,
            color: Colors.grey.shade400,
            size: 60,
          ),
          const SizedBox(height: 16),
          Text(
            'Chưa có chuyến đi nào',
            style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }
  
  Widget _buildTripHistoryItem(trip) {
    // Xác định màu sắc dựa trên trạng thái
    Color backgroundColor;
    Color textColor;
    
    switch (trip.status) {
      case 'Kết thúc an toàn':
        backgroundColor = Colors.green.shade100;
        textColor = Colors.green.shade800;
        break;
      case 'Báo động':
        backgroundColor = Colors.red.shade100;
        textColor = Colors.red.shade800;
        break;
      case 'Đang tiến hành':
        backgroundColor = Colors.blue.shade100;
        textColor = Colors.blue.shade800;
        break;
      default:
        backgroundColor = Colors.grey.shade100;
        textColor = Colors.grey.shade800;
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200)
      ),
      child: Row(
        children: [
          Icon(Icons.location_on_outlined, color: Colors.grey.shade600, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  trip.name ?? 'Chuyến đi',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
                const SizedBox(height: 4),
                Text(
                  _formatDateTime(trip.startedAt),
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              trip.status ?? 'Hoàn thành',
              style: TextStyle(
                color: textColor,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inMinutes < 1) {
      return 'Vừa xong';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes} phút trước';
    } else if (difference.inDays < 1) {
      return '${difference.inHours} giờ trước';
    } else if (difference.inDays == 1) {
      return 'Hôm qua';
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }
  }
}
