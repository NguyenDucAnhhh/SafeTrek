import 'package:safetrek_project/feat/trip/domain/entity/trip.dart';
import 'package:safetrek_project/feat/trip/domain/repository/trip_repository.dart';

class GetTrips {
  final TripRepository repository;
  GetTrips(this.repository);

  Future<List<Trip>> call() async {
    return await repository.getTrips();
  }
}
