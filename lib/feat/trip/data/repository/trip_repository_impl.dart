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

  // Hàm mới để dịch trạng thái sang tiếng Việt
  String _translateStatus(String? status) {
    switch (status) {
      case 'CompletedSafe':
        return 'Kết thúc an toàn';
      case 'Active':
        return 'Đang tiến hành';
      case 'Alarmed':
        return 'Báo động';
      case 'Bị ép buộc': // Giữ lại để tương thích nếu có dữ liệu cũ
        return 'Báo động (ép buộc)';
      default:
        return status ?? 'Không rõ';
    }
  }

  @override
  Future<List<Trip>> getTrips() async {
    final uid = _getUidOrThrow();
    final models = await remoteDataSource.getTrips(uid);
    return models
        .map((m) => Trip(
              name: m.name,
              startedAt: m.startedAt,
              expectedEndTime: m.expectedEndTime,
              status: _translateStatus(m.status), // Gọi hàm dịch ở đây
              lastLocation: m.lastLocation,
            ))
        .toList();
  }

  @override
  Future<String> addTrip(Trip trip) async {
    final uid = _getUidOrThrow();
    // Khi thêm chuyến đi, vẫn giữ trạng thái gốc là tiếng Anh
    final model = TripModel(
      name: trip.name,
      startedAt: trip.startedAt,
      expectedEndTime: trip.expectedEndTime,
      status: trip.status, // Giữ nguyên trạng thái gốc (e.g., 'Active')
      lastLocation: trip.lastLocation,
    );
    return await remoteDataSource.addTrip(uid, model);
  }
}
