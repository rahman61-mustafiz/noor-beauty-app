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

  ApiService._();

  static ApiService get instance {
    _instance ??= ApiService._();
    return _instance!;
  }

  void setAccessToken(String? token) => _accessToken = token;

  String get baseUrl => AppConstants.apiBaseUrl;

  Map<String, String> _headers() {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (_accessToken != null) {
      headers['Authorization'] = 'Bearer $_accessToken';
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

  Future<dynamic> get(String endpoint, {Map<String, String>? queryParams}) async {
    var uri = Uri.parse('$baseUrl$endpoint');
    if (queryParams != null && queryParams.isNotEmpty) {
      uri = uri.replace(queryParameters: queryParams);
    }
    try {
      final response = await http
          .get(uri, headers: _headers())
          .timeout(const Duration(seconds: 30));
      return _handleResponse(response);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('Network error: ${e.toString()}');
    }
  }

  Future<dynamic> post(String endpoint, {Map<String, dynamic>? body}) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl$endpoint'),
            headers: _headers(),
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

  Future<dynamic> put(String endpoint, {Map<String, dynamic>? body}) async {
    try {
      final response = await http
          .put(
            Uri.parse('$baseUrl$endpoint'),
            headers: _headers(),
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

  Future<dynamic> delete(String endpoint) async {
    try {
      final response = await http
          .delete(Uri.parse('$baseUrl$endpoint'), headers: _headers())
          .timeout(const Duration(seconds: 30));
      return _handleResponse(response);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('Network error: ${e.toString()}');
    }
  }

  // --- Auth endpoints ---

  Future<void> requestOtp(String phone) async {
    await post(ApiEndpoints.requestOtp, body: {'phone': phone});
  }

  Future<Map<String, dynamic>> verifyOtp({
    required String phone,
    required String code,
  }) async {
    final result = await post(
      ApiEndpoints.verifyOtp,
      body: {'phone': phone, 'code': code, 'otp': code},
    );
    return result as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> refreshToken({required String refreshToken}) async {
    final result = await post(ApiEndpoints.refreshToken, body: {'refreshToken': refreshToken});
    return result as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> updateProfile(Map<String, dynamic> data) async {
    final result = await put(ApiEndpoints.profile, body: data);
    return result as Map<String, dynamic>;
  }

  Future<void> deleteAccount() async {
    await delete(ApiEndpoints.deleteAccount);
  }

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

  Future<Map<String, dynamic>> createBooking(Map<String, dynamic> bookingData) async {
    final result = await post(ApiEndpoints.bookings, body: bookingData);
    return result as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> getBooking(String id) async {
    final result = await get(ApiEndpoints.booking(id));
    return result as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> updateBooking(String id, Map<String, dynamic> data) async {
    final result = await put(ApiEndpoints.booking(id), body: data);
    return result as Map<String, dynamic>;
  }

  Future<List<dynamic>> getCustomerBookings(String customerId) async {
    final response = await get(ApiEndpoints.customerBookings(customerId));
    return response['data'] as List<dynamic>? ?? response as List<dynamic>;
  }

  // --- Reviews ---

  Future<Map<String, dynamic>> createReview(Map<String, dynamic> reviewData) async {
    final result = await post(ApiEndpoints.reviews, body: reviewData);
    return result as Map<String, dynamic>;
  }

  Future<List<dynamic>> getReviews({Map<String, String>? filters}) async {
    final response = await get(ApiEndpoints.reviews, queryParams: filters);
    return response['data'] as List<dynamic>? ?? response as List<dynamic>;
  }
}
