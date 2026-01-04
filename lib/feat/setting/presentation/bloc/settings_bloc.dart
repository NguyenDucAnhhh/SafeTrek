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
    on<LoadHiddenPanicSettingsEvent>(_loadHiddenPanicSettings);
    on<SaveHiddenPanicSettingsEvent>(_saveHiddenPanicSettings);
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
      await repository.updateProfile(e.name, e.phone, e.email);
      emit(const SettingsSuccess('Cập nhật hồ sơ thành công'));
      add(LoadUserSettingsEvent());
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
      await repository.changePassword(e.oldPassword, e.newPassword);
      emit(const SettingsSuccess('Đổi mật khẩu thành công'));
    } catch (e) {
      emit(SettingsError("Lỗi khi đổi mật khẩu: $e"));
    }
  }

  Future<void> _loadHiddenPanicSettings(
      LoadHiddenPanicSettingsEvent event, Emitter<SettingsState> emit) async {
    try {
      final settings = await repository.loadHiddenPanicSettings();
      emit(HiddenPanicSettingsLoaded(
        isEnabled: settings['isEnabled'] ?? false,
        method: settings['method'] ?? 'volume',
        pressCount: settings['pressCount'] ?? 5,
      ));
    } catch (e) {
      emit(SettingsError("Không thể tải cài đặt nút hoảng loạn: $e"));
    }
  }

  Future<void> _saveHiddenPanicSettings(
      SaveHiddenPanicSettingsEvent event, Emitter<SettingsState> emit) async {
    try {
      await repository.saveHiddenPanicSettings(
          event.isEnabled, event.method, event.pressCount);
      emit(const SettingsSuccess('Đã lưu cài đặt nút hoảng loạn'));
      add(LoadHiddenPanicSettingsEvent()); // Tải lại để cập nhật UI
    } catch (e) {
      emit(SettingsError("Lỗi khi lưu cài đặt: $e"));
    }
  }
}
