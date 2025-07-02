import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:yalla_health/app/app.locator.dart';
import 'package:yalla_health/app/app.router.dart';
import 'package:yalla_health/core/utils/usecase.dart';
import 'package:yalla_health/features/authentication/domain/usecases/check_auth_status_usecase.dart';
import 'package:yalla_health/services/storage_service.dart';

class SplashViewModel extends BaseViewModel {
  final NavigationService _navigationService = locator<NavigationService>();
  final StorageService _storageService = locator<StorageService>();
  final CheckAuthStatusUseCase _checkAuthStatusUseCase = locator<CheckAuthStatusUseCase>();

  Future<void> initialize() async {
    setBusy(true);
    
    // Initialize storage service
    await _storageService.init();
    
    // Check authentication status and auto-login
    await _attemptAutoLogin();
    
    setBusy(false);
  }

  Future<void> _attemptAutoLogin() async {
    try {
      // Use the checkAuthStatus use case which handles token validation and user data loading
      final authStatusResult = await _checkAuthStatusUseCase.call(NoParams());
      
      authStatusResult.fold(
        (failure) async {
          // Authentication failed, clear storage and go to login
          await _storageService.clearAll();
          await _navigateToLogin();
        },
        (isAuthenticated) async {
          if (isAuthenticated) {
            // User is authenticated and data is loaded in UserService by repository
            await _navigateToHome();
          } else {
            // User is not authenticated
            await _navigateToLogin();
          }
        },
      );
    } catch (e) {
      // Error occurred, clear storage and go to login
      await _storageService.clearAll();
      await _navigateToLogin();
    }
  }

  Future<void> _navigateToLogin() async {
    await Future.delayed(const Duration(seconds: 2)); // Show splash for 2 seconds
    _navigationService.clearStackAndShow(Routes.loginView);
  }

  Future<void> _navigateToHome() async {
    await Future.delayed(const Duration(seconds: 2)); // Show splash for 2 seconds
    _navigationService.clearStackAndShow(Routes.mainNavigationView);
  }
}