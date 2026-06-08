class AppConstants {
  AppConstants._();

  /// Configure your VPS API base URL here (no trailing slash).
  static const String apiBaseUrl = 'https://api.noorbeauty.com';

  static const String appName = 'Noor Beauty Salon';
  static const String salonLocation = 'Dhaka, Bangladesh';
  static const String salonPhone = '+880 1XXX-XXXXXX';
  static const String salonEmail = 'info@noorbeauty.com';

  static const int adminSessionTimeoutMinutes = 30;
  static const int jwtRefreshThresholdMinutes = 5;

  static const List<int> durationOptions = [30, 60, 120];
  static const List<String> bookingStatuses = [
    'pending',
    'confirmed',
    'completed',
    'cancelled',
  ];

  static const List<String> weekDays = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];

  static const String defaultSalonOpen = '09:00';
  static const String defaultSalonClose = '21:00';
}

class StorageKeys {
  StorageKeys._();

  static const String accessToken = 'access_token';
  static const String refreshToken = 'refresh_token';
  static const String userId = 'user_id';
  static const String userName = 'user_name';
  static const String userEmail = 'user_email';
  static const String isAdmin = 'is_admin';
  static const String adminToken = 'admin_token';
  static const String adminLastActivity = 'admin_last_activity';
  static const String favoriteStylists = 'favorite_stylists';
  static const String fcmToken = 'fcm_token';
  static const String darkMode = 'dark_mode';
}

class ApiEndpoints {
  ApiEndpoints._();

  static const String register = '/api/auth/register';
  static const String login = '/api/auth/login';
  static const String verifyEmail = '/api/auth/verify-email';
  static const String passwordReset = '/api/auth/password-reset';
  static const String adminLogin = '/api/auth/admin-login';
  static const String verifyMfa = '/api/auth/verify-mfa';
  static const String refreshToken = '/api/auth/refresh';

  static const String services = '/api/services';
  static const String staff = '/api/staff';
  static String staffAvailability(String id) => '/api/staff/$id/availability';

  static const String bookings = '/api/bookings';
  static String booking(String id) => '/api/bookings/$id';
  static String customerBookings(String customerId) =>
      '/api/bookings/customer/$customerId';

  static const String reviews = '/api/reviews';

  static const String adminDashboard = '/api/admin/dashboard';
  static const String adminBookings = '/api/admin/bookings';
  static String adminBooking(String id) => '/api/admin/bookings/$id';
  static const String adminCustomers = '/api/admin/customers';
  static const String adminStaff = '/api/admin/staff';
  static const String adminServices = '/api/admin/services';
  static const String adminReviews = '/api/admin/reviews';
  static const String adminAnalytics = '/api/admin/analytics';
  static const String adminSettings = '/api/admin/settings';
  static const String firebaseConfig = '/api/config/firebase';
}
