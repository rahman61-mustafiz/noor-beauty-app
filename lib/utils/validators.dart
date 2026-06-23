class Validators {
  Validators._();

  static String? validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Name is required';
    }
    if (value.trim().length < 2) {
      return 'Name must be at least 2 characters';
    }
    return null;
  }

  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Enter a valid email address';
    }
    return null;
  }

  /// Validates phone input for OTP login.
  /// BD numbers: local format (01…) — country code added automatically.
  /// Foreign numbers: must include + or 00 country code prefix.
  static String? validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Phone number is required';
    }
    final cleaned = value.replaceAll(RegExp(r'[\s\-()]'), '');

    if (cleaned.startsWith('+') || cleaned.startsWith('00')) {
      if (cleaned.length < 10) {
        return 'Enter a valid international phone number';
      }
      return null;
    }

    final bdLocal = RegExp(r'^0?1[3-9]\d{8}$');
    if (!bdLocal.hasMatch(cleaned)) {
      return 'Enter a valid BD number (01…) or international (+country code)';
    }
    return null;
  }

  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  static String? validateRating(int? rating) {
    if (rating == null || rating < 1 || rating > 5) {
      return 'Please select a rating between 1 and 5';
    }
    return null;
  }

  static String? validateMfaCode(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Verification code is required';
    }
    if (!RegExp(r'^\d{6}$').hasMatch(value.trim())) {
      return 'Enter a valid 6-digit code';
    }
    return null;
  }

  static String? validateOtp(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Verification code is required';
    }
    if (!RegExp(r'^\d{6}$').hasMatch(value.trim())) {
      return 'Enter a valid 6-digit code';
    }
    return null;
  }
}
