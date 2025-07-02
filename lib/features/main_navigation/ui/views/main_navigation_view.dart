import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:yalla_health/core/theme/app_theme.dart';
import 'package:yalla_health/features/main_navigation/ui/viewmodels/main_navigation_viewmodel.dart';
import 'package:yalla_health/features/main_navigation/ui/views/tabs/home_tab_view.dart';
import 'package:yalla_health/features/main_navigation/ui/views/tabs/contact_tab_view.dart';
import 'package:yalla_health/features/main_navigation/ui/views/tabs/calendar_tab_view.dart';
import 'package:yalla_health/features/main_navigation/ui/views/tabs/history_tab_view.dart';
import 'package:yalla_health/features/main_navigation/ui/views/tabs/settings_tab_view.dart';

class MainNavigationView extends StackedView<MainNavigationViewModel> {
  const MainNavigationView({Key? key}) : super(key: key);

  @override
  Widget builder(
    BuildContext context,
    MainNavigationViewModel viewModel,
    Widget? child,
  ) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundPrimary,
      body: IndexedStack(
        index: viewModel.currentIndex,
        children: const [
          HomeTabView(),
          ContactTabView(),
          CalendarTabView(),
          HistoryTabView(),
          SettingsTabView(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: viewModel.currentIndex,
        onTap: viewModel.setIndex,
        backgroundColor: AppTheme.backgroundPrimary,
        selectedItemColor: AppTheme.primaryColor,
        unselectedItemColor: AppTheme.textSecondary,
        selectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
        unselectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w400,
          fontSize: 12,
        ),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_outlined),
            activeIcon: Icon(Icons.chat),
            label: 'Contact',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today_outlined),
            activeIcon: Icon(Icons.calendar_today),
            label: 'Calendar',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history_outlined),
            activeIcon: Icon(Icons.history),
            label: 'History',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings_outlined),
            activeIcon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }

  @override
  MainNavigationViewModel viewModelBuilder(BuildContext context) =>
      MainNavigationViewModel();
}