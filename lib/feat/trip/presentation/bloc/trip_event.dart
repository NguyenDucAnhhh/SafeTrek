import 'package:safetrek_project/feat/trip/domain/entity/trip.dart';

abstract class TripEvent {}

class LoadTripsEvent extends TripEvent {}

class AddTripEvent extends TripEvent {
  final Trip trip;
  AddTripEvent(this.trip);
}
