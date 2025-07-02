import 'package:flutter/cupertino.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:yalla_health/app/app.locator.dart';
import 'package:yalla_health/app/app.router.dart';
import 'package:yalla_health/core/constants/app_constants.dart';
import 'package:yalla_health/core/utils/egyptian_phone_formatter.dart';
import 'package:yalla_health/core/validators/form_validators.dart';
import 'package:yalla_health/features/authentication/domain/usecases/register_usecase.dart';
import 'package:yalla_health/features/authentication/ui/views/register_view.form.dart';

class RegisterViewModel extends FormViewModel with $RegisterView {
  final NavigationService _navigationService = locator<NavigationService>();
  final SnackbarService _snackbarService = locator<SnackbarService>();
  final RegisterUseCase _registerUseCase = locator<RegisterUseCase>();

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  String? _selectedGender;
  String? get selectedGender => _selectedGender;

  final List<String> genderOptions = ['male', 'female'];

  @override
  void dispose() {
    disposeForm();
    super.dispose();
  }

  String get formattedPhone => EgyptianPhoneFormatter.format(phoneController.text);
  
  String get cleanPhone => EgyptianPhoneFormatter.clean(phoneController.text);
  
  
  bool get isFormValid {
    return hasValidName && hasValidPhone && hasValidAge && hasValidGender && hasValidEmail;
  }
  
  bool get hasValidName => nameController.text.trim().isNotEmpty;
  bool get hasValidPhone => EgyptianPhoneFormatter.isValid(phoneController.text);
  bool get hasValidAge => ageController.text.isNotEmpty && int.tryParse(ageController.text) != null;
  bool get hasValidGender => _selectedGender != null;
  bool get hasValidEmail => emailController.text.isEmpty || emailController.text.contains('@');
  
  bool get canRegister => isFormValid && !isBusy;

  void onPhoneChanged(String value) {
    _clearError();

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

  void onNameChanged(String value) {
    _clearError();
    notifyListeners();
  }

  void onEmailChanged(String value) {
    _clearError();
    notifyListeners();
  }

  void onAgeChanged(String value) {
    _clearError();
    notifyListeners();
  }

  void setGender(String? gender) {
    _selectedGender = gender;
    _clearError();
    notifyListeners();
  }

  Future<void> register() async {
    if (!isFormValid) {
      _snackbarService.showSnackbar(
        message: 'Please fill all required fields correctly',
        title: 'Form Incomplete',
        duration: const Duration(seconds: AppConstants.snackbarErrorDuration),
      );
      return;
    }

    setBusy(true);
    _clearError();

    final params = RegisterParams(
      name: nameController.text.trim(),
      phone: cleanPhone,
      gender: _selectedGender!,
      age: int.parse(ageController.text),
      email: emailController.text.trim().isEmpty ? null : emailController.text.trim(),
    );

    final result = await _registerUseCase.call(params);

    result.fold(
      (failure) {
        _errorMessage = failure.message;
        _snackbarService.showSnackbar(
          message: failure.message,
          title: 'Registration Failed',
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
            isRegistration: true,
          ),
        );
      },
    );

    setBusy(false);
  }

  void navigateToLogin() {
    _navigationService.replaceWith(Routes.loginView);
  }

  void _clearError() {
    if (_errorMessage != null) {
      _errorMessage = null;
      notifyListeners();
    }
  }

  @override
  void setFormStatus() {
    // Use cleanPhone for phone validation like LoginViewModel
    setPhoneValidationMessage(FormValidators.validateEgyptianPhone(cleanPhone));
    setNameValidationMessage(FormValidators.validateName(nameController.text));
    setEmailValidationMessage(FormValidators.validateEmail(emailController.text));
    setAgeValidationMessage(FormValidators.validateAge(ageController.text));
    
    // Handle gender validation manually since it's not a text field
    final genderValidation = FormValidators.validateGender(_selectedGender);
    
    final hasErrors = hasNameValidationMessage || 
        hasPhoneValidationMessage || 
        hasEmailValidationMessage || 
        hasAgeValidationMessage || 
        genderValidation != null;

    setValidationMessage(hasErrors ? 'Please fix the errors above' : null);
  }
}