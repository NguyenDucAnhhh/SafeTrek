import 'package:equatable/equatable.dart';

abstract class SettingsEvent extends Equatable {
  const SettingsEvent();

  @override
  List<Object?> get props => [];
}

// Events for User Profile
class LoadUserSettingsEvent extends SettingsEvent {}

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

// Events for PINs
class ChangeSafePinEvent extends SettingsEvent {
  final String pin;
  const ChangeSafePinEvent(this.pin);
}

class ChangeDuressPinEvent extends SettingsEvent {
  final String pin;
  const ChangeDuressPinEvent(this.pin);
}

// Event for Password
class ChangePasswordEvent extends SettingsEvent {
  final String oldPassword;
  final String newPassword;
  const ChangePasswordEvent(this.oldPassword, this.newPassword);
}

// Events for Hidden Panic
class LoadHiddenPanicSettingsEvent extends SettingsEvent {}

class SaveHiddenPanicSettingsEvent extends SettingsEvent {
  final bool isEnabled;
  final String method;
  final int pressCount;

  const SaveHiddenPanicSettingsEvent({
    required this.isEnabled,
    required this.method,
    required this.pressCount,
  });

  @override
  List<Object?> get props => [isEnabled, method, pressCount];
}
