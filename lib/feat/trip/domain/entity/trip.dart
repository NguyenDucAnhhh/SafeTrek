class Trip {
  final String name;
  final DateTime startedAt;
  final DateTime expectedEndTime; // Thêm trường này
  final String? status;
  final Map<String, dynamic>? lastLocation; // {latitude, longitude}

  Trip({
    required this.name,
    required this.startedAt,
    required this.expectedEndTime, // Thêm vào constructor
    this.status,
    this.lastLocation,
  });
}
