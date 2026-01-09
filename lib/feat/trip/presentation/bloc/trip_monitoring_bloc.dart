import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:safetrek_project/core/utils/emergency_utils.dart';
import 'package:safetrek_project/feat/guardians/domain/repository/guardian_repository.dart';
import 'package:safetrek_project/feat/trip/data/services/location_service.dart';
import 'package:safetrek_project/feat/trip/domain/repository/trip_repository.dart';

import 'trip_monitoring_event.dart';
import 'trip_monitoring_state.dart';

class TripMonitoringBloc
    extends Bloc<TripMonitoringEvent, TripMonitoringState> {
  final TripRepository tripRepository;
  final GuardianRepository guardianRepository;
  final FirebaseAuth auth;
  final FirebaseFirestore firestore;
  final FirebaseFunctions functions;

  TripMonitoringBloc({
    required this.tripRepository,
    required this.guardianRepository,
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
    FirebaseFunctions? functions,
  }) : auth = auth ?? FirebaseAuth.instance,
       firestore = firestore ?? FirebaseFirestore.instance,
       functions = functions ?? FirebaseFunctions.instance,
       super(const TripMonitoringState(remainingTime: Duration.zero)) {
    on<TripMonitoringStarted>(_onStarted);
    on<TripMonitoringTicked>(_onTicked);
    on<TripMonitoringTripStatusChanged>(_onTripStatusChanged);
    on<TripMonitoringPanicPressed>(_onPanicPressed);
    on<TripMonitoringPinSubmitted>(_onPinSubmitted);
  }

  Timer? _countdownTimer;
  Timer? _flushTimer;
  Timer? _sampleTimer;
  StreamSubscription<String?>? _tripStatusSubscription;
  StreamSubscription<Map<String, dynamic>>? _positionSubscription;

  int? _prefsStartTimeMs;
  int? _prefsDurationSec;
  String? _tripId;

  final List<Map<String, dynamic>> _locationBuffer = [];
  bool _isFlushing = false;
  bool _isSampling = false;
  String? _lastStatusHandled;
  DateTime? _lastRecordedAt;
  double? _lastLat;
  double? _lastLng;

  Future<void> _onStarted(
    TripMonitoringStarted event,
    Emitter<TripMonitoringState> emit,
  ) async {
    _tripId = event.tripId;
    emit(
      state.copyWith(remainingTime: Duration(minutes: event.durationInMinutes)),
    );

    await _initFromPrefs(emit);

    _startCountdown();
    _startLocationTracking();
    _startFlushTimer();
    _startSampling();
    _listenToTripStatus();

    // Persist one immediate sample at start.
    unawaited(_recordLocation());
  }

  Future<void> _initFromPrefs(Emitter<TripMonitoringState> emit) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _prefsStartTimeMs = prefs.getInt('trip_start_time');
      _prefsDurationSec = prefs.getInt('trip_duration');
      final tripIdPref = prefs.getString('current_trip_id');
      if (tripIdPref != null && tripIdPref.isNotEmpty) {
        _tripId = tripIdPref;
      }

      if (_prefsStartTimeMs != null && _prefsDurationSec != null) {
        final now = DateTime.now().millisecondsSinceEpoch;
        final elapsed = ((now - _prefsStartTimeMs!) / 1000).round();
        final remainingSec = _prefsDurationSec! - elapsed;
        emit(
          state.copyWith(
            remainingTime: Duration(
              seconds: remainingSec > 0 ? remainingSec : 0,
            ),
          ),
        );
      }
    } catch (_) {
      // keep default duration
    }
  }

  void _startCountdown() {
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      add(TripMonitoringTicked());
    });
  }

  Future<void> _onTicked(
    TripMonitoringTicked event,
    Emitter<TripMonitoringState> emit,
  ) async {
    try {
      final startTime = _prefsStartTimeMs;
      final duration = _prefsDurationSec;
      if (startTime == null || duration == null) {
        emit(state.copyWith(remainingTime: Duration.zero));
        _countdownTimer?.cancel();
        return;
      }

      final now = DateTime.now().millisecondsSinceEpoch;
      final elapsed = ((now - startTime) / 1000).round();
      final remainingSec = duration - elapsed;
      if (remainingSec <= 0) {
        emit(state.copyWith(remainingTime: Duration.zero));
        _countdownTimer?.cancel();
        await _triggerAlert('Timeout', emit);
        return;
      }

      emit(state.copyWith(remainingTime: Duration(seconds: remainingSec)));
    } catch (e) {
      debugPrint('Countdown error: $e');
    }
  }

  void _listenToTripStatus() {
    final tripId = _tripId;
    if (tripId == null) return;

    _tripStatusSubscription?.cancel();
    _tripStatusSubscription = tripRepository
        .subscribeToTripStatus(tripId)
        .listen((status) {
          if (status == null) return;
          add(TripMonitoringTripStatusChanged(status));
        });
  }

  Future<void> _onTripStatusChanged(
    TripMonitoringTripStatusChanged event,
    Emitter<TripMonitoringState> emit,
  ) async {
    if (_lastStatusHandled == event.status) return;
    _lastStatusHandled = event.status;

    if (event.status == 'Báo động') {
      await _tripStatusSubscription?.cancel();
      emit(
        state.copyWith(
          effect: const TripMonitoringShowSnackBar(
            message: 'Chuyến đi đã báo động!',
            backgroundColor: Colors.red,
          ),
        ),
      );
      emit(state.copyWith(effect: const TripMonitoringNavigateHome()));
    }

    if (event.status == 'Kết thúc an toàn') {
      await _tripStatusSubscription?.cancel();
      emit(
        state.copyWith(
          effect: const TripMonitoringShowSnackBar(
            message: 'Đã xác nhận đến nơi an toàn!',
            backgroundColor: Colors.green,
          ),
        ),
      );
      emit(state.copyWith(effect: const TripMonitoringNavigateHome()));
    }
  }

  void _startLocationTracking() {
    _positionSubscription?.cancel();
    try {
      _positionSubscription = LocationService.getPositionStream().listen((
        location,
      ) async {
        final tripId = _tripId;
        if (tripId == null) return;

        final record = {
          'tripId': tripId,
          'latitude': location['latitude'],
          'longitude': location['longitude'],
          'timestamp': FieldValue.serverTimestamp(),
          'batteryLevel': null,
        };
        await _addToBuffer(record);
      });
    } catch (e) {
      debugPrint('Failed to start position stream: $e');
    }
  }

  void _startSampling() {
    _sampleTimer?.cancel();
    _sampleTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      unawaited(_recordLocation());
    });
  }

  Future<void> _recordLocation() async {
    if (_isSampling) return;
    _isSampling = true;
    try {
      final tripId = _tripId;
      if (tripId == null) return;

      final location = await LocationService.getCurrentLocation();
      if (location == null) return;

      final record = {
        'tripId': tripId,
        'latitude': location['latitude'],
        'longitude': location['longitude'],
        'timestamp': FieldValue.serverTimestamp(),
        'batteryLevel': null,
      };
      await _addToBuffer(record);
    } catch (e) {
      debugPrint('Error recording location: $e');
    } finally {
      _isSampling = false;
    }
  }

  Future<void> _addToBuffer(Map<String, dynamic> record) async {
    try {
      final lat = (record['latitude'] as num?)?.toDouble();
      final lng = (record['longitude'] as num?)?.toDouble();
      final now = DateTime.now();
      if (_lastRecordedAt != null && lat != null && lng != null) {
        final age = now.difference(_lastRecordedAt!);
        final latDiff = (_lastLat == null)
            ? double.infinity
            : (lat - _lastLat!).abs();
        final lngDiff = (_lastLng == null)
            ? double.infinity
            : (lng - _lastLng!).abs();
        if (age.inSeconds < 5 && latDiff < 0.00005 && lngDiff < 0.00005) {
          return;
        }
      }
      _locationBuffer.add(record);
      _lastRecordedAt = now;
      _lastLat = (record['latitude'] as num?)?.toDouble();
      _lastLng = (record['longitude'] as num?)?.toDouble();
    } catch (_) {
      _locationBuffer.add(record);
    }

    if (_locationBuffer.length >= 3) {
      await _flushLocationBuffer();
      return;
    }
  }

  void _startFlushTimer() {
    _flushTimer?.cancel();
    _flushTimer = Timer.periodic(const Duration(seconds: 30), (_) async {
      await _flushLocationBuffer();
    });
  }

  Future<void> _flushLocationBuffer() async {
    if (_locationBuffer.isEmpty) return;
    if (_isFlushing) return;
    _isFlushing = true;
    try {
      await tripRepository.addLocationBatch(
        List<Map<String, dynamic>>.from(_locationBuffer),
      );
      _locationBuffer.clear();
    } catch (e) {
      debugPrint('Failed to flush location buffer: $e');
    } finally {
      _isFlushing = false;
    }
  }

  Future<void> _onPanicPressed(
    TripMonitoringPanicPressed event,
    Emitter<TripMonitoringState> emit,
  ) async {
    await _triggerAlert(event.triggerMethod, emit);
  }

  Future<void> _onPinSubmitted(
    TripMonitoringPinSubmitted event,
    Emitter<TripMonitoringState> emit,
  ) async {
    try {
      final uid = auth.currentUser?.uid;
      final tripId = _tripId;
      if (uid == null || tripId == null) return;

      final userDoc = await firestore.collection('users').doc(uid).get();
      final safePIN = userDoc.data()?['safePIN'] as String?;
      final duressPIN = userDoc.data()?['duressPIN'] as String?;

      if (event.pin == safePIN) {
        await _completeTripSafely();
        emit(
          state.copyWith(
            effect: const TripMonitoringShowSnackBar(
              message: 'Đã xác nhận đến nơi an toàn!',
              backgroundColor: Colors.green,
            ),
          ),
        );
        emit(state.copyWith(effect: const TripMonitoringNavigateHome()));
        return;
      }

      if (event.pin == duressPIN) {
        await _triggerAlert('DuressPIN', emit, silent: true, markAlarm: true);
        emit(
          state.copyWith(
            effect: const TripMonitoringShowSnackBar(
              message: 'Đã xác nhận đến nơi an toàn!',
              backgroundColor: Colors.green,
            ),
          ),
        );
        emit(state.copyWith(effect: const TripMonitoringNavigateHome()));
        return;
      }

      emit(
        state.copyWith(
          effect: const TripMonitoringShowSnackBar(
            message: 'Mã PIN không chính xác',
            backgroundColor: Colors.red,
          ),
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          effect: TripMonitoringShowSnackBar(
            message: 'Lỗi: ${e.toString()}',
            backgroundColor: Colors.red,
          ),
        ),
      );
    }
  }

  Future<void> _completeTripSafely() async {
    final tripId = _tripId;
    if (tripId == null) return;

    _countdownTimer?.cancel();
    _positionSubscription?.cancel();
    _sampleTimer?.cancel();
    _flushTimer?.cancel();

    await _flushLocationBuffer();

    final lastLocation = await LocationService.getCurrentLocation();
    if (lastLocation != null) {
      final finalRecord = {
        'tripId': tripId,
        'latitude': lastLocation['latitude'],
        'longitude': lastLocation['longitude'],
        'timestamp': FieldValue.serverTimestamp(),
        'batteryLevel': null,
      };
      try {
        await tripRepository.addLocationBatch([finalRecord]);
      } catch (e) {
        debugPrint('Failed to persist final location on check-in: $e');
      }
    }

    await tripRepository.updateTrip(tripId, {
      'status': 'Kết thúc an toàn',
      'lastLocation': lastLocation != null
          ? GeoPoint(
              (lastLocation['latitude'] as num).toDouble(),
              (lastLocation['longitude'] as num).toDouble(),
            )
          : null,
      'actualEndTime': FieldValue.serverTimestamp(),
    });
  }

  Future<void> _triggerAlert(
    String triggerMethod,
    Emitter<TripMonitoringState> emit, {
    bool silent = false,
    bool markAlarm = true,
  }) async {
    if (state.isSendingAlert) return;
    emit(state.copyWith(isSendingAlert: true));

    try {
      _countdownTimer?.cancel();
      _positionSubscription?.cancel();
      _sampleTimer?.cancel();
      _flushTimer?.cancel();
      await _flushLocationBuffer();

      final tripId = _tripId;
      final user = auth.currentUser;
      if (tripId == null || user == null) return;

      final location = await LocationService.getCurrentLocation();
      if (location != null) {
        final finalRecord = {
          'tripId': tripId,
          'latitude': location['latitude'],
          'longitude': location['longitude'],
          'timestamp': FieldValue.serverTimestamp(),
          'batteryLevel': null,
        };
        try {
          await tripRepository.addLocationBatch([finalRecord]);
        } catch (e) {
          debugPrint('Failed to persist final location: $e');
        }
      }

      if (markAlarm) {
        final alert = {
          'tripId': tripId,
          'userId': user.uid,
          'triggerMethod': triggerMethod,
          'timestamp': FieldValue.serverTimestamp(),
          'location': location != null
              ? GeoPoint(
                  (location['latitude'] as num).toDouble(),
                  (location['longitude'] as num).toDouble(),
                )
              : null,
          'status': 'Sent',
          'alertType': 'Push',
        };

        await tripRepository.addAlertLog(alert);
        await tripRepository.updateTrip(tripId, {
          'status': 'Báo động',
          'actualEndTime': FieldValue.serverTimestamp(),
          'lastLocation': location != null
              ? GeoPoint(
                  (location['latitude'] as num).toDouble(),
                  (location['longitude'] as num).toDouble(),
                )
              : null,
        });

        try {
          final func = functions.httpsCallable('sendAlertSms');
          await func.call(<String, dynamic>{
            'tripId': tripId,
            'reason': triggerMethod,
          });
        } catch (e) {
          debugPrint('sendAlertSms failed: $e');
        }

        try {
          await EmergencyUtils.sendTripAlertWithRepo(
            guardianRepository,
            triggerMethod: triggerMethod,
          );
        } catch (e) {
          debugPrint('sendTripAlertWithRepo failed: $e');
        }

        if (!silent) {
          emit(
            state.copyWith(
              effect: const TripMonitoringShowSnackBar(
                message: 'ĐÃ GỬI CẢNH BÁO KHẨN CẤP!',
                backgroundColor: Colors.red,
              ),
            ),
          );
          emit(state.copyWith(effect: const TripMonitoringNavigateHome()));
        }
      } else {
        try {
          await EmergencyUtils.sendTripAlertWithRepo(
            guardianRepository,
            triggerMethod: triggerMethod,
          );
        } catch (e) {
          debugPrint('sendTripAlertWithRepo failed (silent): $e');
        }
      }
    } catch (e) {
      debugPrint('Error triggering alert: $e');
      emit(
        state.copyWith(
          effect: TripMonitoringShowSnackBar(
            message: 'Lỗi: ${e.toString()}',
            backgroundColor: Colors.red,
          ),
        ),
      );
    } finally {
      emit(state.copyWith(isSendingAlert: false));
    }
  }

  @override
  Future<void> close() async {
    _countdownTimer?.cancel();
    _flushTimer?.cancel();
    _sampleTimer?.cancel();
    await _tripStatusSubscription?.cancel();
    await _positionSubscription?.cancel();
    return super.close();
  }
}
