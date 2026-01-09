import 'package:safetrek_project/feat/home/domain/repositories/otp_repository.dart';

class SendOtp {
  final OtpRepository repository;

  SendOtp(this.repository);

  Future<String> call(String email) {
    return repository.sendOtp(email);
  }
}
