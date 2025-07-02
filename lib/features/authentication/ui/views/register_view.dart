import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked/stacked_annotations.dart';
import 'package:yalla_health/core/theme/app_theme.dart';
import 'package:yalla_health/core/widgets/error_message_widget.dart';
import 'package:yalla_health/features/authentication/ui/viewmodels/register_viewmodel.dart';
import 'register_view.form.dart';

@FormView(fields: [
  FormTextField(name: 'name'),
  FormTextField(name: 'phone'),
  FormTextField(name: 'email'),
  FormTextField(name: 'age'),
])
class RegisterView extends StackedView<RegisterViewModel> with $RegisterView {
  const RegisterView({Key? key}) : super(key: key);

  @override
  Widget builder(
    BuildContext context,
    RegisterViewModel viewModel,
    Widget? child,
  ) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundPrimary,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),
              
              // Back button
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(
                    Icons.arrow_back_ios,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Title
              const Text(
                'Create Account',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
              
              const SizedBox(height: 8),
              
              const Text(
                'Fill in your details to get started',
                style: TextStyle(
                  fontSize: 16,
                  color: AppTheme.textSecondary,
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Name Field
              _buildInputField(
                label: 'Full Name',
                controller: nameController,
                focusNode: nameFocusNode,
                keyboardType: TextInputType.name,
                textInputAction: TextInputAction.next,
                onChanged: viewModel.onNameChanged,
                errorText: viewModel.getNameError(),
                hintText: 'Enter your full name',
              ),
              
              const SizedBox(height: 24),
              
              // Phone Field
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Phone Number',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  
                  TextFormField(
                    controller: phoneController,
                    focusNode: phoneFocusNode,
                    keyboardType: TextInputType.phone,
                    textInputAction: TextInputAction.next,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(10),
                    ],
                    onChanged: viewModel.onPhoneChanged,
                    decoration: InputDecoration(
                      hintText: '+20 101 234 5678',
                      prefixIcon: Container(
                        width: 60,
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 24,
                              height: 16,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(2),
                              ),
                              child: Column(
                                children: [
                                  Expanded(child: Container(color: Colors.red)),
                                  Expanded(child: Container(color: Colors.white)),
                                  Expanded(child: Container(color: Colors.black)),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              '+20',
                              style: TextStyle(
                                fontSize: 16,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      errorText: viewModel.getPhoneError(),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 24),
              
              // Email Field (Optional)
              _buildInputField(
                label: 'Email (Optional)',
                controller: emailController,
                focusNode: emailFocusNode,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                onChanged: viewModel.onEmailChanged,
                errorText: viewModel.getEmailError(),
                hintText: 'Enter your email address',
              ),
              
              const SizedBox(height: 24),
              
              // Age Field
              _buildInputField(
                label: 'Age',
                controller: ageController,
                focusNode: ageFocusNode,
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.done,
                onChanged: viewModel.onAgeChanged,
                errorText: viewModel.getAgeError(),
                hintText: 'Enter your age',
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(3),
                ],
              ),
              
              const SizedBox(height: 24),
              
              // Gender Selection
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Gender',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  
                  Row(
                    children: viewModel.genderOptions.map((gender) {
                      final isSelected = viewModel.selectedGender == gender;
                      return Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(
                            right: gender == viewModel.genderOptions.last ? 0 : 12,
                          ),
                          child: GestureDetector(
                            onTap: () => viewModel.setGender(gender),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: isSelected 
                                      ? AppTheme.primaryColor 
                                      : AppTheme.borderColor,
                                  width: isSelected ? 2 : 1,
                                ),
                                borderRadius: BorderRadius.circular(8),
                                color: isSelected 
                                    ? AppTheme.primaryColor.withOpacity(0.05)
                                    : AppTheme.backgroundPrimary,
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    gender == 'male' ? Icons.male : Icons.female,
                                    color: isSelected 
                                        ? AppTheme.primaryColor 
                                        : AppTheme.textSecondary,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    gender.substring(0, 1).toUpperCase() + 
                                        gender.substring(1),
                                    style: TextStyle(
                                      color: isSelected 
                                          ? AppTheme.primaryColor 
                                          : AppTheme.textPrimary,
                                      fontWeight: isSelected 
                                          ? FontWeight.w600 
                                          : FontWeight.normal,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  
                  if (viewModel.getGenderError() != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        viewModel.getGenderError()!,
                        style: const TextStyle(
                          color: AppTheme.errorColor,
                          fontSize: 12,
                        ),
                      ),
                    ),
                ],
              ),
              
              const SizedBox(height: 32),
              
              // Error Message
              if (viewModel.errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 24),
                  child: ErrorMessageWidget.apiError(
                    message: viewModel.errorMessage!,
                    onRetry: viewModel.register,
                  ),
                ),
              
              // Register Button
              ElevatedButton(
                onPressed: viewModel.isBusy ? null : viewModel.register,
                child: viewModel.isBusy
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            AppTheme.textOnPrimary,
                          ),
                        ),
                      )
                    : const Text(
                        'Create Account',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
              
              const SizedBox(height: 24),
              
              // Login Link
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Already have an account? ',
                    style: TextStyle(
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  TextButton(
                    onPressed: viewModel.navigateToLogin,
                    child: const Text(
                      'Login',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    required FocusNode focusNode,
    required TextInputType keyboardType,
    required TextInputAction textInputAction,
    required Function(String) onChanged,
    String? errorText,
    String? hintText,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        
        TextFormField(
          controller: controller,
          focusNode: focusNode,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          onChanged: onChanged,
          inputFormatters: inputFormatters,
          decoration: InputDecoration(
            hintText: hintText,
            errorText: errorText,
          ),
        ),
      ],
    );
  }

  @override
  RegisterViewModel viewModelBuilder(BuildContext context) => RegisterViewModel();

  @override
  void onViewModelReady(RegisterViewModel viewModel) => syncFormWithViewModel(viewModel);
}