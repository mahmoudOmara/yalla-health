import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:yalla_health/core/constants/app_constants.dart';
import 'package:yalla_health/core/theme/app_theme.dart';
import 'package:yalla_health/features/authentication/ui/viewmodels/splash_viewmodel.dart';

class SplashView extends StackedView<SplashViewModel> {
  const SplashView({Key? key}) : super(key: key);

  @override
  Widget builder(
    BuildContext context,
    SplashViewModel viewModel,
    Widget? child,
  ) {
    return Scaffold(
      backgroundColor: AppTheme.primaryColor,
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(flex: 2),
            
            // App Logo/Icon
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: AppTheme.textOnPrimary,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: const Icon(
                Icons.health_and_safety,
                size: 64,
                color: AppTheme.primaryColor,
              ),
            ),
            
            const SizedBox(height: 32),
            
            // App Name
            const Text(
              AppConstants.appName,
              style: TextStyle(
                color: AppTheme.textOnPrimary,
                fontSize: 32,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
            
            const SizedBox(height: 8),
            
            // App Tagline
            const Text(
              AppConstants.appTagline,
              style: TextStyle(
                color: AppTheme.textOnPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w300,
                letterSpacing: 0.5,
              ),
            ),
            
            const Spacer(flex: 2),
            
            // Loading Indicator
            if (viewModel.isBusy)
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppTheme.textOnPrimary),
              ),
            
            const SizedBox(height: 32),
            
            // Made in Egypt indicator
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.location_on,
                  color: AppTheme.textOnPrimary.withOpacity(0.7),
                  size: 16,
                ),
                const SizedBox(width: 4),
                Text(
                  'Made in Egypt',
                  style: TextStyle(
                    color: AppTheme.textOnPrimary.withOpacity(0.7),
                    fontSize: 12,
                    fontWeight: FontWeight.w300,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  @override
  SplashViewModel viewModelBuilder(BuildContext context) => SplashViewModel();

  @override
  void onViewModelReady(SplashViewModel viewModel) => viewModel.initialize();
}