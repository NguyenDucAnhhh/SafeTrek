abstract class TripMonitoringEvent {}

class TripMonitoringStarted extends TripMonitoringEvent {
  final int durationInMinutes;
  final String tripId;

  TripMonitoringStarted({
    required this.durationInMinutes,
    required this.tripId,
  });
}

class TripMonitoringTicked extends TripMonitoringEvent {}

class TripMonitoringTripStatusChanged extends TripMonitoringEvent {
  final String status;
  TripMonitoringTripStatusChanged(this.status);
}

class TripMonitoringPanicPressed extends TripMonitoringEvent {
  final String triggerMethod;
  TripMonitoringPanicPressed({this.triggerMethod = 'PanicButton'});
}

class TripMonitoringPinSubmitted extends TripMonitoringEvent {
  final String pin;
  TripMonitoringPinSubmitted(this.pin);
}
