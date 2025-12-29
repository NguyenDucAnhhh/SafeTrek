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
        // 1. Lấy UID của người dùng hiện tại (người gửi lời mời)
        final String uid = repository.getUserId();
        
        // 2. Thêm người bảo vệ và lấy ID của bản ghi đó (ID người bảo vệ)
        final String guardianDocId = await repository.addGuardian(event.guardian);
        
        emit(const GuardianAddedSuccess("Đã lưu thông tin người bảo vệ!"));

        // 3. TẠO LINK: để tránh trường hợp một số app/ứng dụng tách query string,
        //    đưa `gid` vào path và thêm `uid` làm query parameter.
        final String inviteLink = Uri.https(
          'safetrek-2b5a0.web.app',
          '/invite/$guardianDocId',
          {'uid': uid},
        ).toString();
        
        // IN RA ĐỂ KIỂM TRA TRONG TAB RUN CỦA ANDROID STUDIO
        print("---------------------------------------");
        print("LINK MỜI: $inviteLink");
        print("---------------------------------------");

        final String inviteMessage = "Tôi muốn thêm bạn làm người bảo vệ trên SafeTrek. Nhấn vào link để xác nhận giúp tôi nhé: $inviteLink";

        emit(GuardianInviteReady(message: inviteMessage, phone: event.guardian.phone));
        
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
