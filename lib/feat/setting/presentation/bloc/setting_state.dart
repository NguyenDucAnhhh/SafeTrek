import 'package:equatable/equatable.dart';
import 'package:safetrek_project/feat/setting/domain/entity/user_profile.dart';

abstract class SettingState extends Equatable {
  const SettingState();

  @override
  List<Object> get props => [];
}

class SettingInitial extends SettingState {}

class SettingLoading extends SettingState {}

class SettingLoaded extends SettingState {
  final UserProfile userProfile;

  const SettingLoaded(this.userProfile);

  @override
  List<Object> get props => [userProfile];
}

class SettingFailure extends SettingState {
  final String message;

  const SettingFailure(this.message);

  @override
  List<Object> get props => [message];
}
