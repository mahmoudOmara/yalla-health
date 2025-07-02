import 'package:yalla_health/core/constants/app_constants.dart';

class FormValidators {
  
  // Phone number validation for Egyptian numbers
  static String? validateEgyptianPhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Phone number is required';
    }
    
    // Remove spaces and formatting
    final cleanPhone = value.replaceAll(RegExp(r'[\s\-\(\)]'), '');
    
    // Check if it starts with +20
    if (!cleanPhone.startsWith(AppConstants.phoneCountryCode)) {
      return 'Phone number must start with +20';
    }
    
    // Extract the number part after +20
    final numberPart = cleanPhone.substring(3);
    
    // Check length (should be 10 digits after +20)
    if (numberPart.length != 10) {
      return 'Phone number must be 10 digits after +20';
    }
    
    // Check if all characters are digits
    if (!RegExp(r'^\d+$').hasMatch(numberPart)) {
      return 'Phone number must contain only digits';
    }
    
    // Check if it starts with valid Egyptian prefixes
    final prefix = numberPart.substring(0, 2);
    if (!AppConstants.validEgyptianPrefixes.contains(prefix)) {
      return 'Invalid Egyptian mobile number prefix';
    }
    
    return null;
  }
  
  // Name validation
  static String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Name is required';
    }
    
    if (value.trim().length < AppConstants.minNameLength) {
      return 'Name must be at least ${AppConstants.minNameLength} characters';
    }
    
    if (value.trim().length > AppConstants.maxNameLength) {
      return 'Name must not exceed ${AppConstants.maxNameLength} characters';
    }
    
    // Check for invalid characters (numbers, special characters except spaces)
    if (!RegExp(r'^[a-zA-Z\s\u0600-\u06FF]+$').hasMatch(value.trim())) {
      return 'Name can only contain letters and spaces';
    }
    
    return null;
  }
  
  // Email validation (optional field)
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return null; // Email is optional
    }
    
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return 'Please enter a valid email address';
    }
    
    return null;
  }
  
  // Age validation
  static String? validateAge(String? value) {
    if (value == null || value.isEmpty) {
      return 'Age is required';
    }
    
    final age = int.tryParse(value);
    if (age == null) {
      return 'Please enter a valid age';
    }
    
    if (age < AppConstants.minAge) {
      return 'Age must be at least ${AppConstants.minAge} years';
    }
    
    if (age > AppConstants.maxAge) {
      return 'Age must not exceed ${AppConstants.maxAge} years';
    }
    
    return null;
  }
  
  // Gender validation
  static String? validateGender(String? value) {
    if (value == null || value.isEmpty) {
      return 'Gender is required';
    }
    
    final validGenders = ['male', 'female'];
    if (!validGenders.contains(value.toLowerCase())) {
      return 'Please select a valid gender';
    }
    
    return null;
  }
  
  // OTP validation
  static String? validateOtp(String? value) {
    if (value == null || value.isEmpty) {
      return 'OTP is required';
    }
    
    if (value.length != AppConstants.otpLength) {
      return 'OTP must be ${AppConstants.otpLength} digits';
    }
    
    if (!RegExp(r'^\d+$').hasMatch(value)) {
      return 'OTP must contain only digits';
    }
    
    return null;
  }
  
  // Health issue title validation
  static String? validateIssueTitle(String? value) {
    if (value == null || value.isEmpty) {
      return 'Issue title is required';
    }
    
    if (value.trim().length < 3) {
      return 'Issue title must be at least 3 characters';
    }
    
    if (value.trim().length > AppConstants.maxIssueTitle) {
      return 'Issue title must not exceed ${AppConstants.maxIssueTitle} characters';
    }
    
    return null;
  }
  
  // Description validation
  static String? validateDescription(String? value) {
    if (value == null || value.isEmpty) {
      return 'Description is required';
    }
    
    if (value.trim().length < 10) {
      return 'Description must be at least 10 characters';
    }
    
    if (value.trim().length > AppConstants.maxDescription) {
      return 'Description must not exceed ${AppConstants.maxDescription} characters';
    }
    
    return null;
  }
  
  // Optional text field validation with max length
  static String? validateOptionalText(String? value, int maxLength, String fieldName) {
    if (value == null || value.isEmpty) {
      return null; // Optional field
    }
    
    if (value.trim().length > maxLength) {
      return '$fieldName must not exceed $maxLength characters';
    }
    
    return null;
  }
  
  // Symptoms validation
  static String? validateSymptoms(String? value) {
    return validateOptionalText(value, AppConstants.maxSymptoms, 'Symptoms');
  }
  
  // Treatment validation
  static String? validateTreatment(String? value) {
    return validateOptionalText(value, AppConstants.maxTreatment, 'Treatment');
  }
  
  // Notes validation
  static String? validateNotes(String? value) {
    return validateOptionalText(value, AppConstants.maxNotes, 'Notes');
  }
  
  // Required dropdown validation
  static String? validateDropdown(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }
  
  // Category validation
  static String? validateCategory(String? value) {
    return validateDropdown(value, 'Category');
  }
  
  // Status validation
  static String? validateStatus(String? value) {
    return validateDropdown(value, 'Status');
  }
  
  // Severity validation
  static String? validateSeverity(String? value) {
    return validateDropdown(value, 'Severity');
  }
  
  // Date validation
  static String? validateDate(DateTime? value, String fieldName) {
    if (value == null) {
      return '$fieldName is required';
    }
    
    if (value.isBefore(DateTime.now().subtract(const Duration(days: 365 * 10)))) {
      return '$fieldName cannot be more than 10 years in the past';
    }
    
    if (value.isAfter(DateTime.now().add(const Duration(days: 365 * 5)))) {
      return '$fieldName cannot be more than 5 years in the future';
    }
    
    return null;
  }
  
  // File size validation
  static String? validateFileSize(int fileSize, String fileType) {
    int maxSize;
    
    switch (fileType.toLowerCase()) {
      case 'image':
        maxSize = AppConstants.maxImageSize;
        break;
      case 'pdf':
        maxSize = AppConstants.maxPdfSize;
        break;
      case 'document':
        maxSize = AppConstants.maxDocumentSize;
        break;
      default:
        maxSize = AppConstants.maxDocumentSize;
    }
    
    if (fileSize > maxSize) {
      final maxSizeMB = (maxSize / (1024 * 1024)).toStringAsFixed(1);
      return 'File size exceeds ${maxSizeMB}MB limit for $fileType files';
    }
    
    return null;
  }
  
  // File type validation
  static String? validateFileType(String fileName, String fileType) {
    final extension = fileName.split('.').last.toLowerCase();
    
    List<String> allowedTypes;
    switch (fileType.toLowerCase()) {
      case 'image':
        allowedTypes = AppConstants.supportedImageTypes;
        break;
      case 'document':
        allowedTypes = AppConstants.supportedDocumentTypes;
        break;
      default:
        allowedTypes = [
          ...AppConstants.supportedImageTypes,
          ...AppConstants.supportedDocumentTypes
        ];
    }
    
    if (!allowedTypes.contains(extension)) {
      return 'Unsupported file type. Allowed types: ${allowedTypes.join(', ')}';
    }
    
    return null;
  }
}