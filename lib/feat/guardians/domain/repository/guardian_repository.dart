import '../entity/Guardian.dart';

abstract class GuardianRepository {
  Future<List<Guardian>> getGuardians();
  /// Trả về ID của bản ghi vừa tạo trên Firestore
  Future<String> addGuardian(Guardian guardian);
  Future<void> deleteGuardian(String docId);
}
