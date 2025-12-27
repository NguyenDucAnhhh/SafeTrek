import '../entity/Guardian.dart';

abstract class GuardianRepository {
  Future<List<Guardian>> getGuardians();
  Future<void> addGuardian(Guardian guardian);
  Future<void> deleteGuardian(String phone);
}
