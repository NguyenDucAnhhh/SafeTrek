import 'package:flutter_bloc/flutter_bloc.dart';
import 'guardian_event.dart';
import 'guardian_state.dart';
import 'package:safetrek_project/feat/guardians/domain/repository/guardian_repository.dart';

class GuardianBloc extends Bloc<GuardianEvent, GuardianState> {
  final GuardianRepository repository;

  GuardianBloc(this.repository) : super(GuardianInitial()) {
    
    on<LoadGuardiansEvent>((event, emit) async {
      emit(GuardianLoading());
      try {
        final guardians = await repository.getGuardians();
        emit(GuardianLoaded(guardians));
      } catch (e) {
        emit(GuardianError("Không thể tải danh sách: ${e.toString()}"));
      }
    });

    on<AddGuardianEvent>((event, emit) async {
      try {
        // Lấy ID thật từ Firebase sau khi thêm thành công
        final String docId = await repository.addGuardian(event.guardian);
        
        emit(const GuardianAddedSuccess("Đã lưu thông tin người bảo vệ!"));

        // TẠO LINK THẬT VỚI ID CHÍNH XÁC
        final String inviteLink = "https://safetrek-2b5a0.web.app?id=$docId";
        final String inviteMessage = "Tôi muốn thêm bạn làm người bảo vệ trên SafeTrek. Nhấn vào link để xác nhận giúp tôi nhé: $inviteLink";

        emit(GuardianInviteReady(message: inviteMessage, phone: event.guardian.phone));
        
        // Tải lại danh sách
        add(LoadGuardiansEvent());
      } catch (e) {
        emit(GuardianError("Lỗi khi thêm: ${e.toString()}"));
      }
    });

    on<RemoveGuardianEvent>((event, emit) async {
      try {
        await repository.deleteGuardian(event.docId);
        add(LoadGuardiansEvent()); 
      } catch (e) {
        emit(GuardianError("Lỗi khi xóa: $e"));
      }
    });
  }
}
