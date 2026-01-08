import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/guardian_model.dart';

class GuardianRemoteDataSource {
  final FirebaseFirestore firestore;

  GuardianRemoteDataSource(this.firestore);

  Stream<List<GuardianModel>> getGuardiansStream(String userId) {
    final userRef = firestore.collection('users').doc(userId);
    return firestore
        .collection('guardians')
        .where('userID', isEqualTo: userRef)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => GuardianModel.fromFirestore(doc))
          .toList();
    });
  }

  // Lấy danh sách người bảo vệ từ Collection 'guardians' ở gốc
  Future<List<GuardianModel>> getGuardians(String userId) async {
    // Tạo Reference đến user để lọc (vì trong ảnh userID là kiểu Reference)
    final userRef = firestore.collection('users').doc(userId);

    // Thử query trường 'userID' dưới dạng DocumentReference trước
    final snapshotRef = await firestore
        .collection('guardians')
        .where('userID', isEqualTo: userRef)
        .get();

    if (snapshotRef.docs.isNotEmpty) {
      return snapshotRef.docs
          .map((doc) => GuardianModel.fromFirestore(doc))
          .toList();
    }

    // Nếu không có kết quả, thử query bằng chuỗi uid (nếu dữ liệu được lưu dưới dạng String)
    final snapshotString = await firestore
        .collection('guardians')
        .where('userID', isEqualTo: userId)
        .get();

    return snapshotString.docs
        .map((doc) => GuardianModel.fromFirestore(doc))
        .toList();
  }

  // Thêm người bảo vệ mới vào Collection 'guardians' ở gốc và trả về ID
  Future<String> addGuardian(String userId, GuardianModel guardian, {bool storeAsReference = true}) async {
    final userRef = firestore.collection('users').doc(userId);

    // Tạo dữ liệu để lưu
    final data = guardian.toFirestore();

    // Nếu muốn, lưu `userID` dưới dạng DocumentReference, ngược lại lưu chuỗi uid
    data['userID'] = storeAsReference ? userRef : userId;

    final docRef = await firestore.collection('guardians').add(data);
    return docRef.id;
  }

  // Xóa người bảo vệ theo Document ID
  Future<void> deleteGuardian(String docId) async {
    await firestore.collection('guardians').doc(docId).delete();
  }
}
