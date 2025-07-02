import 'package:flutter/cupertino.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:yalla_health/app/app.locator.dart';
import 'package:yalla_health/app/app.router.dart';
import 'package:yalla_health/core/utils/egyptian_phone_formatter.dart';
import 'package:yalla_health/core/validators/form_validators.dart';
import 'package:yalla_health/features/authentication/domain/usecases/register_usecase.dart';
import 'package:yalla_health/features/authentication/ui/views/register_view.form.dart';

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
  
  // Store raw user input separate from formatted display
  String _rawPhoneInput = '';

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

  String get formattedPhone => EgyptianPhoneFormatter.format(_rawPhoneInput);
  
  String get cleanPhone => EgyptianPhoneFormatter.clean(_rawPhoneInput);
  
  bool get hasValidPhone => EgyptianPhoneFormatter.isValid(_rawPhoneInput);
  
  bool get isFormValid => hasValidName && hasValidPhone && hasValidAge && hasValidGender && hasValidEmail;
  
  bool get hasValidName => nameController.text.trim().isNotEmpty;
  bool get hasValidAge => ageController.text.isNotEmpty && int.tryParse(ageController.text) != null;
  bool get hasValidGender => _selectedGender != null;
  bool get hasValidEmail => emailController.text.isEmpty || emailController.text.contains('@');
  
  bool get canRegister => isFormValid && !isBusy;

  void onPhoneChanged(String value) {
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