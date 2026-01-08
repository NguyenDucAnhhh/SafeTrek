import 'package:firebase_auth/firebase_auth.dart';
import 'package:safetrek_project/feat/guardians/data/data_source/guardian_remote_data_source.dart';
import 'package:safetrek_project/feat/guardians/data/model/guardian_model.dart';
import 'package:safetrek_project/feat/guardians/domain/entity/Guardian.dart';
import 'package:safetrek_project/feat/guardians/domain/repository/guardian_repository.dart';

class GuardianRepositoryImpl implements GuardianRepository {
  final GuardianRemoteDataSource remoteDataSource;

  GuardianRepositoryImpl(this.remoteDataSource);

  String _getUidOrThrow() {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) throw Exception('Người dùng chưa đăng nhập');
    return uid;
  }

  @override
  String getUserId() {
    return _getUidOrThrow();
  }

  @override
  Stream<List<Guardian>> getGuardiansStream() {
    final uid = _getUidOrThrow();
    // Ánh xạ Stream<List<GuardianModel>> thành Stream<List<Guardian>>
    return remoteDataSource.getGuardiansStream(uid).map((models) {
      return models.cast<Guardian>().toList();
    });
  }

  @override
  Future<List<Guardian>> getGuardians() async {
    final uid = _getUidOrThrow();
    final models = await remoteDataSource.getGuardians(uid);
    // Ánh xạ List<GuardianModel> thành List<Guardian>
    return models.cast<Guardian>().toList();
  }

  @override
  Future<String> addGuardian(Guardian guardian) async {
    final model = GuardianModel(
      name: guardian.name,
      phone: guardian.phone,
      email: guardian.email,
      status: 'Pending',
    );
    final uid = _getUidOrThrow();
    return await remoteDataSource.addGuardian(uid, model);
  }

  @override
  Future<void> deleteGuardian(String docId) async {
    return await remoteDataSource.deleteGuardian(docId);
  }
}
