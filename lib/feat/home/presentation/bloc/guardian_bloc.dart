import 'package:flutter_bloc/flutter_bloc.dart';
import 'guardian_event.dart';
import 'guardian_state.dart';
import 'package:safetrek_project/feat/guardians/domain/entity/Guardian.dart';

class GuardianBloc extends Bloc<GuardianEvent, GuardianState> {
  // Danh sách tạm thời để demo (Trong thực tế sẽ gọi UseCase)
  final List<Guardian> _mockGuardians = [
    Guardian(name: 'Nguyễn Đức Anh', phone: '0987654321', email: 'a@gmail.com', isAccepted: true),
    Guardian(name: 'Trần Thị B', phone: '0123456789', email: 'b@gmail.com', isAccepted: false),
  ];

  GuardianBloc() : super(GuardianInitial()) {
    // Xử lý sự kiện tải danh sách
    on<LoadGuardiansEvent>((event, emit) async {
      emit(GuardianLoading());
      try {
        // Giả lập delay mạng
        await Future.delayed(const Duration(milliseconds: 500));
        emit(GuardianLoaded(List.from(_mockGuardians)));
      } catch (e) {
        emit(const GuardianError("Không thể tải danh sách người bảo vệ"));
      }
    });

    // Xử lý sự kiện thêm người bảo vệ
    on<AddGuardianEvent>((event, emit) async {
      // Có thể emit Loading nếu muốn hiện overlay loading
      try {
        _mockGuardians.add(event.guardian);
        emit(const GuardianAddedSuccess("Thêm người bảo vệ thành công !"));
        
        // Sau khi thêm xong, phát lại trạng thái Loaded với danh sách mới
        emit(GuardianLoaded(List.from(_mockGuardians)));
      } catch (e) {
        emit(const GuardianError("Lỗi khi thêm người bảo vệ"));
      }
    });

    // Xử lý sự kiện xóa người bảo vệ
    on<RemoveGuardianEvent>((event, emit) async {
      try {
        _mockGuardians.removeWhere((g) => g.phone == event.phone);
        emit(GuardianLoaded(List.from(_mockGuardians)));
      } catch (e) {
        emit(const GuardianError("Lỗi khi xóa người bảo vệ"));
      }
    });
  }
}
