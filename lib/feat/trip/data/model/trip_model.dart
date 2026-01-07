import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:safetrek_project/feat/trip/domain/entity/trip.dart';

class TripModel extends Trip {
  final String? id;

  TripModel({
    this.id,
    required String name,
    required DateTime startedAt,
    required DateTime expectedEndTime,
    String? status,
    Map<String, dynamic>? lastLocation,
  }) : super(
          name: name,
          startedAt: startedAt,
          expectedEndTime: expectedEndTime,
          status: status,
          lastLocation: lastLocation,
        );

  factory TripModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final geoPoint = data['lastLocation'] as GeoPoint?;

    return TripModel(
      id: doc.id,
      name: data['name'] as String? ?? '',
      startedAt: (data['startedAt'] as Timestamp).toDate(),
      expectedEndTime: (data['expectedEndTime'] as Timestamp).toDate(),
      status: data['status'] as String?,
      lastLocation: geoPoint != null
          ? {'latitude': geoPoint.latitude, 'longitude': geoPoint.longitude}
          : null,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'startedAt': Timestamp.fromDate(startedAt),
      'expectedEndTime': Timestamp.fromDate(expectedEndTime),
      'status': status,
      'lastLocation': lastLocation != null
          ? GeoPoint(lastLocation!['latitude'], lastLocation!['longitude'])
          : null,
    };
  }
}
