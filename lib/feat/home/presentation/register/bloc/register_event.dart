import 'package:equatable/equatable.dart';

abstract class RegisterEvent extends Equatable {
  const RegisterEvent();

  @override
  List<Object> get props => [];
}

// Event được gửi khi người dùng nhấn nút 'Tiếp theo' để gửi OTP
class SendOtpRequested extends RegisterEvent {
  final String email;

  const SendOtpRequested(this.email);

  @override
  List<Object> get props => [email];
}
