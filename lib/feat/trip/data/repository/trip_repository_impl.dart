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

  // Note: trip statuses are stored in Vietnamese in Firestore.

  @override
  Future<List<Trip>> getTrips() async {
    final uid = _getUidOrThrow();
    final models = await remoteDataSource.getTrips(uid);
    return models
      .map((m) => Trip(
          name: m.name,
          startedAt: m.startedAt,
          expectedEndTime: m.expectedEndTime,
          status: m.status, // stored in Vietnamese
          lastLocation: m.lastLocation,
        ))
      .toList();
  }

  @override
  Future<String> addTrip(Trip trip) async {
    final uid = _getUidOrThrow();
    // Khi thêm chuyến đi, lưu trạng thái bằng tiếng Việt
    String statusToSave;
    switch (trip.status) {
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
        statusToSave = trip.status ?? 'Không rõ';
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
}
