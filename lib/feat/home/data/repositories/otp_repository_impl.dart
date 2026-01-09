import 'package:safetrek_project/feat/home/data/datasources/otp_remote_data_source.dart';
import 'package:safetrek_project/feat/home/domain/repositories/otp_repository.dart';

class OtpRepositoryImpl implements OtpRepository {
  final OtpRemoteDataSource remoteDataSource;

  OtpRepositoryImpl({required this.remoteDataSource});

  @override
  Future<String> sendOtp(String email) {
    return remoteDataSource.sendOtp(email);
  }
}
