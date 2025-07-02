import 'package:stacked/stacked_annotations.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:yalla_health/services/api_service.dart';
import 'package:yalla_health/services/storage_service.dart';
import 'package:yalla_health/services/user_service.dart';

// Authentication imports
import 'package:yalla_health/features/authentication/domain/repositories/auth_repository.dart';
import 'package:yalla_health/features/authentication/data/repositories/auth_repository_impl.dart';
import 'package:yalla_health/features/authentication/data/datasources/auth_remote_datasource.dart';
import 'package:yalla_health/features/authentication/domain/usecases/login_usecase.dart';
import 'package:yalla_health/features/authentication/domain/usecases/register_usecase.dart';
import 'package:yalla_health/features/authentication/domain/usecases/verify_otp_usecase.dart';
import 'package:yalla_health/features/authentication/domain/usecases/get_user_details_usecase.dart';
import 'package:yalla_health/features/authentication/domain/usecases/get_shared_users_usecase.dart';
import 'package:yalla_health/features/authentication/domain/usecases/logout_usecase.dart';
import 'package:yalla_health/features/authentication/domain/usecases/check_auth_status_usecase.dart';

// UI imports
import 'package:yalla_health/features/authentication/ui/views/splash_view.dart';
import 'package:yalla_health/features/authentication/ui/views/login_view.dart';
import 'package:yalla_health/features/authentication/ui/views/register_view.dart';
import 'package:yalla_health/features/authentication/ui/views/otp_view.dart';
import 'package:yalla_health/features/home/ui/views/home_view.dart';
import 'package:yalla_health/features/main_navigation/ui/views/main_navigation_view.dart';

@StackedApp(
  routes: [
    // Authentication Routes
    MaterialRoute(page: SplashView, initial: true),
    MaterialRoute(page: LoginView),
    MaterialRoute(page: RegisterView),
    MaterialRoute(page: OtpView),
    
    // Main App Routes
    MaterialRoute(page: HomeView),
    MaterialRoute(page: MainNavigationView),
    // TODO: Add remaining app routes when features are implemented
  ],
  dependencies: [
    // Core Services
    LazySingleton(classType: NavigationService),
    LazySingleton(classType: DialogService),
    LazySingleton(classType: BottomSheetService),
    LazySingleton(classType: SnackbarService),
    
    // App Services
    LazySingleton(classType: ApiService),
    LazySingleton(classType: StorageService),
    LazySingleton(classType: UserService),
    
    // Authentication Data Sources
    LazySingleton(classType: AuthRemoteDataSource, asType: IAuthRemoteDataSource),
    
    // Authentication Repository
    LazySingleton(classType: AuthRepository, asType: IAuthRepository),
    
    // Authentication Use Cases
    LazySingleton(classType: LoginUseCase),
    LazySingleton(classType: RegisterUseCase),
    LazySingleton(classType: VerifyOtpUseCase),
    LazySingleton(classType: GetUserDetailsUseCase),
    LazySingleton(classType: GetSharedUsersUseCase),
    LazySingleton(classType: LogoutUseCase),
    LazySingleton(classType: CheckAuthStatusUseCase),
    
    // TODO: Add additional dependencies when features are implemented
  ],
)
class App {}

// TODO: Add classes for features when implemented