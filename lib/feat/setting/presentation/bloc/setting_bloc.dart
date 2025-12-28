import 'package:bloc/bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:safetrek_project/feat/setting/domain/repository/setting_repository.dart';
import 'setting_event.dart';
import 'setting_state.dart';

final sl = GetIt.instance;

class SettingBloc extends Bloc<SettingEvent, SettingState> {
  final SettingRepository settingRepository;

  SettingBloc({required this.settingRepository}) : super(SettingInitial()) {
    on<LoadUserProfile>((event, emit) async {
      emit(SettingLoading());
      final failureOrUserProfile = await settingRepository.getUserProfile();
      failureOrUserProfile.fold(
        (failure) => emit(const SettingFailure('Không thể tải thông tin người dùng')),
        (userProfile) => emit(SettingLoaded(userProfile)),
      );
    });

    on<UpdateUserProfile>((event, emit) async {
      final failureOrVoid = await settingRepository.updateUserProfile(event.userProfile);
      failureOrVoid.fold(
        (failure) => emit(const SettingFailure('Không thể cập nhật thông tin')),
        (_) => emit(SettingLoaded(event.userProfile)),
      );
    });
  }
}
