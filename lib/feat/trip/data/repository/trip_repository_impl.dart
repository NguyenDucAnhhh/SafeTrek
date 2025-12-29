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
  Future<List<Trip>> getTrips() async {
    final uid = _getUidOrThrow();
    final models = await remoteDataSource.getTrips(uid);
    return models
        .map((m) => Trip(name: m.name, startedAt: m.startedAt, status: m.status))
        .toList();
  }

  @override
  Future<String> addTrip(Trip trip) async {
    final uid = _getUidOrThrow();
    final model = TripModel(name: trip.name, startedAt: trip.startedAt, status: trip.status);
    return await remoteDataSource.addTrip(uid, model);
  }
}
