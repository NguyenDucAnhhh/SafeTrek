import 'package:safetrek_project/feat/guardians/data/data_source/guardian_remote_data_source.dart';
import 'package:safetrek_project/feat/guardians/data/model/guardian_model.dart';
import 'package:safetrek_project/feat/guardians/domain/entity/Guardian.dart';
import 'package:safetrek_project/feat/guardians/domain/repository/guardian_repository.dart';

class GuardianRepositoryImpl implements GuardianRepository {
  final GuardianRemoteDataSource remoteDataSource;

  GuardianRepositoryImpl(this.remoteDataSource);

  final String _currentUserId = 'fBMzuk8GwEjeqccc1j54';

  @override
  Future<List<Guardian>> getGuardians() async {
    return await remoteDataSource.getGuardians(_currentUserId);
  }

  @override
  Future<String> addGuardian(Guardian guardian) async {
    final model = GuardianModel(
      name: guardian.name,
      phone: guardian.phone,
      email: guardian.email,
      status: 'Pending',
    );
    // TRẢ VỀ ID THẬT TỪ FIRESTORE
    return await remoteDataSource.addGuardian(_currentUserId, model);
  }

  @override
  Future<void> deleteGuardian(String docId) async {
    return await remoteDataSource.deleteGuardian(docId);
  }
}
