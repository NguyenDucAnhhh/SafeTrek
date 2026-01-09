import 'package:safetrek_project/feat/trip/data/data_source/trip_remote_data_source.dart';
import 'package:safetrek_project/feat/trip/data/model/trip_model.dart';
import 'package:safetrek_project/feat/trip/domain/entity/trip.dart';
import 'package:safetrek_project/feat/trip/domain/repository/trip_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TripRepositoryImpl implements TripRepository {
  final TripRemoteDataSource remoteDataSource;

  TripRepositoryImpl(this.remoteDataSource);

  String _getUidOrThrow() {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) throw Exception('Người dùng chưa đăng nhập');
    return uid;
  }

  @override
  String getUserId() => _getUidOrThrow();

  // Note: trip statuses are stored in Vietnamese in Firestore.

  @override
  Future<List<Trip>> getTrips() async {
    final uid = _getUidOrThrow();
    final models = await remoteDataSource.getTrips(uid);
    return models
        .map(
          (m) => Trip(
            id: m.id,
            name: m.name,
            startedAt: m.startedAt,
            expectedEndTime: m.expectedEndTime,
            status: m.status,
            lastLocation: m.lastLocation,
          ),
        )
        .toList();
  }

  @override
  Future<String> addTrip(Trip trip) async {
    final uid = _getUidOrThrow();
    // Khi thêm chuyến đi, lưu trạng thái bằng tiếng Việt
    String statusToSave;
    final status = trip.status ?? '';
    switch (status) {
      case 'Active':
      case 'Đang tiến hành':
        statusToSave = 'Đang tiến hành';
        break;
      case 'Alarmed':
      case 'Báo động':
        statusToSave = 'Báo động';
        break;
      case 'CompletedSafe':
      case 'Kết thúc an toàn':
        statusToSave = 'Kết thúc an toàn';
        break;
      default:
        statusToSave = status.isNotEmpty ? status : 'Không rõ';
    }
    final model = TripModel(
      name: trip.name,
      startedAt: trip.startedAt,
      expectedEndTime: trip.expectedEndTime,
      status: statusToSave,
      lastLocation: trip.lastLocation,
    );
    return await remoteDataSource.addTrip(uid, model);
  }

  @override
  Future<List<Trip>> getActiveTrips() async {
    final uid = _getUidOrThrow();
    final models = await remoteDataSource.getActiveTrips(uid);
    return models
        .map(
          (m) => Trip(
            id: m.id,
            name: m.name,
            startedAt: m.startedAt,
            expectedEndTime: m.expectedEndTime,
            status: m.status,
            lastLocation: m.lastLocation,
          ),
        )
        .toList();
  }

  @override
  Stream<String?> subscribeToTripStatus(String tripId) {
    return remoteDataSource.tripStatusStream(tripId).map((doc) {
      final data = doc.data();
      if (data == null) return null;
      if (data is Map<String, dynamic>) {
        return data['status'] as String?;
      }
      try {
        return (data as Map)['status'] as String?;
      } catch (_) {
        return null;
      }
    });
  }

  @override
  Future<void> addLocationBatch(List<Map<String, dynamic>> locations) async {
    await remoteDataSource.addLocationBatch(locations);
  }

  @override
  Future<void> addAlertLog(Map<String, dynamic> alert) async {
    await remoteDataSource.addAlertLog(alert);
  }

  @override
  Future<void> updateTrip(String tripId, Map<String, dynamic> data) async {
    await remoteDataSource.updateTrip(tripId, data);
  }
}
