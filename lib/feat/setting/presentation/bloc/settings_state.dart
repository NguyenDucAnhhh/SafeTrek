import 'package:equatable/equatable.dart';
import 'package:safetrek_project/feat/setting/domain/entity/user_setting.dart';

abstract class SettingsState extends Equatable {
  const SettingsState();

  @override
  List<Object?> get props => [];
}

// Initial and Loading States
class SettingsInitial extends SettingsState {}
class SettingsLoading extends SettingsState {}

// User Profile States
class SettingsLoaded extends SettingsState {
  final UserSetting userSetting;
  const SettingsLoaded({required this.userSetting});
  @override
  List<Object?> get props => [userSetting];
}

// Hidden Panic States
class HiddenPanicSettingsLoaded extends SettingsState {
  final bool isEnabled;
  final String method;
  final int pressCount;

  const HiddenPanicSettingsLoaded({
    required this.isEnabled,
    required this.method,
    required this.pressCount,
  });

  @override
  List<Object?> get props => [isEnabled, method, pressCount];
}


// General Success and Error States
class SettingsSuccess extends SettingsState {
  final String message;
  const SettingsSuccess(this.message);
  @override
  List<Object?> get props => [message];
}

class SettingsError extends SettingsState {
  final String message;
  const SettingsError(this.message);
  @override
  List<Object?> get props => [message];
}
