import 'package:safetrek_project/feat/trip/domain/entity/trip.dart';

abstract class TripRepository {
  Future<List<Trip>> getTrips();
  Future<String> addTrip(Trip trip);
  Future<List<Trip>> getActiveTrips();
  Stream<String?> subscribeToTripStatus(String tripId);
  Future<void> addLocationBatch(List<Map<String, dynamic>> locations);
  Future<void> addAlertLog(Map<String, dynamic> alert);
  Future<void> updateTrip(String tripId, Map<String, dynamic> data);
}
