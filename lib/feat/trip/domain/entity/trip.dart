class Trip {
  final String name;
  final DateTime startedAt;
  final String? status;
  final Map<String, dynamic>? lastLocation; // {latitude, longitude}

  Trip({
    required this.name,
    required this.startedAt,
    this.status,
    this.lastLocation,
  });
}
