# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Development Commands

### Flutter Development
- `flutter run` - Run the app in debug mode
- `flutter build apk` - Build Android APK
- `flutter build ios` - Build iOS app
- `flutter test` - Run all tests
- `flutter analyze` - Run static analysis
- `flutter clean` - Clean build artifacts
- `flutter pub get` - Install dependencies
- `flutter pub upgrade` - Upgrade dependencies

### Build Runner (Required for Stacked Architecture)
- `flutter packages pub run build_runner build --delete-conflicting-outputs` - Generate auto-generated files (routes, locator, forms)
- `flutter packages pub run build_runner watch --delete-conflicting-outputs` - Watch for changes and auto-generate

### Testing
- `flutter test test/widget_test.dart` - Run specific widget test
- `flutter test --coverage` - Run tests with coverage report

## Architecture Overview

This is a Flutter application implementing **Clean Architecture with Stacked state management** for YallaHealth, a centralized health management platform for Egyptian users.

### Project Structure
```
lib/
├── app/                     # Stacked app setup with auto-generated files
│   ├── app.dart            # App configuration with routes and dependencies
│   ├── app.locator.dart    # Auto-generated service locator
│   └── app.router.dart     # Auto-generated navigation routes
├── core/                   # Cross-cutting concerns
│   ├── constants/          # App-wide constants
│   ├── errors/             # Error handling (failures, exceptions)
│   ├── network/            # Network configuration
│   ├── storage/            # Local storage setup
│   ├── theme/              # App theming
│   ├── utils/              # Utility functions
│   ├── validators/         # Form validators
│   └── widgets/            # Reusable widgets
├── features/               # Feature-based modules
│   └── [feature_name]/
│       ├── data/           # Data layer
│       │   ├── datasources/ # Remote/Local data sources
│       │   ├── models/     # Data models with JSON serialization
│       │   └── repositories/ # Repository implementations
│       ├── domain/         # Domain layer
│       │   ├── entities/   # Business entities
│       │   ├── repositories/ # Repository interfaces
│       │   └── usecases/   # Business use cases
│       └── ui/             # Presentation layer
│           ├── views/      # View widgets (pages)
│           ├── viewmodels/ # ViewModels for state management
│           └── widgets/    # Feature-specific widgets
├── services/               # App-wide services
└── main.dart
```

### Key Architecture Principles

**Clean Architecture Layers:**
- **Presentation**: Views, ViewModels, Widgets
- **Domain**: Entities, Use Cases, Repository Interfaces
- **Data**: Repository Implementations, Data Sources, Models

**State Management:**
- Uses **Stacked** framework with reactive ViewModels
- BaseViewModel for basic state management
- FormViewModel for form handling with validation
- ReactiveServiceMixin for cross-cutting reactive services

**Dependency Injection:**
- All dependencies registered in `app/app.dart`
- Auto-generated service locator with `get_it`
- Services, repositories, and use cases are LazySingleton

**Navigation:**
- Auto-generated routes using `stacked_generator`
- Centralized navigation through NavigationService
- Type-safe navigation with generated arguments

### Key Features

**Authentication System:**
- Egyptian phone number validation (+20 prefix)
- OTP-based login/registration
- JWT token authentication
- Auto-login with stored tokens

**Health Management:**
- Multi-account access with shared permissions
- CRUD operations for health issues
- File upload support (images, PDFs, documents)  
- Calendar integration for follow-ups and reminders
- Local fuzzy search with fuzzywuzzy package

**Data Management:**
- No caching strategy - always fetch fresh data
- Either<Failure, Success> return types for error handling
- Account-specific data requests with X-User-UUID header
- Device information headers for all API requests

### Important Implementation Details

**Egyptian Phone Numbers:**
- Must start with prefixes: 10, 11, 12, 15
- Format: +20XXXXXXXXXX (11 digits total)
- Validation enforced at UI and API levels

**File Upload Limits:**
- Images: 10MB max
- PDFs: 25MB max
- Documents: 15MB max

**API Headers Required:**
```
Authorization: Bearer {jwt_token}
X-Device-Name: {device_brand_model}
X-Platform: {os_version}  
X-App-Version: {app_version_build}
X-User-UUID: {selected_account_uuid}
```

**Navigation Structure:**
- Bottom tabs: Home, Contact, Calendar, History, Settings
- Portrait orientation only
- No offline support - online-only application

### Development Workflow

1. **After Schema Changes**: Run build_runner to regenerate files
2. **New Features**: Follow Clean Architecture with domain-first approach
3. **Forms**: Use FormViewModel with reactive form fields
4. **Services**: Use ReactiveServiceMixin for global state
5. **Testing**: Mock all external dependencies, test ViewModels thoroughly

### Key Packages
- `stacked` - State management framework
- `dartz` - Functional programming (Either types)
- `get_it` - Dependency injection
- `dio` - HTTP client
- `json_annotation` - JSON serialization
- `fuzzywuzzy` - Local search functionality
- `file_picker` - File selection
- `table_calendar` - Calendar widget

### Brand Guidelines
- Primary Color: #2E7D32 (Green)
- App Name: YallaHealth
- Target Market: Egyptian users only
- UI/UX: Simple, accessible, health-focused design