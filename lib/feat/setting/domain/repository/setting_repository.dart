import 'package:safetrek_project/core/error/failures.dart';
import 'package:safetrek_project/feat/setting/domain/entity/user_profile.dart';

abstract class SettingRepository {
  Future<Either<Failure, UserProfile>> getUserProfile();
  Future<Either<Failure, void>> updateUserProfile(UserProfile userProfile);
}
