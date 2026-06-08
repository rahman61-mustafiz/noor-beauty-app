import 'dart:convert';

import 'package:http/http.dart' as http;

import '../utils/constants.dart';

class ApiException implements Exception {
  final String message;
  final int statusCode;

  const ApiException(this.message, {this.statusCode = 0});

  @override
  String toString() => message;
}

/// Central HTTP client for all REST API calls to the VPS backend.
class ApiService {
  static ApiService? _instance;
  String? _accessToken;
  String? _adminToken;

  ApiService._();

  static ApiService get instance {
    _instance ??= ApiService._();
    return _instance!;
  }

  void setAccessToken(String? token) => _accessToken = token;
  void setAdminToken(String? token) => _adminToken = token;

  String get baseUrl => AppConstants.apiBaseUrl;

  Map<String, String> _headers({bool isAdmin = false}) {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    final token = isAdmin ? _adminToken : _accessToken;
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  Future<dynamic> _handleResponse(http.Response response) async {
    final body = response.body.isNotEmpty
        ? jsonDecode(response.body) as Map<String, dynamic>
        : <String, dynamic>{};

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return body;
    }

    final message = body['message'] as String? ??
        body['error'] as String? ??
        'Request failed (${response.statusCode})';
    throw ApiException(message, statusCode: response.statusCode);
  }

  Future<dynamic> get(
    String endpoint, {
    Map<String, String>? queryParams,
    bool isAdmin = false,
  }) async {
    var uri = Uri.parse('$baseUrl$endpoint');
    if (queryParams != null && queryParams.isNotEmpty) {
      uri = uri.replace(queryParameters: queryParams);
    }

    try {
      final response = await http
          .get(uri, headers: _headers(isAdmin: isAdmin))
          .timeout(const Duration(seconds: 30));
      return _handleResponse(response);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('Network error: ${e.toString()}');
    }
  }

  Future<dynamic> post(
    String endpoint, {
    Map<String, dynamic>? body,
    bool isAdmin = false,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl$endpoint'),
            headers: _headers(isAdmin: isAdmin),
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(const Duration(seconds: 30));
      return _handleResponse(response);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('Network error: ${e.toString()}');
    }
  }

  Future<dynamic> put(
    String endpoint, {
    Map<String, dynamic>? body,
    bool isAdmin = false,
  }) async {
    try {
      final response = await http
          .put(
            Uri.parse('$baseUrl$endpoint'),
            headers: _headers(isAdmin: isAdmin),
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(const Duration(seconds: 30));
      return _handleResponse(response);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('Network error: ${e.toString()}');
    }
  }

  Future<dynamic> delete(
    String endpoint, {
    bool isAdmin = false,
  }) async {
    try {
      final response = await http
          .delete(
            Uri.parse('$baseUrl$endpoint'),
            headers: _headers(isAdmin: isAdmin),
          )
          .timeout(const Duration(seconds: 30));
      return _handleResponse(response);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('Network error: ${e.toString()}');
    }
  }

  // --- Auth endpoints ---

  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) =>
      post(ApiEndpoints.register, body: {
        'name': name,
        'email': email,
        'phone': phone,
        'password': password,
      }) as Future<Map<String, dynamic>>;

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) =>
      post(ApiEndpoints.login, body: {
        'email': email,
        'password': password,
      }) as Future<Map<String, dynamic>>;

  Future<Map<String, dynamic>> verifyEmail({
    required String email,
    required String code,
  }) =>
      post(ApiEndpoints.verifyEmail, body: {
        'email': email,
        'code': code,
      }) as Future<Map<String, dynamic>>;

  Future<Map<String, dynamic>> passwordReset({
    required String email,
  }) =>
      post(ApiEndpoints.passwordReset, body: {
        'email': email,
      }) as Future<Map<String, dynamic>>;

  Future<Map<String, dynamic>> adminLogin({
    required String email,
    required String password,
  }) =>
      post(ApiEndpoints.adminLogin, body: {
        'email': email,
        'password': password,
      }) as Future<Map<String, dynamic>>;

  Future<Map<String, dynamic>> verifyMfa({
    required String sessionToken,
    required String code,
  }) =>
      post(ApiEndpoints.verifyMfa, body: {
        'sessionToken': sessionToken,
        'code': code,
      }) as Future<Map<String, dynamic>>;

  Future<Map<String, dynamic>> refreshToken({
    required String refreshToken,
  }) =>
      post(ApiEndpoints.refreshToken, body: {
        'refreshToken': refreshToken,
      }) as Future<Map<String, dynamic>>;

  // --- Services & Staff ---

  Future<List<dynamic>> getServices() async {
    final response = await get(ApiEndpoints.services);
    return response['data'] as List<dynamic>? ?? response as List<dynamic>;
  }

  Future<List<dynamic>> getStaff() async {
    final response = await get(ApiEndpoints.staff);
    return response['data'] as List<dynamic>? ?? response as List<dynamic>;
  }

  Future<Map<String, dynamic>> getStaffAvailability(String staffId) =>
      get(ApiEndpoints.staffAvailability(staffId))
          as Future<Map<String, dynamic>>;

  // --- Bookings ---

  Future<Map<String, dynamic>> createBooking(
    Map<String, dynamic> bookingData,
  ) =>
      post(ApiEndpoints.bookings, body: bookingData)
          as Future<Map<String, dynamic>>;

  Future<Map<String, dynamic>> getBooking(String id) =>
      get(ApiEndpoints.booking(id)) as Future<Map<String, dynamic>>;

  Future<Map<String, dynamic>> updateBooking(
    String id,
    Map<String, dynamic> data,
  ) =>
      put(ApiEndpoints.booking(id), body: data)
          as Future<Map<String, dynamic>>;

  Future<List<dynamic>> getCustomerBookings(String customerId) async {
    final response = await get(ApiEndpoints.customerBookings(customerId));
    return response['data'] as List<dynamic>? ?? response as List<dynamic>;
  }

  // --- Reviews ---

  Future<Map<String, dynamic>> createReview(
    Map<String, dynamic> reviewData,
  ) =>
      post(ApiEndpoints.reviews, body: reviewData)
          as Future<Map<String, dynamic>>;

  Future<List<dynamic>> getReviews({Map<String, String>? filters}) async {
    final response = await get(ApiEndpoints.reviews, queryParams: filters);
    return response['data'] as List<dynamic>? ?? response as List<dynamic>;
  }

  // --- Admin endpoints ---

  Future<Map<String, dynamic>> getAdminDashboard() =>
      get(ApiEndpoints.adminDashboard, isAdmin: true)
          as Future<Map<String, dynamic>>;

  Future<List<dynamic>> getAdminBookings({
    Map<String, String>? filters,
  }) async {
    final response =
        await get(ApiEndpoints.adminBookings, queryParams: filters, isAdmin: true);
    return response['data'] as List<dynamic>? ?? response as List<dynamic>;
  }

  Future<Map<String, dynamic>> updateAdminBooking(
    String id,
    Map<String, dynamic> data,
  ) =>
      put(ApiEndpoints.adminBooking(id), body: data, isAdmin: true)
          as Future<Map<String, dynamic>>;

  Future<List<dynamic>> getAdminCustomers({
    Map<String, String>? filters,
  }) async {
    final response =
        await get(ApiEndpoints.adminCustomers, queryParams: filters, isAdmin: true);
    return response['data'] as List<dynamic>? ?? response as List<dynamic>;
  }

  Future<Map<String, dynamic>> getAdminAnalytics() =>
      get(ApiEndpoints.adminAnalytics, isAdmin: true)
          as Future<Map<String, dynamic>>;

  Future<Map<String, dynamic>> getFirebaseConfig() =>
      get(ApiEndpoints.firebaseConfig) as Future<Map<String, dynamic>>;

  Future<List<dynamic>> getAdminReviews({
    Map<String, String>? filters,
  }) async {
    final response =
        await get(ApiEndpoints.adminReviews, queryParams: filters, isAdmin: true);
    return response['data'] as List<dynamic>? ?? response as List<dynamic>;
  }

  Future<Map<String, dynamic>> respondToReview(
    String reviewId,
    String response,
  ) =>
      put('${ApiEndpoints.adminReviews}/$reviewId', body: {
        'adminResponse': response,
      }, isAdmin: true) as Future<Map<String, dynamic>>;
}
