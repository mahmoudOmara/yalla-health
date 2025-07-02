/// Utility class for formatting and handling Egyptian phone numbers
/// Assumes input does NOT contain country code, outputs formatted numbers
class EgyptianPhoneFormatter {
  static const String countryCode = '+20';
  static const int maxDigits = 10;
  static const List<String> validPrefixes = ['10', '11', '12', '15'];

  /// Formats a phone number string for display (without country code)
  /// Example: "1012345678" becomes "101 234 5678"
  /// Ignores non-digit characters and handles incomplete numbers
  static String format(String input) {
    // Extract only digits from input
    final digits = _extractDigits(input);
    
    // If no digits, return empty
    if (digits.isEmpty) return '';
    
    // Limit to maxDigits for Egyptian numbers
    final limitedDigits = digits.length > maxDigits 
        ? digits.substring(0, maxDigits) 
        : digits;
    
    // Progressive formatting based on digit count
    if (limitedDigits.length <= 3) {
      return limitedDigits;
    }
    if (limitedDigits.length <= 6) {
      return '${limitedDigits.substring(0, 3)} ${limitedDigits.substring(3)}';
    }
    
    // Full format: XXX XXX XXXX
    final prefix = limitedDigits.substring(0, 3);
    final middle = limitedDigits.substring(3, limitedDigits.length > 6 ? 6 : limitedDigits.length);
    final suffix = limitedDigits.length > 6 ? limitedDigits.substring(6) : '';
    
    return suffix.isEmpty ? '$prefix $middle' : '$prefix $middle $suffix';
  }

  /// Takes a formatted number (without country code) and returns clean format with +20
  /// Example: "101 234 5678" becomes "+201012345678"
  static String clean(String formatted) {
    // Extract only digits from formatted input
    final digits = _extractDigits(formatted);
    
    // If no digits, return empty
    if (digits.isEmpty) return '';
    
    // Limit to maxDigits for Egyptian numbers
    final limitedDigits = digits.length > maxDigits 
        ? digits.substring(0, maxDigits) 
        : digits;
    
    // Return with country code (no spaces)
    return '$countryCode$limitedDigits';
  }

  /// Validates a formatted number (without country code)
  /// Example: "101 234 5678" returns true if valid Egyptian mobile number
  static bool isValid(String formatted) {
    // Extract only digits from formatted input
    final digits = _extractDigits(formatted);
    
    // Must be exactly 10 digits for a complete Egyptian number
    if (digits.length != maxDigits) return false;
    
    // Must start with valid Egyptian mobile prefix
    final prefix = digits.substring(0, 2);
    return validPrefixes.contains(prefix);
  }

  /// Extracts only digits from input string
  static String _extractDigits(String input) {
    return input.replaceAll(RegExp(r'[^\d]'), '');
  }
}