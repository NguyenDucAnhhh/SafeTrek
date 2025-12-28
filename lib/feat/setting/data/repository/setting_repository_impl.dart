import 'package:dartz/dartz.dart';
import 'package:safetrek_project/core/error/exceptions.dart';
import 'package:safetrek_project/core/error/failures.dart';
import 'package:safetrek_project/feat/setting/data/datasource/setting_datasource.dart';
import 'package:safetrek_project/feat/setting/domain/entity/user_profile.dart';
import 'package:safetrek_project/feat/setting/domain/repository/setting_repository.dart';

class SettingRepositoryImpl implements SettingRepository {
  final SettingDataSource dataSource;

  SettingRepositoryImpl({required this.dataSource});

  @override
  Future<Either<Failure, UserProfile>> getUserProfile() async {
    try {
      final userProfile = await dataSource.getUserProfile();
      return Right(userProfile);
    } on ServerException {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, void>> updateUserProfile(UserProfile userProfile) async {
    // TODO: Implement updateUserProfile
    throw UnimplementedError();
  }
}
