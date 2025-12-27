import 'package:flutter_bloc/flutter_bloc.dart';
import 'guardian_event.dart';
import 'guardian_state.dart';
import 'package:safetrek_project/feat/guardians/domain/repository/guardian_repository.dart';

class GuardianBloc extends Bloc<GuardianEvent, GuardianState> {
  final GuardianRepository repository;

  GuardianBloc(this.repository) : super(GuardianInitial()) {
    
    // Xử lý sự kiện tải danh sách người bảo vệ từ Firebase
    on<LoadGuardiansEvent>((event, emit) async {
      emit(GuardianLoading());
      try {
        final guardians = await repository.getGuardians();
        emit(GuardianLoaded(guardians));
      } catch (e) {
        emit(GuardianError("Không thể tải danh sách: ${e.toString()}"));
      }
    });

    // Xử lý sự kiện thêm người bảo vệ mới
    on<AddGuardianEvent>((event, emit) async {
      try {
        await repository.addGuardian(event.guardian);
        emit(const GuardianAddedSuccess("Thêm người bảo vệ thành công !"));
        
        // Tự động tải lại danh sách mới để cập nhật UI
        add(LoadGuardiansEvent());
      } catch (e) {
        emit(GuardianError("Lỗi khi thêm người bảo vệ: $e"));
      }
    });

    // Xử lý sự kiện xóa người bảo vệ
    on<RemoveGuardianEvent>((event, emit) async {
      print("Đang chuẩn bị xóa ID: ${event.docId}");
      try {
        // Gọi hàm xóa với event.docId
        await repository.deleteGuardian(event.docId);
        add(LoadGuardiansEvent()); // Tải lại danh sách
      } catch (e) {
        emit(GuardianError("Lỗi khi xóa: $e"));
      }
    });
  }
}
