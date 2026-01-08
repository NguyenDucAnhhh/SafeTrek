import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'guardian_event.dart';
import 'guardian_state.dart';
import 'package:safetrek_project/feat/guardians/domain/repository/guardian_repository.dart';

class GuardianBloc extends Bloc<GuardianEvent, GuardianState> {
  final GuardianRepository repository;
  StreamSubscription? _guardiansSubscription;

  GuardianBloc(this.repository) : super(GuardianInitial()) {
    on<LoadGuardiansEvent>((event, emit) {
      emit(GuardianLoading());
      _guardiansSubscription?.cancel();
      try {
        _guardiansSubscription = repository.getGuardiansStream().listen(
          (guardians) {
            add(GuardiansUpdatedEvent(guardians));
          },
          onError: (error) {
            emit(GuardianError("Không thể tải danh sách: ${error.toString()}"));
          },
        );
      } catch (e) {
        emit(GuardianError("Không thể tải danh sách: ${e.toString()}"));
      }
    });

    on<GuardiansUpdatedEvent>((event, emit) {
      emit(GuardianLoaded(event.guardians));
    });

    on<AddGuardianEvent>((event, emit) async {
      try {
        final String uid = repository.getUserId();
        final String guardianDocId = await repository.addGuardian(event.guardian);

        emit(const GuardianAddedSuccess("Đã lưu thông tin người bảo vệ!"));

        final String inviteLink = Uri.https(
          'safetrek-2b5a0.web.app',
          '/invite/$guardianDocId',
          {'uid': uid},
        ).toString();

        print("---------------------------------------");
        print("LINK MỜI: $inviteLink");
        print("---------------------------------------");

        final String inviteMessage = "Tôi muốn thêm bạn làm người bảo vệ trên SafeTrek. Nhấn vào link để xác nhận giúp tôi nhé: $inviteLink";

        emit(GuardianInviteReady(message: inviteMessage, phone: event.guardian.phone));
      } catch (e) {
        emit(GuardianError("Lỗi khi thêm: ${e.toString()}"));
      }
    });

    on<RemoveGuardianEvent>((event, emit) async {
      try {
        await repository.deleteGuardian(event.docId);
      } catch (e) {
        emit(GuardianError("Lỗi khi xóa: $e"));
      }
    });
  }

  @override
  Future<void> close() {
    _guardiansSubscription?.cancel();
    return super.close();
  }
}
