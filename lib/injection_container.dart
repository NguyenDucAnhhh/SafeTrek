import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';
import 'package:safetrek_project/feat/setting/data/datasource/setting_datasource.dart';
import 'package:safetrek_project/feat/setting/data/repository/setting_repository_impl.dart';
import 'package:safetrek_project/feat/setting/domain/repository/setting_repository.dart';
import 'package:safetrek_project/feat/setting/presentation/bloc/setting_bloc.dart';

final sl = GetIt.instance;

void init() {
  // Blocs
  sl.registerFactory(() => SettingBloc(settingRepository: sl()));

  // Repositories
  sl.registerLazySingleton<SettingRepository>(
      () => SettingRepositoryImpl(dataSource: sl()));

  // Data sources
  sl.registerLazySingleton<SettingDataSource>(
      () => SettingDataSourceImpl(firestore: sl(), auth: sl()));

  // External
  sl.registerLazySingleton(() => FirebaseAuth.instance);
  sl.registerLazySingleton(() => FirebaseFirestore.instance);
}
