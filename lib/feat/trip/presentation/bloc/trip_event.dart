import 'package:safetrek_project/feat/trip/domain/entity/trip.dart';

abstract class TripEvent {}

class LoadTripsEvent extends TripEvent {}

class AddTripEvent extends TripEvent {
  final Trip trip;
  AddTripEvent(this.trip);
}

class CheckResumeActiveTripEvent extends TripEvent {
  final String? preferredTripId;
  CheckResumeActiveTripEvent({this.preferredTripId});
}

class StartOrResumeTripRequested extends TripEvent {
  final String destination;
  final int durationMinutes;

  StartOrResumeTripRequested({
    required this.destination,
    required this.durationMinutes,
  });
}

class TriggerInstantAlertEvent extends TripEvent {
  final String triggerMethod;
  TriggerInstantAlertEvent({this.triggerMethod = 'PanicButton'});
}
