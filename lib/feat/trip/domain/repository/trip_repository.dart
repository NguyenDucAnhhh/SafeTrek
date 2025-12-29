import 'package:safetrek_project/feat/trip/domain/entity/trip.dart';

abstract class TripRepository {
  Future<List<Trip>> getTrips();
  Future<String> addTrip(Trip trip);
}
