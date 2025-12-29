import 'package:equatable/equatable.dart';

abstract class SettingsEvent extends Equatable {
  const SettingsEvent();

  @override
  List<Object?> get props => [];
}

// ================= LOAD =================
class LoadUserSettingsEvent extends SettingsEvent {}

// ================= UPDATE PROFILE =================
class UpdateProfileEvent extends SettingsEvent {
  final String name;
  final String phone;
  final String email;

  // Sửa từ (this.name, this.phone, this.email) thành dạng đặt tên dưới đây:
  const UpdateProfileEvent({
    required this.name,
    required this.phone,
    required this.email,
  });

  @override
  List<Object?> get props => [name, phone, email];
}

// ================= SAFE PIN =================
class ChangeSafePinEvent extends SettingsEvent {
  final String pin;

  const ChangeSafePinEvent(this.pin);

  @override
  List<Object?> get props => [pin];
}

// ================= DURESS PIN =================
class ChangeDuressPinEvent extends SettingsEvent {
  final String pin;

  const ChangeDuressPinEvent(this.pin);

  @override
  List<Object?> get props => [pin];
}

// ================= PASSWORD =================
class ChangePasswordEvent extends SettingsEvent {
  final String oldPassword;
  final String newPassword;

  const ChangePasswordEvent(this.oldPassword, this.newPassword);

  @override
  List<Object?> get props => [oldPassword, newPassword];

}

class LoadHiddenPanicEvent extends SettingsEvent {}

class ToggleHiddenPanicEvent extends SettingsEvent {
  final bool enabled;
  ToggleHiddenPanicEvent(this.enabled);

  @override
  List<Object> get props => [enabled];
}