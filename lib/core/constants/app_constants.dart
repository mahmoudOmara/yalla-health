class AppConstants {
  // App Info
  static const String appName = 'YallaHealth';
  static const String appTagline = 'Your Health, Our Priority';
  
  // Colors
  static const int primaryColorValue = 0xFF2E7D32;
  
  // Egyptian Phone Number Validation
  static const String phoneCountryCode = '+20';
  static const List<String> validEgyptianPrefixes = ['10', '11', '12', '15'];
  static const int phoneNumberLength = 11; // Including prefix
  
  // File Upload Limits (in bytes)
  static const int maxImageSize = 10 * 1024 * 1024; // 10MB
  static const int maxPdfSize = 25 * 1024 * 1024; // 25MB
  static const int maxDocumentSize = 15 * 1024 * 1024; // 15MB
  
  // Supported file types
  static const List<String> supportedImageTypes = ['jpg', 'jpeg', 'png'];
  static const List<String> supportedDocumentTypes = ['pdf', 'doc', 'docx'];
  
  // Form Validation
  static const int minNameLength = 2;
  static const int maxNameLength = 50;
  static const int minAge = 13;
  static const int maxAge = 120;
  static const int maxIssueTitle = 100;
  static const int maxDescription = 500;
  static const int maxSymptoms = 300;
  static const int maxTreatment = 300;
  static const int maxNotes = 500;
  
  // OTP Configuration
  static const int otpLength = 6;
  static const int otpTimeoutSeconds = 300; // 5 minutes
  
  // Search Configuration
  static const int searchDebounceMs = 300;
  
  // Network Configuration
  static const int connectionTimeoutSeconds = 30;
  static const int receiveTimeoutSeconds = 30;
  
  // Shared Preferences Keys
  static const String keyAuthToken = 'auth_token';
  static const String keyUserData = 'user_data';
  static const String keySelectedAccountId = 'selected_account_id';
  static const String keySharedUsers = 'shared_users';
  static const String keyRememberLogin = 'remember_login';
  
  // Error Messages
  static const String genericErrorMessage = 'Something went wrong. Please try again.';
  static const String networkErrorMessage = 'Please check your internet connection and try again.';
  static const String authErrorMessage = 'Authentication failed. Please login again.';
  static const String validationErrorMessage = 'Please check your input and try again.';
  
  // Success Messages
  static const String loginSuccessMessage = 'Login successful';
  static const String registrationSuccessMessage = 'Registration successful';
  static const String otpSentMessage = 'OTP sent successfully';
  static const String healthIssueSavedMessage = 'Health issue saved successfully';
  static const String healthIssueDeletedMessage = 'Health issue deleted successfully';
  static const String fileUploadedMessage = 'File uploaded successfully';
  static const String followUpBookedMessage = 'Follow-up booked successfully';
  static const String reminderAddedMessage = 'Reminder added successfully';
  
  // Navigation
  static const String routeSplash = '/splash';
  static const String routeLogin = '/login';
  static const String routeRegister = '/register';
  static const String routeOtp = '/otp';
  static const String routeHome = '/home';
  static const String routeAddHealthIssue = '/add-health-issue';
  static const String routeEditHealthIssue = '/edit-health-issue';
  static const String routeHealthIssueDetail = '/health-issue-detail';
  static const String routeContact = '/contact';
  static const String routeCalendar = '/calendar';
  static const String routeHistory = '/history';
  static const String routeSettings = '/settings';
}