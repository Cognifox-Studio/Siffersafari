/// Lightweight input validation utilities for user data
class InputValidators {
  /// Validate parent PIN: must be 4-6 digits
  static String? validatePin(String? value) {
    if (value == null || value.isEmpty) {
      return 'PIN kan inte vara tom';
    }
    if (value.length < 4 || value.length > 6) {
      return 'PIN måste vara 4-6 siffror';
    }
    if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
      return 'PIN får bara innehålla siffror';
    }
    return null;
  }

  /// Validate profile name: 1-30 chars, no leading/trailing spaces
  static String? validateProfileName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Namn kan inte vara tomt';
    }
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      return 'Namn kan inte bara innehålla mellanslag';
    }
    if (trimmed.length > 30) {
      return 'Namn får max vara 30 tecken';
    }
    // Disallow certain special characters that could cause issues
    if (RegExp(r'[<>"/\\|?*]').hasMatch(trimmed)) {
      return 'Namn innehåller otillåtna tecken';
    }
    return null;
  }

  /// Validate security answer: 1-100 chars, non-empty
  static String? validateSecurityAnswer(String? value) {
    if (value == null || value.isEmpty) {
      return 'Svar kan inte vara tomt';
    }
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      return 'Svar kan inte bara innehålla mellanslag';
    }
    if (trimmed.length > 100) {
      return 'Svar får max vara 100 tecken';
    }
    return null;
  }

  /// Sanitize PIN: strip non-digits
  static String sanitizePin(String value) {
    return value.replaceAll(RegExp(r'[^0-9]'), '');
  }

  /// Sanitize profile name: trim and lowercase
  static String sanitizeProfileName(String value) {
    return value.trim();
  }

  /// Sanitize security answer: trim
  static String sanitizeSecurityAnswer(String value) {
    return value.trim();
  }
}
