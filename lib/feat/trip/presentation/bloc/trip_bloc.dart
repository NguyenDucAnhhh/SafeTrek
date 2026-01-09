import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'trip_event.dart';
import 'trip_state.dart';
import 'package:safetrek_project/feat/trip/domain/entity/trip.dart';
import 'package:safetrek_project/feat/trip/domain/repository/trip_repository.dart';
import 'package:safetrek_project/feat/trip/data/services/location_service.dart';
import 'package:safetrek_project/background_service.dart';
import 'package:safetrek_project/core/utils/emergency_utils.dart';
import 'package:safetrek_project/feat/guardians/domain/repository/guardian_repository.dart';

class TripBloc extends Bloc<TripEvent, TripState> {
  final TripRepository repository;
  final GuardianRepository guardianRepository;

  TripBloc({required this.repository, required this.guardianRepository})
    : super(TripInitial()) {
    on<LoadTripsEvent>((event, emit) async {
      emit(TripLoading());
      try {
        final trips = await repository.getTrips();
        emit(TripLoaded(trips));
      } catch (e) {
        emit(TripError('Không thể tải chuyến đi: ${e.toString()}'));
      }
    });

    on<AddTripEvent>((event, emit) async {
      try {
        final tripId = await repository.addTrip(event.trip);
        emit(TripAddedSuccess(message: 'Đã tạo chuyến đi', tripId: tripId));
      } catch (e) {
        emit(TripError('Lỗi khi thêm chuyến đi: ${e.toString()}'));
      }
    });

    on<CheckResumeActiveTripEvent>(_onCheckResumeActiveTrip);
    on<StartOrResumeTripRequested>(_onStartOrResumeTripRequested);
    on<TriggerInstantAlertEvent>(_onTriggerInstantAlert);
  }

  Future<void> _onCheckResumeActiveTrip(
    CheckResumeActiveTripEvent event,
    Emitter<TripState> emit,
  ) async {
    emit(TripCheckingActive());
    try {
      final activeTrips = await repository.getActiveTrips();
      if (activeTrips.isEmpty) {
        emit(TripNoActiveTrip());
        return;
      }

      // Choose preferred trip if available, otherwise most recent.
      activeTrips.sort((a, b) => b.startedAt.compareTo(a.startedAt));
      final preferred = (event.preferredTripId == null)
          ? null
          : activeTrips.where((t) => t.id == event.preferredTripId).toList();
      final activeTrip = (preferred != null && preferred.isNotEmpty)
          ? preferred.first
          : activeTrips.first;

      final now = DateTime.now();
      final remaining = activeTrip.expectedEndTime.isAfter(now)
          ? activeTrip.expectedEndTime.difference(now)
          : Duration.zero;

      if (activeTrip.id == null) {
        emit(TripNoActiveTrip());
        return;
      }

      emit(
        TripResumeReady(
          tripId: activeTrip.id!,
          remainingMinutes: remaining.inMinutes,
        ),
      );
    } catch (e) {
      emit(
        TripError(
          'Không thể kiểm tra chuyến đi đang hoạt động: ${e.toString()}',
        ),
      );
    }
  }

  Future<void> _saveTripToPrefs(
    String tripId,
    DateTime startedAt,
    int durationMinutes,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('current_trip_id', tripId);
    await prefs.setInt('trip_start_time', startedAt.millisecondsSinceEpoch);
    await prefs.setInt('trip_duration', durationMinutes * 60);
  }

  Future<void> _onStartOrResumeTripRequested(
    StartOrResumeTripRequested event,
    Emitter<TripState> emit,
  ) async {
    try {
      final guardians = await guardianRepository.getGuardians();
      if (guardians.isEmpty) {
        emit(TripError('Vui lòng thêm người bảo vệ'));
        return;
      }

      emit(TripStarting());

      // If there's a persisted trip id, and it's still active, resume it.
      final prefs = await SharedPreferences.getInstance();
      final existingTripId = prefs.getString('current_trip_id');
      if (existingTripId != null) {
        final activeTrips = await repository.getActiveTrips();
        final match = activeTrips.where((t) => t.id == existingTripId).toList();
        if (match.isNotEmpty) {
          final activeTrip = match.first;
          final now = DateTime.now();
          final remaining = activeTrip.expectedEndTime.isAfter(now)
              ? activeTrip.expectedEndTime.difference(now)
              : Duration.zero;
          emit(
            TripResumeReady(
              tripId: existingTripId,
              remainingMinutes: remaining.inMinutes,
            ),
          );
          return;
        }
      }

      final location = await LocationService.getCurrentLocation();
      if (location == null) {
        emit(TripError('Vui lòng cấp quyền truy cập vị trí để bắt đầu.'));
        return;
      }

      final now = DateTime.now();
      final trip = Trip(
        name: event.destination.isNotEmpty
            ? event.destination
            : 'Chuyến đi không tên',
        startedAt: now,
        expectedEndTime: now.add(Duration(minutes: event.durationMinutes)),
        status: 'Đang tiến hành',
        lastLocation: location,
      );

      final tripId = await repository.addTrip(trip);

      await _saveTripToPrefs(tripId, now, event.durationMinutes);
      try {
        await initializeService();
      } catch (_) {}

      emit(
        TripStartSuccess(
          tripId: tripId,
          durationMinutes: event.durationMinutes,
        ),
      );
    } catch (e) {
      emit(TripError('Lỗi khi bắt đầu chuyến đi: ${e.toString()}'));
    }
  }

  Future<void> _onTriggerInstantAlert(
    TriggerInstantAlertEvent event,
    Emitter<TripState> emit,
  ) async {
    try {
      final guardians = await guardianRepository.getGuardians();
      if (guardians.isEmpty) {
        emit(TripError('Vui lòng thêm người bảo vệ'));
        return;
      }
      emit(TripAlertSending());
      final uid = repository.getUserId();
      final location = await LocationService.getCurrentLocation();
      final alert = {
        'tripId': null,
        'userId': uid,
        'triggerMethod': event.triggerMethod,
        'timestamp': FieldValue.serverTimestamp(),
        'location': location != null
            ? GeoPoint(
                location['latitude'] as double,
                location['longitude'] as double,
              )
            : null,
        'status': 'Sent',
        'alertType': 'Push',
      };
      await repository.addAlertLog(alert);
      try {
        await EmergencyUtils.sendTripAlertWithRepo(
          guardianRepository,
          triggerMethod: event.triggerMethod,
        );
      } catch (_) {}

      emit(TripAlertSent(message: 'ĐÃ GỬI CẢNH BÁO KHẨN CẤP!'));
    } catch (e) {
      emit(TripError('Lỗi khi gửi cảnh báo: ${e.toString()}'));
    }
  }
}
