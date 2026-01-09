import 'package:flutter/material.dart';

abstract class TripMonitoringEffect {
  const TripMonitoringEffect();
}

class TripMonitoringShowSnackBar extends TripMonitoringEffect {
  final String message;
  final Color backgroundColor;
  const TripMonitoringShowSnackBar({
    required this.message,
    required this.backgroundColor,
  });
}

class TripMonitoringNavigateHome extends TripMonitoringEffect {
  const TripMonitoringNavigateHome();
}

class TripMonitoringState {
  final Duration remainingTime;
  final bool isSendingAlert;
  final TripMonitoringEffect? effect;

  const TripMonitoringState({
    required this.remainingTime,
    this.isSendingAlert = false,
    this.effect,
  });

  TripMonitoringState copyWith({
    Duration? remainingTime,
    bool? isSendingAlert,
    TripMonitoringEffect? effect,
  }) {
    return TripMonitoringState(
      remainingTime: remainingTime ?? this.remainingTime,
      isSendingAlert: isSendingAlert ?? this.isSendingAlert,
      effect: effect ?? this.effect,
    );
  }
}
