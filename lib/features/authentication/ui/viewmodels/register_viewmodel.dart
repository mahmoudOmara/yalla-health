import 'package:flutter/cupertino.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:yalla_health/app/app.locator.dart';
import 'package:yalla_health/app/app.router.dart';
import 'package:yalla_health/core/validators/form_validators.dart';
import 'package:yalla_health/features/authentication/domain/usecases/register_usecase.dart';
import 'package:yalla_health/features/authentication/ui/views/login_view.form.dart';

class RegisterViewModel extends FormViewModel {
  final NavigationService _navigationService = locator<NavigationService>();
  final SnackbarService _snackbarService = locator<SnackbarService>();
  final RegisterUseCase _registerUseCase = locator<RegisterUseCase>();

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  String? _selectedGender;
  String? get selectedGender => _selectedGender;

  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController ageController = TextEditingController();

  final FocusNode nameFocusNode = FocusNode();
  final FocusNode phoneFocusNode = FocusNode();
  final FocusNode emailFocusNode = FocusNode();
  final FocusNode ageFocusNode = FocusNode();

  final List<String> genderOptions = ['male', 'female'];

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    emailController.dispose();
    ageController.dispose();
    nameFocusNode.dispose();
    phoneFocusNode.dispose();
    emailFocusNode.dispose();
    ageFocusNode.dispose();
    super.dispose();
  }

  String get formattedPhone {
    final text = phoneController.text;
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
    _clearError();
    
    final formatted = formattedPhone;
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
    if (!isFormValid) return;

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
            isRegistration: true,
          ),
        );
      },
    );

    setBusy(false);
  }

  void navigateToLogin() {
    _navigationService.navigateTo(Routes.loginView);
  }

  void _clearError() {
    if (_errorMessage != null) {
      _errorMessage = null;
      notifyListeners();
    }
  }

  @override
  void setFormStatus() {
    final nameValidation = FormValidators.validateName(nameController.text);
    final phoneValidation = FormValidators.validateEgyptianPhone(cleanPhone);
    final emailValidation = FormValidators.validateEmail(emailController.text);
    final ageValidation = FormValidators.validateAge(ageController.text);
    final genderValidation = FormValidators.validateGender(_selectedGender);

    final hasErrors = nameValidation != null ||
        phoneValidation != null ||
        emailValidation != null ||
        ageValidation != null ||
        genderValidation != null;

    setValidationMessage(hasErrors ? 'Please fix the errors above' : null);
  }

  String? getNameError() => FormValidators.validateName(nameController.text);
  String? getPhoneError() => FormValidators.validateEgyptianPhone(cleanPhone);
  String? getEmailError() => FormValidators.validateEmail(emailController.text);
  String? getAgeError() => FormValidators.validateAge(ageController.text);
  String? getGenderError() => FormValidators.validateGender(_selectedGender);
}