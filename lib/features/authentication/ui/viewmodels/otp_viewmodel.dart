import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:yalla_health/app/app.locator.dart';
import 'package:yalla_health/app/app.router.dart';
import 'package:yalla_health/core/constants/app_constants.dart';
import 'package:yalla_health/core/utils/usecase.dart';
import 'package:yalla_health/core/validators/form_validators.dart';
import 'package:yalla_health/features/authentication/domain/usecases/get_shared_users_usecase.dart';
import 'package:yalla_health/features/authentication/domain/usecases/get_user_details_usecase.dart';
import 'package:yalla_health/features/authentication/domain/usecases/login_usecase.dart';
import 'package:yalla_health/features/authentication/domain/usecases/register_usecase.dart';
import 'package:yalla_health/features/authentication/domain/usecases/verify_otp_usecase.dart';
import 'package:yalla_health/features/authentication/ui/views/login_view.form.dart';
import 'package:yalla_health/services/storage_service.dart';
import 'package:yalla_health/services/user_service.dart';

class OtpViewModel extends FormViewModel {
  final NavigationService _navigationService = locator<NavigationService>();
  final SnackbarService _snackbarService = locator<SnackbarService>();
  final VerifyOtpUseCase _verifyOtpUseCase = locator<VerifyOtpUseCase>();
  final LoginUseCase _loginUseCase = locator<LoginUseCase>();
  final RegisterUseCase _registerUseCase = locator<RegisterUseCase>();
  final GetUserDetailsUseCase _getUserDetailsUseCase = locator<GetUserDetailsUseCase>();
  final GetSharedUsersUseCase _getSharedUsersUseCase = locator<GetSharedUsersUseCase>();
  final StorageService _storageService = locator<StorageService>();
  final UserService _userService = locator<UserService>();

  final String phone;
  final bool isRegistration;

  OtpViewModel({
    required this.phone,
    required this.isRegistration,
  });

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  int _remainingTime = AppConstants.otpTimeoutSeconds;
  int get remainingTime => _remainingTime;

  bool _canResend = false;
  bool get canResend => _canResend;

  Timer? _timer;

  final TextEditingController otpController = TextEditingController();
  final FocusNode otpFocusNode = FocusNode();

  @override
  void dispose() {
    _timer?.cancel();
    otpController.dispose();
    otpFocusNode.dispose();
    super.dispose();
  }

  void initialize() {
    _startTimer();
    // Auto-focus on OTP field
    Future.delayed(const Duration(milliseconds: 100), () {
      otpFocusNode.requestFocus();
    });
  }

  void _startTimer() {
    _remainingTime = AppConstants.otpTimeoutSeconds;
    _canResend = false;
    _timer?.cancel();
    
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingTime > 0) {
        _remainingTime--;
        notifyListeners();
      } else {
        _canResend = true;
        timer.cancel();
        notifyListeners();
      }
    });
  }

  String get formattedTime {
    final minutes = _remainingTime ~/ 60;
    final seconds = _remainingTime % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  String get maskedPhone {
    if (phone.length >= 10) {
      final countryCode = phone.substring(0, 3); // +20
      final prefix = phone.substring(3, 5);
      final suffix = phone.substring(phone.length - 4);
      return '$countryCode $prefix*** $suffix';
    }
    return phone;
  }

  void onOtpChanged(String value) {
    _clearError();
    
    // Auto-verify when 6 digits are entered
    if (value.length == AppConstants.otpLength) {
      verifyOtp();
    }
    
    notifyListeners();
  }

  Future<void> verifyOtp() async {
    if (!isFormValid) return;

    setBusy(true);
    _clearError();

    final params = VerifyOtpParams(
      phone: phone,
      otpCode: otpController.text,
    );

    final result = await _verifyOtpUseCase.call(params);

    await result.fold(
      (failure) async {
        _errorMessage = failure.message;
        _snackbarService.showSnackbar(
          message: failure.message,
          title: 'Verification Failed',
        );
        otpController.clear();
        notifyListeners();
      },
      (token) async {
        // Store the token
        await _storageService.saveToken(token);
        
        // Get user details and shared users
        await _loadUserData();
        
        _snackbarService.showSnackbar(
          message: isRegistration ? 'Account created successfully!' : 'Login successful!',
          title: 'Success',
        );
        
        _navigationService.clearStackAndShow(Routes.homeView);
      },
    );

    setBusy(false);
  }

  Future<void> _loadUserData() async {
    try {
      // Get user details
      final userDetailsResult = await _getUserDetailsUseCase.call(NoParams());
      
      await userDetailsResult.fold(
        (failure) async {
          // Handle error silently, user can try again later
        },
        (user) async {
          // Get shared users
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
            },
          );
        },
      );
    } catch (e) {
      // Handle error silently
    }
  }

  Future<void> resendOtp() async {
    if (!_canResend || isBusy) return;

    setBusy(true);
    _clearError();

    if (isRegistration) {
      // For registration, we would need to store the registration data
      // For now, just show error asking user to go back and register again
      _errorMessage = 'Please go back and register again to resend OTP';
      notifyListeners();
    } else {
      // For login, resend OTP
      final params = LoginParams(phone: phone);
      final result = await _loginUseCase.call(params);

      result.fold(
        (failure) {
          _errorMessage = failure.message;
          notifyListeners();
        },
        (success) {
          _snackbarService.showSnackbar(
            message: 'OTP sent successfully',
            title: 'Success',
          );
          _startTimer();
          otpController.clear();
        },
      );
    }

    setBusy(false);
  }

  void navigateBack() {
    _navigationService.back();
  }

  void _clearError() {
    if (_errorMessage != null) {
      _errorMessage = null;
      notifyListeners();
    }
  }

  @override
  void setFormStatus() {
    final otpValidation = FormValidators.validateOtp(otpController.text);
    setValidationMessage(otpValidation);
  }
}