import 'package:flutter/foundation.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

import '../models/user.dart';
import '../utils/constants.dart';
import 'api_service.dart';
import 'storage_service.dart';

class OtpResult {
  final bool success;
  final bool isNewUser;

  const OtpResult({required this.success, required this.isNewUser});
}

class AuthService extends ChangeNotifier {
  final ApiService _api = ApiService.instance;
  StorageService? _storage;

  User? _currentUser;
  bool _isLoading = false;
  String? _error;

  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isLoggedIn => _currentUser != null;

  /// The display name remembered locally on this device (from a previous
  /// sign-in). Empty when nothing has been saved yet.
  String get cachedName => _storage?.getUserName() ?? '';

  Future<void> init() async {
    _storage = await StorageService.getInstance();
    final token = _storage!.getAccessToken();
    if (token != null && !JwtDecoder.isExpired(token)) {
      _api.setAccessToken(token);
      _currentUser = User(
        id: _storage!.getUserId() ?? '',
        name: _storage!.getUserName() ?? '',
        phone: _storage!.getUserPhone() ?? '',
        createdAt: DateTime.now(),
      );
    }
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  /// Step 1: POST /auth/request-otp
  Future<bool> requestOtp(String phone) async {
    _setLoading(true);
    _error = null;
    try {
      await _api.requestOtp(phone);
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      return false;
    } catch (_) {
      _error = 'Network error. Please check your connection and try again.';
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Step 2: POST /auth/verify-otp — saves session token on success.
  Future<OtpResult> verifyOtp(String phone, String code) async {
    _setLoading(true);
    _error = null;
    try {
      final response = await _api.verifyOtp(phone: phone, code: code);
      await _saveSession(response);
      final isNew = response['isNewUser'] as bool? ?? false;
      return OtpResult(success: true, isNewUser: isNew);
    } on ApiException catch (e) {
      _error = e.message;
      return const OtpResult(success: false, isNewUser: false);
    } catch (_) {
      _error = 'Network error. Please check your connection and try again.';
      return const OtpResult(success: false, isNewUser: false);
    } finally {
      _setLoading(false);
    }
  }

  /// First-time users: save display name after OTP verification.
  Future<void> saveName(String name) async {
    if (_currentUser == null) return;
    _currentUser = _currentUser!.copyWith(name: name);
    await _storage!.saveUserData(
      userId: _currentUser!.id,
      name: name,
      phone: _currentUser!.phone,
    );
    notifyListeners();
    try {
      await _api.updateProfile({'name': name});
    } catch (_) {}
  }

  Future<bool> refreshTokenIfNeeded() async {
    final token = _storage?.getAccessToken();
    if (token == null) return false;

    if (!JwtDecoder.isExpired(token)) {
      final expiry = JwtDecoder.getExpirationDate(token);
      if (expiry.difference(DateTime.now()).inMinutes >
          AppConstants.jwtRefreshThresholdMinutes) {
        return true;
      }
    }

    final refresh = _storage?.getRefreshToken();
    if (refresh == null) return false;

    try {
      final response = await _api.refreshToken(refreshToken: refresh);
      final newAccess = response['accessToken'] as String?;
      final newRefresh = response['refreshToken'] as String?;
      if (newAccess != null) {
        await _storage!.saveAccessToken(newAccess);
        _api.setAccessToken(newAccess);
        if (newRefresh != null) {
          await _storage!.saveRefreshToken(newRefresh);
        }
        return true;
      }
    } catch (_) {
      await logout();
    }
    return false;
  }

  /// DELETE /auth/account — clears local session only after server confirms.
  Future<bool> deleteAccount() async {
    _setLoading(true);
    _error = null;
    try {
      await _api.deleteAccount();
      await logout(clearProfileData: true);
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      return false;
    } catch (_) {
      _error = 'Could not delete account. Please try again.';
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> logout({bool clearProfileData = false}) async {
    await _storage?.clearCustomerSession(clearProfileData: clearProfileData);
    _api.setAccessToken(null);
    _currentUser = null;
    notifyListeners();
  }

  Future<void> _saveSession(Map<String, dynamic> response) async {
    final accessToken = response['accessToken'] as String? ??
        response['token'] as String? ??
        '';
    final refreshToken = response['refreshToken'] as String?;
    final userData =
        response['user'] as Map<String, dynamic>? ?? response;

    if (accessToken.isEmpty) {
      throw const ApiException('No session token received from server');
    }

    await _storage!.saveAccessToken(accessToken);
    _api.setAccessToken(accessToken);
    if (refreshToken != null) {
      await _storage!.saveRefreshToken(refreshToken);
    }

    _currentUser = User.fromJson(userData);

    // App-only persistence: if the server didn't return a name (common when
    // the backend doesn't store it), fall back to the name we cached locally
    // on a previous sign-in so the user doesn't have to retype it.
    if (_currentUser!.name.trim().isEmpty) {
      final cached = _storage!.getUserName();
      if (cached != null && cached.trim().isNotEmpty) {
        _currentUser = _currentUser!.copyWith(name: cached);
      }
    }

    await _storage!.saveUserData(
      userId: _currentUser!.id,
      name: _currentUser!.name,
      phone: _currentUser!.phone,
      email: _currentUser!.email,
    );
    notifyListeners();
  }
}
