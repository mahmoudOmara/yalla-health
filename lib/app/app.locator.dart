// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// StackedLocatorGenerator
// **************************************************************************

// ignore_for_file: public_member_api_docs, implementation_imports, depend_on_referenced_packages

import 'package:stacked_services/src/bottom_sheet/bottom_sheet_service.dart';
import 'package:stacked_services/src/dialog/dialog_service.dart';
import 'package:stacked_services/src/navigation/navigation_service.dart';
import 'package:stacked_services/src/snackbar/snackbar_service.dart';
import 'package:stacked_shared/stacked_shared.dart';

import '../features/authentication/data/datasources/auth_remote_datasource.dart';
import '../features/authentication/data/repositories/auth_repository_impl.dart';
import '../features/authentication/domain/repositories/auth_repository.dart';
import '../features/authentication/domain/usecases/check_auth_status_usecase.dart';
import '../features/authentication/domain/usecases/get_shared_users_usecase.dart';
import '../features/authentication/domain/usecases/get_user_details_usecase.dart';
import '../features/authentication/domain/usecases/login_usecase.dart';
import '../features/authentication/domain/usecases/logout_usecase.dart';
import '../features/authentication/domain/usecases/register_usecase.dart';
import '../features/authentication/domain/usecases/verify_otp_usecase.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';
import '../services/user_service.dart';

final locator = StackedLocator.instance;

Future<void> setupLocator({
  String? environment,
  EnvironmentFilter? environmentFilter,
}) async {
// Register environments
  locator.registerEnvironment(
      environment: environment, environmentFilter: environmentFilter);

// Register dependencies
  locator.registerLazySingleton(() => NavigationService());
  locator.registerLazySingleton(() => DialogService());
  locator.registerLazySingleton(() => BottomSheetService());
  locator.registerLazySingleton(() => SnackbarService());
  locator.registerLazySingleton(() => ApiService());
  locator.registerLazySingleton(() => StorageService());
  locator.registerLazySingleton(() => UserService());
  locator.registerLazySingleton<IAuthRemoteDataSource>(
      () => AuthRemoteDataSource(apiService: locator<ApiService>()));
  locator.registerLazySingleton<IAuthRepository>(() => AuthRepository(
      remoteDataSource: locator<IAuthRemoteDataSource>(),
      storageService: locator<StorageService>(),
      userService: locator<UserService>()));
  locator.registerLazySingleton(() => LoginUseCase(locator<IAuthRepository>()));
  locator.registerLazySingleton(() => RegisterUseCase(locator<IAuthRepository>()));
  locator.registerLazySingleton(() => VerifyOtpUseCase(locator<IAuthRepository>()));
  locator.registerLazySingleton(() => GetUserDetailsUseCase(locator<IAuthRepository>()));
  locator.registerLazySingleton(() => GetSharedUsersUseCase(locator<IAuthRepository>()));
  locator.registerLazySingleton(() => LogoutUseCase(locator<IAuthRepository>()));
  locator.registerLazySingleton(() => CheckAuthStatusUseCase(locator<IAuthRepository>()));
}
