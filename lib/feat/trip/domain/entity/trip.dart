class Trip {
  final String? id;
  final String name;
  final DateTime startedAt;
  final DateTime expectedEndTime;
  final String? status;
  final Map<String, dynamic>? lastLocation;

  Trip({
    this.id,
    required this.name,
    required this.startedAt,
    required this.expectedEndTime,
    this.status,
    this.lastLocation,
  });
}
