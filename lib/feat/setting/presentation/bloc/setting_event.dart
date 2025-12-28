import 'package:equatable/equatable.dart';
import 'package:safetrek_project/feat/setting/domain/entity/user_profile.dart';

abstract class SettingEvent extends Equatable {
  const SettingEvent();

  @override
  List<Object> get props => [];
}

class LoadUserProfile extends SettingEvent {}

class UpdateUserProfile extends SettingEvent {
  final UserProfile userProfile;

  const UpdateUserProfile(this.userProfile);

  @override
  List<Object> get props => [userProfile];
}
