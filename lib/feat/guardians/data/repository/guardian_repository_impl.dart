import 'package:safetrek_project/feat/guardians/data/data_source/guardian_remote_data_source.dart';
import 'package:safetrek_project/feat/guardians/data/model/guardian_model.dart';
import 'package:safetrek_project/feat/guardians/domain/entity/Guardian.dart';
import 'package:safetrek_project/feat/guardians/domain/repository/guardian_repository.dart';

class GuardianRepositoryImpl implements GuardianRepository {
  final GuardianRemoteDataSource remoteDataSource;

  GuardianRepositoryImpl(this.remoteDataSource);

  // ID của user hiện tại (Sẽ lấy từ Auth của người kia mời bạn)
  final String _currentUserId = 'fBMzuk8GwEjeqccc1j54';

  @override
  Future<List<Guardian>> getGuardians() async {
    // Gọi DataSource để lấy danh sách Model rồi trả về dưới dạng Entity Guardian
    return await remoteDataSource.getGuardians(_currentUserId);
  }

  @override
  Future<void> addGuardian(Guardian guardian) async {
    // Chuyển đổi từ Entity sang Model để phù hợp với Firestore
    final model = GuardianModel(
      name: guardian.name,
      phone: guardian.phone,
      email: guardian.email,
      status: 'Pending', // Theo cấu trúc trong ảnh bạn gửi
    );
    await remoteDataSource.addGuardian(_currentUserId, model);
  }

  @override
  Future<void> deleteGuardian(String docId) async {
    return await remoteDataSource.deleteGuardian(docId);
  }
}
