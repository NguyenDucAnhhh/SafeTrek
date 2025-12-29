import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/guardian_model.dart';

class GuardianRemoteDataSource {
  final FirebaseFirestore firestore;

  GuardianRemoteDataSource(this.firestore);

  // Lấy danh sách người bảo vệ từ Collection 'guardians' ở gốc
  Future<List<GuardianModel>> getGuardians(String userId) async {
    // Tạo Reference đến user để lọc (vì trong ảnh userID là kiểu Reference)
    final userRef = firestore.collection('users').doc(userId);

    final snapshot = await firestore
        .collection('guardians') // Truy cập thẳng vào collection 'guardians' ở gốc
        .where('userID', isEqualTo: userRef) // Lọc những người bảo vệ của user này
        .get();

    return snapshot.docs
        .map((doc) => GuardianModel.fromFirestore(doc))
        .toList();
  }

  // Thêm người bảo vệ mới vào Collection 'guardians' ở gốc và trả về ID
  Future<String> addGuardian(String userId, GuardianModel guardian) async {
    final userRef = firestore.collection('users').doc(userId);
    
    // Tạo dữ liệu để lưu, đảm bảo userID là một Reference
    final data = guardian.toFirestore();
    data['userID'] = userRef;

    final docRef = await firestore
        .collection('guardians')
        .add(data);
        
    return docRef.id;
  }

  // Xóa người bảo vệ theo Document ID
  Future<void> deleteGuardian(String docId) async {
    await firestore.collection('guardians').doc(docId).delete();
  }
}
