import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:safetrek_project/feat/trip/domain/entity/trip.dart';

class TripModel extends Trip {
  final String? id;

  TripModel({
    this.id,
    required String name,
    required DateTime startedAt,
    String? status,
    Map<String, dynamic>? lastLocation,
  }) : super(
    name: name,
    startedAt: startedAt,
    status: status,
    lastLocation: lastLocation,
  );

  factory TripModel.fromFirestore(QueryDocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return TripModel(
      id: doc.id,
      name: data['name'] as String? ?? '',
      startedAt: (data['startedAt'] as Timestamp).toDate(),
      status: data['status'] as String?,
      lastLocation: data['lastLocation'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'startedAt': Timestamp.fromDate(startedAt),
      'status': status,
      'lastLocation': lastLocation,
    };
  }
}
