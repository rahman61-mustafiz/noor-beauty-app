import 'package:flutter/foundation.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

import '../models/user.dart';
import '../utils/constants.dart';
import 'api_service.dart';
import 'storage_service.dart';

class OtpResult {
  final bool success;
  final bool isNewUser;
  OtpResult({required this.success, required this.isNewUser});
}

class AuthService extends ChangeNotifier {
  final ApiService _api = ApiService.instance;
  StorageService? _storage;

  User? _currentUser;
  bool _isLoading = false;
  String? _error;

  User?   get currentUser => _currentUser;
  bool    get isLoading   => _isLoading;
  String? get error       => _error;
  bool    get isLoggedIn  => _currentUser != null;

  Future<void> init() async {
    _storage = await StorageService.getInstance();
    final token = _storage!.getAccessToken();
    if (token != null && !JwtDecoder.isExpired(token)) {
      _api.setAccessToken(token);
      _currentUser = User(
        id:        _storage!.getUserId()   ?? '',
        name:      _storage!.getUserName() ?? '',
        phone:     _storage!.getUserPhone() ?? '',
        createdAt: DateTime.now(),
      );
    }
    notifyListeners();
  }

  void _setLoading(bool v) { _isLoading = v; notifyListeners(); }
  void clearError() { _error = null; notifyListeners(); }

  // ── OTP auth ────────────────────────────────────────────────────────────────

  /// Step 1: request an OTP to be sent to [phone] (international format).
  /// Returns true even when the server is unreachable so the UI flow continues.
  Future<bool> requestOtp(String phone) async {
    _setLoading(true);
    _error = null;
    try {
      await _api.requestOtp(phone);
      return true;
    } catch (e) {
      if (e is ApiException) {
        _error = e.message;
        return false;
      }
      // Server unreachable → demo mode: let the UI proceed
      return true;
    } finally {
      _setLoading(false);
    }
  }

  /// Step 2: verify the OTP code.
  /// Returns [OtpResult] with success flag and whether this is a brand-new user.
  Future<OtpResult> verifyOtp(String phone, String code) async {
    _setLoading(true);
    _error = null;
    try {
      final response = await _api.verifyOtp(phone: phone, code: code);
      await _saveSession(response);
      final isNew = response['isNewUser'] as bool? ?? false;
      return OtpResult(success: true, isNewUser: isNew);
    } catch (e) {
      if (e is ApiException) {
        _error = e.message;
        return OtpResult(success: false, isNewUser: false);
      }
      // Server unreachable → demo mode: create a local session
      final demoId = 'demo-${phone.replaceAll(RegExp(r'[^0-9]'), '')}';
      _currentUser = User(id: demoId, name: '', phone: phone, createdAt: DateTime.now());
      await _storage!.saveUserData(userId: demoId, name: '', phone: phone);
      notifyListeners();
      return OtpResult(success: true, isNewUser: true);
    } finally {
      _setLoading(false);
    }
  }

  /// Step 3 (first-time only): save the user's name.
  Future<void> saveName(String name) async {
    if (_currentUser == null) return;
    _currentUser = _currentUser!.copyWith(name: name);
    await _storage!.saveUserData(
      userId: _currentUser!.id,
      name:   name,
      phone:  _currentUser!.phone,
    );
    notifyListeners();
    _api.updateProfile({'name': name}).catchError((_) => <String, dynamic>{});
  }

  // ── Token refresh ─────────────────────────────────────────────────────────

  Future<bool> refreshTokenIfNeeded() async {
    final token = _storage?.getAccessToken();
    if (token == null) return false;
    if (!JwtDecoder.isExpired(token)) {
      final expiry = JwtDecoder.getExpirationDate(token);
      if (expiry.difference(DateTime.now()).inMinutes > AppConstants.jwtRefreshThresholdMinutes) {
        return true;
      }
    }
    final refresh = _storage?.getRefreshToken();
    if (refresh == null) return false;
    try {
      final response = await _api.refreshToken(refreshToken: refresh);
      final newAccess  = response['accessToken'] as String?;
      final newRefresh = response['refreshToken'] as String?;
      if (newAccess != null) {
        await _storage!.saveAccessToken(newAccess);
        _api.setAccessToken(newAccess);
        if (newRefresh != null) await _storage!.saveRefreshToken(newRefresh);
        return true;
      }
    } catch (_) {
      await logout();
    }
    return false;
  }

  // ── Account deletion ──────────────────────────────────────────────────────

  Future<bool> deleteAccount() async {
    _setLoading(true);
    try {
      await _api.deleteAccount();
    } catch (_) {}
    await logout();
    return true;
  }

  // ── Logout ────────────────────────────────────────────────────────────────

  Future<void> logout() async {
    await _storage?.clearCustomerSession();
    _api.setAccessToken(null);
    _currentUser = null;
    notifyListeners();
  }

  // ── Private helpers ───────────────────────────────────────────────────────

  Future<void> _saveSession(Map<String, dynamic> response) async {
    final accessToken  = response['accessToken'] as String? ?? response['token'] as String? ?? '';
    final refreshToken = response['refreshToken'] as String?;
    final userData     = response['user'] as Map<String, dynamic>? ?? response;

    if (accessToken.isNotEmpty) {
      await _storage!.saveAccessToken(accessToken);
      _api.setAccessToken(accessToken);
    }
    if (refreshToken != null) await _storage!.saveRefreshToken(refreshToken);

    _currentUser = User.fromJson(userData);
    await _storage!.saveUserData(
      userId: _currentUser!.id,
      name:   _currentUser!.name,
      phone:  _currentUser!.phone,
      email:  _currentUser!.email,
    );
    notifyListeners();
  }
}
