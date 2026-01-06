abstract class UserRepository {
  /// Tạo document user với id = [uid]
  Future<void> createUser(String uid, Map<String, dynamic> userData);

  /// Xóa document user (dùng cho rollback nếu cần)
  Future<void> deleteUserDocument(String uid);
}
