import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:safetrek_project/feat/home/domain/usecases/send_otp.dart';
import 'register_event.dart';
import 'register_state.dart';

class RegisterBloc extends Bloc<RegisterEvent, RegisterState> {
  final SendOtp sendOtp;

  RegisterBloc({required this.sendOtp}) : super(RegisterInitial()) {
    on<SendOtpRequested>(_onSendOtpRequested);
  }

  void _onSendOtpRequested(SendOtpRequested event, Emitter<RegisterState> emit) async {
    emit(OtpSending());
    try {
      // Gọi use case để gửi OTP và chờ kết quả
      final otp = await sendOtp(event.email);
      // Nếu thành công, phát ra state OtpSentSuccess kèm theo mã OTP
      emit(OtpSentSuccess(otp));
    } catch (e) {
      // Nếu có lỗi, phát ra state OtpSendFailure kèm theo thông báo lỗi
      emit(OtpSendFailure(e.toString().replaceFirst('Exception: ', '')));
    }
  }
}
