import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/trip_model.dart';

class TripRemoteDataSource {
  final FirebaseFirestore firestore;

  TripRemoteDataSource(this.firestore);

  // Lấy danh sách chuyến đi của user
  Future<List<TripModel>> getTrips(String userId) async {
    final snapshot = await firestore
        .collection('trips')
        .where('userId', isEqualTo: userId)
        .get();

    return snapshot.docs.map((d) => TripModel.fromFirestore(d)).toList();
  }

  // Thêm 1 chuyến đi mới
  Future<String> addTrip(String userId, TripModel trip) async {
    final data = trip.toFirestore();
    data['userId'] = userId;
    final docRef = await firestore.collection('trips').add(data);
    return docRef.id;
  }

  // Cập nhật trạng thái chuyến đi
  Future<void> updateTripStatus(String tripId, String status) async {
    await firestore.collection('trips').doc(tripId).update({'status': status});
  }

  // Lấy active trips (status == 'Đang tiến hành') cho user
  Future<List<TripModel>> getActiveTrips(String userId) async {
    final snapshot = await firestore
        .collection('trips')
        .where('userId', isEqualTo: userId)
        .where('status', isEqualTo: 'Đang tiến hành')
        .get();
    return snapshot.docs.map((d) => TripModel.fromFirestore(d)).toList();
  }

  // Stream status của 1 trip
  Stream<DocumentSnapshot> tripStatusStream(String tripId) {
    return firestore.collection('trips').doc(tripId).snapshots();
  }

  // Thêm 1 bản ghi location vào collection
  Future<void> addLocation(Map<String, dynamic> location) async {
    await firestore.collection('locationHistories').add(location);
  }

  // Batch thêm nhiều bản ghi locations
  Future<void> addLocationBatch(List<Map<String, dynamic>> locations) async {
    final batch = firestore.batch();
    final col = firestore.collection('locationHistories');
    for (final item in locations) {
      final ref = col.doc();
      batch.set(ref, item);
    }
    await batch.commit();
  }

  // Thêm 1 bản ghi alert log
  Future<void> addAlertLog(Map<String, dynamic> alert) async {
    await firestore.collection('alertLogs').add(alert);
  }

  //  Cập nhật chung
  Future<void> updateTrip(String tripId, Map<String, dynamic> data) async {
    await firestore.collection('trips').doc(tripId).update(data);
  }
}
