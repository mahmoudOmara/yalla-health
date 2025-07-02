import 'package:flutter/cupertino.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:yalla_health/app/app.locator.dart';
import 'package:yalla_health/app/app.router.dart';
import 'package:yalla_health/core/utils/egyptian_phone_formatter.dart';
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
  
  // Store raw user input separate from formatted display
  String _rawPhoneInput = '';

  @override
  void dispose() {
    phoneController.dispose();
    phoneFocusNode.dispose();
    super.dispose();
  }

  String get formattedPhone => EgyptianPhoneFormatter.format(_rawPhoneInput);
  
  String get cleanPhone => EgyptianPhoneFormatter.clean(_rawPhoneInput);
  
  bool get hasValidPhone => EgyptianPhoneFormatter.isValid(_rawPhoneInput);
  
  bool get canSendOtp => hasValidPhone && !isBusy;

  void onPhoneChanged(String value) {
    // Clear any previous errors when user starts typing
    _clearError();
    
    // Store only digits from user input
    _rawPhoneInput = EgyptianPhoneFormatter.extractDigits(value);
    
    // Format for display
    final formatted = formattedPhone;
    
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