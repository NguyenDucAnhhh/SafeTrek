import 'package:bloc/bloc.dart';
import 'package:safetrek_project/feat/setting/domain/repository/settings_repository.dart';
import 'settings_event.dart';
import 'settings_state.dart';

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  final SettingsRepository repository;

  SettingsBloc(this.repository) : super(SettingsInitial()) {
    on<LoadUserSettingsEvent>(_loadUserSettings);
    on<UpdateProfileEvent>(_updateProfile);
    on<ChangeSafePinEvent>(_changeSafePin);
    on<ChangeDuressPinEvent>(_changeDuressPin);
    on<ChangePasswordEvent>(_changePassword);
    on<LoadHiddenPanicEvent>((event, emit) async {
      final enabled = await repository.getHiddenPanic();
      emit(HiddenPanicLoaded(enabled));
    });

    on<ToggleHiddenPanicEvent>((event, emit) async {
      await repository.setHiddenPanic(event.enabled);
      emit(HiddenPanicLoaded(event.enabled));
    });

  }

  Future<void> _loadUserSettings(
      LoadUserSettingsEvent event, Emitter<SettingsState> emit) async {
    emit(SettingsLoading());
    try {
      final userSetting = await repository.getUserSettings();
      emit(SettingsLoaded(userSetting: userSetting));
    } catch (e) {
      emit(SettingsError("Không thể tải dữ liệu: ${e.toString()}"));
    }
  }

  Future<void> _updateProfile(UpdateProfileEvent e, Emitter<SettingsState> emit) async {
    try {
      // 1. Cập nhật lên Firebase
      await repository.updateProfile(e.name, e.phone, e.email);

      // 2. Lấy dữ liệu mới nhất ngay lập tức
      final updatedUser = await repository.getUserSettings();

      // 3. Phát ra trạng thái thành công kèm dữ liệu mới
      // Giả sử bạn muốn hiện thông báo, hãy emit Success trước rồi Loaded sau,
      // hoặc chỉ cần emit Loaded là đủ để UI update tên mới.
      emit(SettingsLoaded(userSetting: updatedUser));

      print("Cập nhật hồ sơ thành công!");
    } catch (e) {
      emit(SettingsError("Lỗi khi cập nhật hồ sơ: $e"));
    }
  }


  Future<void> _changeSafePin(ChangeSafePinEvent e, Emitter<SettingsState> emit) async {
    try {
      await repository.changeSafePin(e.pin);
      emit(const SettingsSuccess('Đổi mã PIN an toàn thành công'));
      add(LoadUserSettingsEvent());
    } catch (e) {
      emit(SettingsError("Lỗi khi đổi mã PIN: $e"));
    }
  }

  Future<void> _changeDuressPin(ChangeDuressPinEvent e, Emitter<SettingsState> emit) async {
    try {
      await repository.changeDuressPin(e.pin);
      emit(const SettingsSuccess('Đổi mã PIN bị ép buộc thành công'));
      add(LoadUserSettingsEvent());
    } catch (e) {
      emit(SettingsError("Lỗi khi đổi mã PIN: $e"));
    }
  }

  Future<void> _changePassword(ChangePasswordEvent e, Emitter<SettingsState> emit) async {
    try {
      await repository.changePassword(
        e.oldPassword,
        e.newPassword,
      );
      emit(const SettingsSuccess('Đổi mật khẩu thành công'));
    } catch (e) {
      emit(SettingsError("Lỗi khi đổi mật khẩu: $e"));
    }
  }
}
