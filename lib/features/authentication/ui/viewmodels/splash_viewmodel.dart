import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:yalla_health/app/app.locator.dart';
import 'package:yalla_health/app/app.router.dart';
import 'package:yalla_health/core/utils/usecase.dart';
import 'package:yalla_health/features/authentication/domain/usecases/get_user_details_usecase.dart';
import 'package:yalla_health/features/authentication/domain/usecases/get_shared_users_usecase.dart';
import 'package:yalla_health/services/storage_service.dart';
import 'package:yalla_health/services/user_service.dart';

class SplashViewModel extends BaseViewModel {
  final NavigationService _navigationService = locator<NavigationService>();
  final StorageService _storageService = locator<StorageService>();
  final UserService _userService = locator<UserService>();
  final GetUserDetailsUseCase _getUserDetailsUseCase = locator<GetUserDetailsUseCase>();
  final GetSharedUsersUseCase _getSharedUsersUseCase = locator<GetSharedUsersUseCase>();

  Future<void> initialize() async {
    setBusy(true);
    
    // Initialize storage service
    await _storageService.init();
    
    // Check if user is logged in
    final isLoggedIn = await _storageService.isLoggedIn();
    
    if (isLoggedIn) {
      await _attemptAutoLogin();
    } else {
      await _navigateToLogin();
    }
    
    setBusy(false);
  }

  Future<void> _attemptAutoLogin() async {
    try {
      // Try to get user details to verify token is valid
      final userDetailsResult = await _getUserDetailsUseCase.call(NoParams());
      
      await userDetailsResult.fold(
        (failure) async {
          // Token is invalid, clear storage and go to login
          await _storageService.clearAll();
          await _navigateToLogin();
        },
        (user) async {
          // Token is valid, get shared users and navigate to home
          final sharedUsersResult = await _getSharedUsersUseCase.call(NoParams());
          
          sharedUsersResult.fold(
            (failure) {
              // Continue without shared users
              final serviceUser = User(
                id: user.id,
                name: user.name,
                phone: user.phone,
                email: user.email ?? '',
                gender: user.gender,
                age: user.age,
                createdAt: user.createdAt,
                updatedAt: user.updatedAt,
              );
              
              _userService.setCurrentUser(serviceUser);
              _navigateToHome();
            },
            (sharedUsers) {
              // Set user and shared users in service
              final serviceUser = User(
                id: user.id,
                name: user.name,
                phone: user.phone,
                email: user.email ?? '',
                gender: user.gender,
                age: user.age,
                createdAt: user.createdAt,
                updatedAt: user.updatedAt,
              );
              
              final serviceSharedUsers = sharedUsers.map((userEntity) => User(
                id: userEntity.id,
                name: userEntity.name,
                phone: userEntity.phone,
                email: userEntity.email ?? '',
                gender: userEntity.gender,
                age: userEntity.age,
                createdAt: userEntity.createdAt,
                updatedAt: userEntity.updatedAt,
              )).toList();
              
              _userService.setCurrentUser(serviceUser);
              _userService.setSharedUsers(serviceSharedUsers);
              _navigateToHome();
            },
          );
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
    _navigationService.clearStackAndShow(Routes.homeView);
  }
}