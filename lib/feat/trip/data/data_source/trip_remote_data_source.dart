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
}
