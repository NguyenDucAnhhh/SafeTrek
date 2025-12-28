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

  const UpdateProfileEvent(this.name, this.phone);

  @override
  List<Object?> get props => [name, phone];
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
