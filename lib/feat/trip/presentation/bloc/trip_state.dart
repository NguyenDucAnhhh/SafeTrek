import 'package:safetrek_project/feat/trip/domain/entity/trip.dart';

abstract class TripState {}

class TripInitial extends TripState {}

class TripLoading extends TripState {}

class TripLoaded extends TripState {
  final List<Trip> trips;
  TripLoaded(this.trips);
}

class TripError extends TripState {
  final String message;
  TripError(this.message);
}

class TripAddedSuccess extends TripState {
  final String message;
  final String tripId;
  TripAddedSuccess({required this.message, required this.tripId});
}

class TripCheckingActive extends TripState {}

class TripNoActiveTrip extends TripState {}

class TripResumeReady extends TripState {
  final String tripId;
  final int remainingMinutes;
  TripResumeReady({required this.tripId, required this.remainingMinutes});
}

class TripStarting extends TripState {}

class TripStartSuccess extends TripState {
  final String tripId;
  final int durationMinutes;
  TripStartSuccess({required this.tripId, required this.durationMinutes});
}

class TripAlertSending extends TripState {}

class TripAlertSent extends TripState {
  final String message;
  TripAlertSent({required this.message});
}
