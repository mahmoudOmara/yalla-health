import 'package:flutter/cupertino.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:yalla_health/app/app.locator.dart';
import 'package:yalla_health/app/app.router.dart';
import 'package:yalla_health/core/constants/app_constants.dart';
import 'package:yalla_health/core/utils/egyptian_phone_formatter.dart';
import 'package:yalla_health/core/validators/form_validators.dart';
import 'package:yalla_health/features/authentication/domain/usecases/login_usecase.dart';
import 'package:yalla_health/features/authentication/ui/views/login_view.form.dart';

class LoginViewModel extends FormViewModel with $LoginView {
  final NavigationService _navigationService = locator<NavigationService>();
  final SnackbarService _snackbarService = locator<SnackbarService>();
  final LoginUseCase _loginUseCase = locator<LoginUseCase>();

  String? _errorMessage;
  String? get errorMessage => _errorMessage;


  @override
  void dispose() {
    disposeForm();
    super.dispose();
  }

  String get cleanPhone => EgyptianPhoneFormatter.clean(phoneController.text);
  
  bool get hasValidPhone => EgyptianPhoneFormatter.isValid(phoneController.text);
  
  bool get canSendOtp => hasValidPhone && !isBusy;

  void onPhoneChanged(String value) {
    // Clear any previous errors when user starts typing
    _clearError();
    
    // Format for display
    final formatted = EgyptianPhoneFormatter.format(value);
    
    // Update controller with formatted text, avoiding loops
    if (formatted != phoneController.text) {
      phoneController.value = TextEditingValue(
        text: formatted,
        selection: TextSelection.collapsed(offset: formatted.length),
      );
    }
    
    notifyListeners();
  }

  Future<void> sendOtp() async {
    // Validate phone manually since we have custom validation
    final phoneValidation = FormValidators.validateEgyptianPhone(cleanPhone);
    if (phoneValidation != null) {
      // Set validation message on the form
      setValidationMessage(phoneValidation);
      notifyListeners();
      return;
    }

    setBusy(true);
    _clearError();

    final params = LoginParams(phone: cleanPhone);
    final result = await _loginUseCase.call(params);

    result.fold(
      (failure) {
        _errorMessage = failure.message;
        _snackbarService.showSnackbar(
          message: failure.message,
          title: 'Login Failed',
          duration: const Duration(seconds: AppConstants.snackbarErrorDuration),
        );
        notifyListeners();
      },
      (success) {
        _snackbarService.showSnackbar(
          message: 'OTP sent successfully',
          title: 'Success',
          duration: const Duration(seconds: AppConstants.snackbarSuccessDuration),
        );
        _navigationService.navigateTo(
          Routes.otpView,
          arguments: OtpViewArguments(
            phone: cleanPhone,
            isRegistration: false,
          ),
        );
      },
    );

    setBusy(false);
  }

  void navigateToRegister() {
    _navigationService.replaceWith(Routes.registerView);
  }

  void _clearError() {
    if (_errorMessage != null) {
      _errorMessage = null;
      notifyListeners();
    }
  }

  @override
  void setFormStatus() {
    final phoneValidation = FormValidators.validateEgyptianPhone(cleanPhone);
    setValidationMessage(phoneValidation);
  }
}