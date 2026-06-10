class AppConstants {
  AppConstants._();

  static const String apiBaseUrl = 'http://192.168.0.195:5000';

  static const String appName      = 'Noor Beauty Salon';
  static const String salonLocation = 'Dhaka, Bangladesh';
  static const String salonPhone   = '+8801711726728';
  static const String salonEmail   = 'info@noorbeauty.com';

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

  /// Normalises a raw phone input to full international format.
  /// BD numbers (start with 0 or 1) → +880...
  /// Already-international (+... or 00...) → kept as-is.
  static String normalizePhone(String raw) {
    final s = raw.replaceAll(RegExp(r'[\s\-()]'), '');
    if (s.startsWith('+'))  return s;
    if (s.startsWith('00')) return '+${s.substring(2)}';
    if (s.startsWith('0'))  return '+880${s.substring(1)}';
    return '+880$s';
  }
}

class StorageKeys {
  StorageKeys._();

  static const String accessToken      = 'access_token';
  static const String refreshToken     = 'refresh_token';
  static const String userId           = 'user_id';
  static const String userName         = 'user_name';
  static const String userEmail        = 'user_email';
  static const String favoriteStylists = 'favorite_stylists';
  static const String fcmToken         = 'fcm_token';
  static const String darkMode         = 'dark_mode';
}

class ApiEndpoints {
  ApiEndpoints._();

  // OTP auth (new passwordless flow)
  static const String requestOtp   = '/api/auth/request-otp';
  static const String verifyOtp    = '/api/auth/verify-otp';
  static const String refreshToken = '/api/auth/refresh';
  static const String profile      = '/api/auth/profile';
  static const String deleteAccount = '/api/auth/account';

  static const String services = '/api/services';
  static const String staff    = '/api/staff';
  static String staffAvailability(String id) => '/api/staff/$id/availability';

  static const String bookings = '/api/bookings';
  static String booking(String id) => '/api/bookings/$id';
  static String customerBookings(String customerId) =>
      '/api/bookings/customer/$customerId';

  static const String reviews = '/api/reviews';
}
