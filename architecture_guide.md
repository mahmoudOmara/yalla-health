# Flutter Clean Architecture Implementation with Stacked

Hi Claude! I need you to help me implement a Flutter application using Clean Architecture principles with Stacked state management. Please follow this exact structure and implementation approach:

## Project Architecture Requirements

### 1. Clean Architecture Layers
Implement the standard Clean Architecture with these layers:
- **Presentation Layer**: UI, ViewModels, Views, Widgets
- **Domain Layer**: Entities, use cases, repository interfaces, business logic
- **Data Layer**: Repository implementations, data sources, models, mappers

### 2. Folder Structure
Please create this exact folder structure:

```
lib/
├── app/
│   ├── app.dart                # Stacked app setup
│   ├── app.locator.dart        # Auto-generated service locator
│   └── app.router.dart         # Auto-generated routes
├── core/
│   ├── constants/              # App-wide constants
│   ├── errors/                 # Error handling (failures, exceptions)
│   ├── network/                # Network configuration
│   ├── storage/                # Local storage setup
│   ├── theme/                  # App theming
│   ├── utils/                  # Utility functions
│   ├── validators/             # Form validators
│   └── widgets/                # Reusable widgets
├── features/
│   └── [feature_name]/
│       ├── data/
│       │   ├── datasources/    # Remote/Local data sources
│       │   ├── models/         # Data models with JSON serialization
│       │   └── repositories/   # Repository implementations
│       ├── domain/
│       │   ├── entities/       # Business entities
│       │   ├── repositories/   # Repository interfaces
│       │   └── usecases/       # Business use cases
│       └── ui/
│           ├── views/          # View widgets (pages)
│           ├── viewmodels/     # ViewModels for state management
│           └── widgets/        # Feature-specific widgets
├── services/                   # App-wide services
│   ├── api_service.dart
│   ├── storage_service.dart
│   └── navigation_service.dart
└── main.dart
```

### 3. State Management with Stacked
- Use **stacked** package with ViewModels
- Use **BaseViewModel** for reactive state management
- Use **FormViewModel** for form handling
- Use **FutureViewModel** for async operations
- Use **StreamViewModel** for real-time data
- Implement **ReactiveServiceMixin** for service reactivity

### 4. Stacked App Setup
Configure the app with stacked_generator:

```dart
// app.dart
@StackedApp(
  routes: [
    MaterialRoute(page: SplashView),
    MaterialRoute(page: LoginView),
    MaterialRoute(page: RegisterView),
    MaterialRoute(page: OtpView),
    MaterialRoute(page: HomeView),
    MaterialRoute(page: AddHealthIssueView),
    MaterialRoute(page: HealthIssueDetailView),
    MaterialRoute(page: ContactView),
    MaterialRoute(page: CalendarView),
    MaterialRoute(page: HistoryView),
    MaterialRoute(page: SettingsView),
  ],
  dependencies: [
    // Services
    LazySingleton(classType: ApiService),
    LazySingleton(classType: StorageService),
    LazySingleton(classType: NavigationService),
    LazySingleton(classType: UserService),
    
    // Repositories
    LazySingleton(classType: AuthRepository, asType: IAuthRepository),
    LazySingleton(classType: HealthIssueRepository, asType: IHealthIssueRepository),
    LazySingleton(classType: FileRepository, asType: IFileRepository),
    LazySingleton(classType: CalendarRepository, asType: ICalendarRepository),
    
    // Use Cases
    LazySingleton(classType: LoginUseCase),
    LazySingleton(classType: RegisterUseCase),
    LazySingleton(classType: VerifyOtpUseCase),
    LazySingleton(classType: GetUserDetailsUseCase),
    LazySingleton(classType: GetSharedUsersUseCase),
    LazySingleton(classType: GetHealthIssuesUseCase),
    LazySingleton(classType: AddHealthIssueUseCase),
    LazySingleton(classType: UpdateHealthIssueUseCase),
    LazySingleton(classType: GetHealthIssueDetailUseCase),
    LazySingleton(classType: AddUpdateUseCase),
    LazySingleton(classType: UploadFileUseCase),
    LazySingleton(classType: BookFollowUpUseCase),
    LazySingleton(classType: AddReminderUseCase),
    LazySingleton(classType: GetCalendarEventsUseCase),
  ],
)
class App {}
```

### 5. ViewModel Pattern
Implement ViewModels with this pattern:

```dart
class FeatureViewModel extends BaseViewModel {
  final FeatureUseCase _featureUseCase = locator<FeatureUseCase>();
  final NavigationService _navigationService = locator<NavigationService>();
  
  // State variables
  String? _errorMessage;
  String? get errorMessage => _errorMessage;
  
  // Business methods
  Future<void> performAction() async {
    setBusy(true);
    
    final result = await _featureUseCase.call(params);
    
    result.fold(
      (failure) {
        _errorMessage = failure.message;
        notifyListeners();
      },
      (success) {
        // Handle success
        _navigationService.navigateTo(Routes.nextView);
      },
    );
    
    setBusy(false);
  }
  
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
```

### 6. View Structure
Structure all views like this:

```dart
class SomeView extends StackedView<SomeViewModel> {
  const SomeView({Key? key}) : super(key: key);

  @override
  Widget builder(
    BuildContext context,
    SomeViewModel viewModel,
    Widget? child,
  ) {
    return Scaffold(
      body: viewModel.isBusy
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                if (viewModel.hasError)
                  ErrorWidget(
                    message: viewModel.modelError,
                    onRetry: viewModel.initialise,
                  ),
                // Main content
              ],
            ),
    );
  }

  @override
  SomeViewModel viewModelBuilder(BuildContext context) => SomeViewModel();
}
```

### 7. Form Handling with Stacked
Use FormViewModel for form handling:

```dart
class LoginViewModel extends FormViewModel {
  final LoginUseCase _loginUseCase = locator<LoginUseCase>();
  final NavigationService _navigationService = locator<NavigationService>();
  
  String? _errorMessage;
  String? get errorMessage => _errorMessage;
  
  Future<void> login() async {
    if (!isFormValid) return;
    
    setBusy(true);
    
    final params = LoginParams(
      phone: phoneValue!,
    );
    
    final result = await _loginUseCase.call(params);
    
    result.fold(
      (failure) {
        _errorMessage = failure.message;
        notifyListeners();
      },
      (success) {
        _navigationService.navigateTo(Routes.otpView);
      },
    );
    
    setBusy(false);
  }
  
  @override
  void setFormStatus() {
    // Form validation logic
  }
}

// Form view with reactive form fields
class LoginView extends StackedView<LoginViewModel> with $LoginView {
  const LoginView({Key? key}) : super(key: key);

  @override
  Widget builder(BuildContext context, LoginViewModel viewModel, Widget? child) {
    return Scaffold(
      body: Form(
        child: Column(
          children: [
            TextFormField(
              controller: phoneController,
              focusNode: phoneFocusNode,
              decoration: const InputDecoration(labelText: 'Phone'),
            ),
            ElevatedButton(
              onPressed: viewModel.isBusy ? null : viewModel.login,
              child: viewModel.isBusy
                  ? const CircularProgressIndicator()
                  : const Text('Login'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  LoginViewModel viewModelBuilder(BuildContext context) => LoginViewModel();

  @override
  void onViewModelReady(LoginViewModel viewModel) => syncFormWithViewModel(viewModel);
}
```

### 8. Error Handling Strategy

```dart
abstract class Failure extends Equatable {
  final String message;
  const Failure(this.message);
}

class ServerFailure extends Failure {
  const ServerFailure(String message) : super(message);
}

class CacheFailure extends Failure {
  const CacheFailure(String message) : super(message);
}

class NetworkFailure extends Failure {
  const NetworkFailure(String message) : super(message);
}

class ValidationFailure extends Failure {
  const ValidationFailure(String message) : super(message);
}
```

### 9. Use Case Pattern

```dart
abstract class UseCase<Type, Params> {
  Future<Either<Failure, Type>> call(Params params);
}

class NoParams extends Equatable {
  @override
  List<Object> get props => [];
}
```

### 10. Service Layer
Create services for cross-cutting concerns:

```dart
// api_service.dart
@LazySingleton()
class ApiService {
  final Dio _dio;
  
  ApiService(this._dio);
  
  Future<Response> post(String endpoint, {Map<String, dynamic>? data}) async {
    try {
      return await _dio.post(endpoint, data: data);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}

// storage_service.dart
@LazySingleton()
class StorageService {
  Future<void> saveToken(String token) async {
    // Implementation
  }
  
  Future<String?> getToken() async {
    // Implementation
  }
}

// user_service.dart - For current selected account management
@LazySingleton()
class UserService with ReactiveServiceMixin {
  User? _currentUser;
  User? get currentUser => _currentUser;
  
  String? _selectedAccountId;
  String? get selectedAccountId => _selectedAccountId;
  
  List<User> _sharedUsers = [];
  List<User> get sharedUsers => _sharedUsers;
  
  bool get isAuthenticated => _currentUser != null;
  
  void setUser(User user) {
    _currentUser = user;
    _selectedAccountId = user.id; // Default to current user
    notifyListeners();
  }
  
  void setSharedUsers(List<User> users) {
    _sharedUsers = users;
    notifyListeners();
  }
  
  void selectAccount(String accountId) {
    _selectedAccountId = accountId;
    notifyListeners();
  }
  
  void logout() {
    _currentUser = null;
    _selectedAccountId = null;
    _sharedUsers = [];
    notifyListeners();
  }
}
```

### 11. Navigation with Stacked
Use auto-generated navigation:

```dart
// In ViewModel
final NavigationService _navigationService = locator<NavigationService>();

// Navigate to next screen
_navigationService.navigateTo(Routes.homeView);

// Navigate with arguments
_navigationService.navigateTo(
  Routes.healthIssueDetailView,
  arguments: HealthIssueDetailViewArguments(issueId: '123'),
);

// Navigate and clear stack
_navigationService.clearStackAndShow(Routes.homeView);
```

### 12. Reactive Services
Create reactive services for global state:

```dart
// In ViewModel, listen to service changes
class HomeViewModel extends ReactiveViewModel {
  final UserService _userService = locator<UserService>();
  final GetHealthIssuesUseCase _getHealthIssuesUseCase = locator<GetHealthIssuesUseCase>();
  
  User? get currentUser => _userService.currentUser;
  String? get selectedAccountId => _userService.selectedAccountId;
  List<User> get sharedUsers => _userService.sharedUsers;
  
  @override
  List<ReactiveServiceMixin> get reactiveServices => [_userService];
  
  @override
  void onAnyListenableChanged() {
    // Reload health issues when selected account changes
    if (_userService.selectedAccountId != null) {
      loadHealthIssues();
    }
  }
}
```

### 13. Key Packages to Use
Include these packages in pubspec.yaml:
```yaml
dependencies:
  stacked: ^3.4.0
  stacked_services: ^1.1.0
  dartz: ^0.10.1
  get_it: ^7.6.0
  equatable: ^2.0.5
  json_annotation: ^4.8.1
  dio: ^5.3.0
  shared_preferences: ^2.2.0
  connectivity_plus: ^4.0.2
  file_picker: ^6.1.1
  table_calendar: ^3.0.9
  fuzzywuzzy: ^1.1.6
  device_info_plus: ^9.1.0

dev_dependencies:
  stacked_generator: ^1.3.3
  build_runner: ^2.4.6
  json_serializable: ^6.7.1
```

### 14. Build Runner Commands
After setting up, run:
```bash
flutter packages pub run build_runner build --delete-conflicting-outputs
```

### 15. Repository Pattern
- Create abstract repository interfaces in domain layer
- Implement concrete repositories in data layer
- Use Either<Failure, Success> return types
- Handle all data source exceptions and convert to failures

### 16. Model Implementation
- Create data models with **json_annotation**
- Implement **fromJson** and **toJson** methods
- Create **toDomain()** method to convert to domain entities
- Keep domain entities pure (no JSON dependencies)

### 17. Device Information Collection
**Automatic Collection for All API Requests:**
- **Device Name**: Brand + Model (e.g., "Samsung Galaxy S21", "iPhone 14 Pro")
- **Platform**: OS + Version (e.g., "Android 13", "iOS 17.1")
- **App Version**: Version + Build (e.g., "1.0.0 (1)")

**Request Headers:**
```
X-Device-Name: Samsung Galaxy S21
X-Platform: Android 13
X-App-Version: 1.0.0 (1)
```

### 18. File Upload Configuration
**Supported File Types & Size Limits:**
- Images: 10MB max
- PDFs: 25MB max  
- Documents: 15MB max

**Implementation Notes:**
- Use file_picker package for file selection
- Validate file size before upload
- Show upload progress
- Handle upload errors gracefully

### 19. Search Implementation
- Use fuzzywuzzy package for local fuzzy search
- Search across: issue name, description, symptoms, treatment, notes
- No server-side search API calls
- Implement debounced search for performance

### 20. Testing Strategy
Structure tests similarly:

```dart
// ViewModel tests
class MockGetHealthIssuesUseCase extends Mock implements GetHealthIssuesUseCase {}

void main() {
  group('HomeViewModel Tests', () {
    late HomeViewModel viewModel;
    late MockGetHealthIssuesUseCase mockGetHealthIssuesUseCase;
    
    setUp(() {
      mockGetHealthIssuesUseCase = MockGetHealthIssuesUseCase();
      // Setup locator with mocks
      viewModel = HomeViewModel();
    });
    
    test('should load health issues when account is selected', () async {
      // Test implementation
    });
  });
}
```

## Implementation Instructions

1. **Start with**: Create the folder structure and app.dart configuration
2. **Authentication**: Complete auth flow (login, register, OTP, auto-login)
3. **Core Setup**: Implement error handling, services, and core utilities
4. **Home Feature**: Health issues list with account selection and local search
5. **Health Issue Management**: Add/Edit health issues with all required fields
6. **Detail Views**: Health issue detail with actions (updates, files, follow-ups, reminders)
7. **Calendar**: Monthly view with events and filtering
8. **Contact**: Basic structure (detailed implementation TBD)
9. **Navigation**: Bottom navigation bar implementation
10. **Testing**: Write unit tests for ViewModels and services

## API Integration Notes
- Ask for specific API endpoints before implementing each feature
- Use placeholder API calls initially if endpoints not ready
- Include device information headers in all requests
- Handle Egyptian phone number formatting (+20XXXXXXXXXX)
- No caching - always fetch fresh data when switching accounts

## Code Style Preferences
- Use camelCase for variables and functions
- Use PascalCase for classes
- Use snake_case for file names
- Use UPPER_SNAKE_CASE for constants
- Always use const constructors when possible
- Follow Flutter/Dart best practices
- Keep code concise and avoid unnecessary complexity

---

**Important**: Always use the stacked_generator for dependency injection and routing, handle errors gracefully with Either types, and maintain clean separation between layers. Each feature should be completely independent and testable with proper ViewModel implementation. Ask for API endpoints before implementing data layer functionality.