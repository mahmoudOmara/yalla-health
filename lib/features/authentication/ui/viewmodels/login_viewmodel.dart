import 'package:flutter/cupertino.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:yalla_health/app/app.locator.dart';
import 'package:yalla_health/app/app.router.dart';
import 'package:yalla_health/core/validators/form_validators.dart';
import 'package:yalla_health/features/authentication/domain/usecases/login_usecase.dart';

class LoginViewModel extends FormViewModel {
  final NavigationService _navigationService = locator<NavigationService>();
  final SnackbarService _snackbarService = locator<SnackbarService>();
  final LoginUseCase _loginUseCase = locator<LoginUseCase>();

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  final TextEditingController phoneController = TextEditingController();
  final FocusNode phoneFocusNode = FocusNode();

  @override
  void dispose() {
    phoneController.dispose();
    phoneFocusNode.dispose();
    super.dispose();
  }

  String get formattedPhone {
    final text = phoneController.text;
    // Remove any existing formatting
    final digits = text.replaceAll(RegExp(r'[^\d]'), '');
    
    if (digits.isEmpty) return '+20 ';
    if (digits.length <= 2) return '+20 $digits';
    if (digits.length <= 5) return '+20 ${digits.substring(0, 2)} ${digits.substring(2)}';
    if (digits.length <= 8) return '+20 ${digits.substring(0, 2)} ${digits.substring(2, 5)} ${digits.substring(5)}';
    return '+20 ${digits.substring(0, 2)} ${digits.substring(2, 5)} ${digits.substring(5, 9)}';
  }

  String get cleanPhone {
    final text = phoneController.text;
    final digits = text.replaceAll(RegExp(r'[^\d]'), '');
    if (digits.length >= 10) {
      return '+20${digits.substring(0, 10)}';
    }
    return '+20$digits';
  }

  void onPhoneChanged(String value) {
    // Clear any previous errors when user starts typing
    _clearError();
    
    // Update the controller with formatted text
    final formatted = formattedPhone;
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
        );
        notifyListeners();
      },
      (success) {
        _snackbarService.showSnackbar(
          message: 'OTP sent successfully',
          title: 'Success',
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
    _navigationService.navigateTo(Routes.registerView);
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