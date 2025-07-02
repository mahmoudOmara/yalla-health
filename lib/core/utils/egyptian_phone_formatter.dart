/// Utility class for formatting and handling Egyptian phone numbers
/// Supports the +20 country code format with proper validation
class EgyptianPhoneFormatter {
  static const String countryCode = '+20';
  static const int maxDigits = 10;
  static const List<String> validPrefixes = ['10', '11', '12', '15'];

  /// Formats a phone number string for display
  /// Example: "1012345678" becomes "+20 101 234 5678"
  static String format(String input) {
    final digits = _extractDigits(input);
    
    if (digits.isEmpty) return '';
    
    // Limit to maxDigits
    final limitedDigits = digits.length > maxDigits 
        ? digits.substring(0, maxDigits) 
        : digits;
    
    if (limitedDigits.length <= 2) {
      return '$countryCode $limitedDigits';
    }
    if (limitedDigits.length <= 5) {
      return '$countryCode ${limitedDigits.substring(0, 2)} ${limitedDigits.substring(2)}';
    }
    if (limitedDigits.length <= 8) {
      return '$countryCode ${limitedDigits.substring(0, 2)} ${limitedDigits.substring(2, 5)} ${limitedDigits.substring(5)}';
    }
    
    // Full format: +20 XXX XXX XXXX
    final prefix = limitedDigits.substring(0, 2);
    final middle = limitedDigits.substring(2, 5);
    final suffix = limitedDigits.substring(5);
    return '$countryCode $prefix $middle $suffix';
  }

  /// Returns a clean phone number with country code
  /// Example: "101 234 5678" becomes "+201012345678"
  static String clean(String input) {
    final digits = _extractDigits(input);
    final limitedDigits = digits.length > maxDigits 
        ? digits.substring(0, maxDigits) 
        : digits;
    return '$countryCode$limitedDigits';
  }

  /// Validates if the phone number format is correct for Egypt
  static bool isValid(String input) {
    final digits = _extractDigits(input);
    
    // Must be exactly 10 digits
    if (digits.length != maxDigits) return false;
    
    // Must start with valid prefix
    final prefix = digits.substring(0, 2);
    return validPrefixes.contains(prefix);
  }

  /// Extracts only digits from input string
  static String extractDigits(String input) {
    return input.replaceAll(RegExp(r'[^\d]'), '');
  }
  
  /// Private method for internal use (kept for backward compatibility)
  static String _extractDigits(String input) => extractDigits(input);

  /// Returns example format for UI hints
  static String get exampleFormat => '$countryCode 101 234 5678';

  /// Returns helper text for user guidance
  static String get helperText => 'Format: $countryCode 1X XXX XXXX';

  /// Returns the mask pattern for input formatters
  static String get maskPattern => '$countryCode ### ### ####';
}