class AppConstants {
  AppConstants._();

  /// Live VPS backend (no trailing slash).
  /// Auth example: $apiBaseUrl/auth/request-otp
  static const String apiBaseUrl = 'https://noor-beauty-backend-production.up.railway.app';

  static const String appName      = 'Noor Beauty Salon';
  static const String salonLocation = 'Dhaka, Bangladesh';
  static const String salonPhone   = '+8801711726728';
  static const String salonEmail   = 'azmir@noorbeauty.com';

  static const int jwtRefreshThresholdMinutes = 5;
  static const int otpResendCooldownSeconds   = 60;

  static const List<int> durationOptions = [30, 60, 120];
  static const List<String> bookingStatuses = [
    'pending', 'confirmed', 'completed', 'cancelled',
  ];
  static const List<String> weekDays = [
    'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday',
  ];
  static const String defaultSalonOpen  = '11:00';
  static const String defaultSalonClose = '21:00';

  /// Normalises a raw phone input to full international E.164-style format.
  ///
  /// Bangladesh: local numbers (01… or 1…) are auto-prefixed with +880.
  /// Foreign: must already include a country code (`+…` or `00…`).
  static String normalizePhone(String raw) {
    final d = raw.replaceAll(RegExp(r'\D'), '');
    // Bangladesh only - foreign numbers are not allowed.
    if (d.length == 13 && RegExp(r'^8801[3-9]\d{8}$').hasMatch(d)) {
      return '+$d';
    }
    if (d.length == 11 && RegExp(r'^01[3-9]\d{8}$').hasMatch(d)) {
      return '+880${d.substring(1)}';
    }
    if (d.length == 10 && RegExp(r'^1[3-9]\d{8}$').hasMatch(d)) {
      return '+880$d';
    }
    throw const FormatException(
      'Please enter a valid Bangladeshi mobile number (e.g. 01XXXXXXXXX)',
    );
  }
}

class StorageKeys {
  StorageKeys._();

  static const String accessToken      = 'access_token';
  static const String refreshToken     = 'refresh_token';
  static const String userId           = 'user_id';
  static const String userName         = 'user_name';
  static const String userEmail        = 'user_email';
  static const String userPhone        = 'user_phone';
  static const String favoriteStylists = 'favorite_stylists';
  static const String fcmToken         = 'fcm_token';
  static const String darkMode         = 'dark_mode';
}

class ApiEndpoints {
  ApiEndpoints._();

  // Phone OTP auth (passwordless)
  static const String requestOtp    = '/api/auth/send-otp';
  static const String verifyOtp     = '/api/auth/verify-otp';
  static const String refreshToken  = '/api/auth/refresh';
  static const String profile       = '/api/auth/profile';
  static const String deleteAccount = '/api/auth/account';

  static const String services = '/api/services/menu';
  static const String staff    = '/api/staff';
  static String staffAvailability(String id) => '/api/staff/$id/availability';

  static const String bookings = '/api/bookings';
  static String booking(String id) => '/api/bookings/$id';
  static String customerBookings(String customerId) =>
      '/api/bookings/customer/$customerId';

  static const String reviews = '/api/reviews';
  static const String gallery = '/api/gallery';
  static const String announcement = '/api/announcement';
}
