import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked/stacked_annotations.dart';
import 'package:yalla_health/core/constants/app_constants.dart';
import 'package:yalla_health/core/theme/app_theme.dart';
import 'package:yalla_health/core/widgets/error_message_widget.dart';
import 'package:yalla_health/features/authentication/ui/viewmodels/otp_viewmodel.dart';
import 'otp_view.form.dart';

@FormView(fields: [
  FormTextField(name: 'otp'),
])
class OtpView extends StackedView<OtpViewModel> with $OtpView {
  final String phone;
  final bool isRegistration;

  const OtpView({
    Key? key,
    required this.phone,
    required this.isRegistration,
  }) : super(key: key);

  @override
  Widget builder(
    BuildContext context,
    OtpViewModel viewModel,
    Widget? child,
  ) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundPrimary,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 40),
              
              // Back button
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  onPressed: viewModel.navigateBack,
                  icon: const Icon(
                    Icons.arrow_back_ios,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Title
              Text(
                isRegistration ? 'Verify Your Number' : 'Enter OTP Code',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
              
              const SizedBox(height: 8),
              
              RichText(
                text: TextSpan(
                  style: const TextStyle(
                    fontSize: 16,
                    color: AppTheme.textSecondary,
                  ),
                  children: [
                    const TextSpan(text: 'We sent a 6-digit code to '),
                    TextSpan(
                      text: viewModel.maskedPhone,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 40),
              
              // OTP Input
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Enter OTP Code',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  
                  TextFormField(
                    controller: otpController,
                    focusNode: otpFocusNode,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 8,
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(AppConstants.otpLength),
                    ],
                    onChanged: viewModel.onOtpChanged,
                    decoration: InputDecoration(
                      hintText: '123456',
                      hintStyle: TextStyle(
                        color: AppTheme.textHint.withOpacity(0.5),
                        letterSpacing: 8,
                      ),
                      errorText: viewModel.hasOtpValidationMessage ? viewModel.otpValidationMessage : null,
                      counterText: '',
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 24),
              
              // Timer and Resend
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    viewModel.canResend ? 'Code expired' : 'Code expires in ${viewModel.formattedTime}',
                    style: TextStyle(
                      color: viewModel.canResend ? AppTheme.errorColor : AppTheme.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                  
                  if (viewModel.canResend)
                    TextButton(
                      onPressed: viewModel.isBusy ? null : viewModel.resendOtp,
                      child: const Text(
                        'Resend Code',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
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
                    onRetry: viewModel.verifyOtp,
                  ),
                ),
              
              // Verify Button
              ElevatedButton(
                onPressed: viewModel.isBusy ? null : viewModel.verifyOtp,
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
                    : Text(
                        isRegistration ? 'Create Account' : 'Verify & Login',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
              
              const Spacer(),
              
              // Help Text
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.infoColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.info_outline,
                      color: AppTheme.infoColor,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Having trouble? Check your SMS messages or wait ${viewModel.formattedTime} to resend the code.',
                        style: const TextStyle(
                          color: AppTheme.infoColor,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  @override
  OtpViewModel viewModelBuilder(BuildContext context) => OtpViewModel(
        phone: phone,
        isRegistration: isRegistration,
      );

  @override
  void onViewModelReady(OtpViewModel viewModel) {
    syncFormWithViewModel(viewModel);
    viewModel.initialize();
  }
}