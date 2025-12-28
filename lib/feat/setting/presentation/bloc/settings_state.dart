import 'package:equatable/equatable.dart';
import 'package:safetrek_project/feat/setting/domain/entity/user_setting.dart';

abstract class SettingsState extends Equatable {
  const SettingsState();

  @override
  List<Object?> get props => [];
}

class SettingsInitial extends SettingsState {}

class SettingsLoading extends SettingsState {}

class SettingsLoaded extends SettingsState {
  final UserSetting userSetting;

  const SettingsLoaded(this.userSetting);

  @override
  List<Object?> get props => [userSetting];
}

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
