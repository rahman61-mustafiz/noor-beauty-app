import 'package:flutter/foundation.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:totp/totp.dart';

import '../models/admin_user.dart';
import '../models/user.dart';
import '../utils/constants.dart';
import 'api_service.dart';
import 'storage_service.dart';

class AuthService extends ChangeNotifier {
  final ApiService _api = ApiService.instance;
  StorageService? _storage;

  User? _currentUser;
  AdminUser? _currentAdmin;
  String? _mfaSessionToken;
  String? _pendingMfaSecret;
  bool _isLoading = false;
  String? _error;

  User? get currentUser => _currentUser;
  AdminUser? get currentAdmin => _currentAdmin;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isLoggedIn => _currentUser != null;
  bool get isAdminLoggedIn => _currentAdmin != null;
  String? get mfaSessionToken => _mfaSessionToken;

  Future<void> init() async {
    _storage = await StorageService.getInstance();
    final token = _storage!.getAccessToken();
    if (token != null && !JwtDecoder.isExpired(token)) {
      _api.setAccessToken(token);
      _currentUser = User(
        id: _storage!.getUserId() ?? '',
        name: _storage!.getUserName() ?? '',
        email: _storage!.getUserEmail() ?? '',
        phone: '',
        createdAt: DateTime.now(),
        emailVerified: true,
      );
    }

    if (_storage!.getIsAdmin() && _storage!.isAdminLoggedIn) {
      final adminToken = _storage!.getAdminToken();
      if (adminToken != null) {
        _api.setAdminToken(adminToken);
        _currentAdmin = AdminUser(
          id: 'admin',
          email: _storage!.getUserEmail() ?? '',
          mfaEnabled: true,
          createdAt: DateTime.now(),
        );
      }
    }
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// Refresh JWT if within threshold of expiry.
  Future<bool> refreshTokenIfNeeded() async {
    final token = _storage?.getAccessToken();
    if (token == null) return false;

    if (!JwtDecoder.isExpired(token)) {
      final expiry = JwtDecoder.getExpirationDate(token);
      final minutesLeft = expiry.difference(DateTime.now()).inMinutes;
      if (minutesLeft > AppConstants.jwtRefreshThresholdMinutes) {
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

  Future<bool> register({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) async {
    _setLoading(true);
    _error = null;
    try {
      await _api.register(
        name: name,
        email: email,
        phone: phone,
        password: password,
      );
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> login({
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    _error = null;
    try {
      final response = await _api.login(email: email, password: password);
      await _saveCustomerSession(response);
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> _saveCustomerSession(Map<String, dynamic> response) async {
    final accessToken = response['accessToken'] as String;
    final refreshToken = response['refreshToken'] as String?;
    final userData = response['user'] as Map<String, dynamic>? ?? response;

    await _storage!.saveAccessToken(accessToken);
    if (refreshToken != null) {
      await _storage!.saveRefreshToken(refreshToken);
    }
    _api.setAccessToken(accessToken);

    _currentUser = User.fromJson(userData);
    await _storage!.saveUserData(
      userId: _currentUser!.id,
      name: _currentUser!.name,
      email: _currentUser!.email,
    );
    notifyListeners();
  }

  Future<bool> verifyEmail({
    required String email,
    required String code,
  }) async {
    _setLoading(true);
    _error = null;
    try {
      final response = await _api.verifyEmail(email: email, code: code);
      if (response['accessToken'] != null) {
        await _saveCustomerSession(response);
      }
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> passwordReset({required String email}) async {
    _setLoading(true);
    _error = null;
    try {
      await _api.passwordReset(email: email);
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> adminLogin({
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    _error = null;
    try {
      final response = await _api.adminLogin(email: email, password: password);
      _mfaSessionToken = response['sessionToken'] as String?;
      _pendingMfaSecret = response['mfaSecret'] as String?;
      _currentAdmin = AdminUser.fromJson(
        response['admin'] as Map<String, dynamic>? ?? {'email': email},
      );
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Verify TOTP code for admin MFA using the totp package.
  bool verifyTotpLocally(String secret, String code) {
    try {
      final generated = Totp.generateTOTPCodeString(
        secret,
        DateTime.now().millisecondsSinceEpoch,
        algorithm: Algorithm.SHA1,
        isGoogle: true,
        length: 6,
        interval: 30,
      );
      return generated == code.trim();
    } catch (_) {
      return false;
    }
  }

  Future<bool> verifyMfa({required String code}) async {
    _setLoading(true);
    _error = null;
    try {
      if (_mfaSessionToken == null) {
        _error = 'MFA session expired. Please login again.';
        return false;
      }

      final response = await _api.verifyMfa(
        sessionToken: _mfaSessionToken!,
        code: code,
      );

      final adminToken = response['accessToken'] as String? ??
          response['adminToken'] as String?;
      if (adminToken == null) {
        _error = 'MFA verification failed';
        return false;
      }

      await _storage!.saveAdminToken(adminToken);
      await _storage!.setIsAdmin(true);
      await _storage!.updateAdminLastActivity();
      _api.setAdminToken(adminToken);

      _currentAdmin = AdminUser.fromJson(
        response['admin'] as Map<String, dynamic>? ??
            {'email': _currentAdmin?.email ?? ''},
      );
      _mfaSessionToken = null;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Generate otpauth URI for QR code display during MFA setup.
  String generateMfaQrUri({
    required String secret,
    required String email,
  }) {
    final issuer = Uri.encodeComponent(AppConstants.appName);
    final account = Uri.encodeComponent(email);
    return 'otpauth://totp/$issuer:$account?secret=$secret&issuer=$issuer&algorithm=SHA1&digits=6&period=30';
  }

  String? get pendingMfaSecret => _pendingMfaSecret;

  /// Check and enforce 30-minute admin session timeout.
  bool checkAdminSession() {
    if (_storage == null) return false;
    if (_storage!.isAdminSessionExpired()) {
      adminLogout();
      return false;
    }
    _storage!.updateAdminLastActivity();
    return true;
  }

  Future<void> logout() async {
    await _storage?.clearCustomerSession();
    _api.setAccessToken(null);
    _currentUser = null;
    notifyListeners();
  }

  Future<void> adminLogout() async {
    await _storage?.clearAdminSession();
    _api.setAdminToken(null);
    _currentAdmin = null;
    _mfaSessionToken = null;
    notifyListeners();
  }
}
