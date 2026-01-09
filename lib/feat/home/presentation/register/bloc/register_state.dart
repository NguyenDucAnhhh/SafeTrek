import 'package:equatable/equatable.dart';

abstract class RegisterState extends Equatable {
  const RegisterState();

  @override
  List<Object> get props => [];
}

// Trạng thái ban đầu
class RegisterInitial extends RegisterState {}

// Trạng thái đang gửi OTP
class OtpSending extends RegisterState {}

// Gửi OTP thành công
class OtpSentSuccess extends RegisterState {
  final String otp;

  const OtpSentSuccess(this.otp);

  @override
  List<Object> get props => [otp];
}

// Gửi OTP thất bại
class OtpSendFailure extends RegisterState {
  final String message;

  const OtpSendFailure(this.message);

  @override
  List<Object> get props => [message];
}
