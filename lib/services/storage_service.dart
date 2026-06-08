import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../utils/constants.dart';

/// Secure local storage wrapper using SharedPreferences.
/// Tokens and sensitive data are stored with prefixed keys.
class StorageService {
  static StorageService? _instance;
  late SharedPreferences _prefs;

  StorageService._();

  static Future<StorageService> getInstance() async {
    if (_instance == null) {
      final service = StorageService._();
      service._prefs = await SharedPreferences.getInstance();
      _instance = service;
    }
    return _instance!;
  }

  // --- Auth tokens ---

  Future<void> saveAccessToken(String token) async {
    await _prefs.setString(StorageKeys.accessToken, token);
  }

  String? getAccessToken() => _prefs.getString(StorageKeys.accessToken);

  Future<void> saveRefreshToken(String token) async {
    await _prefs.setString(StorageKeys.refreshToken, token);
  }

  String? getRefreshToken() => _prefs.getString(StorageKeys.refreshToken);

  Future<void> saveAdminToken(String token) async {
    await _prefs.setString(StorageKeys.adminToken, token);
  }

  String? getAdminToken() => _prefs.getString(StorageKeys.adminToken);

  // --- User data ---

  Future<void> saveUserData({
    required String userId,
    required String name,
    required String email,
  }) async {
    await _prefs.setString(StorageKeys.userId, userId);
    await _prefs.setString(StorageKeys.userName, name);
    await _prefs.setString(StorageKeys.userEmail, email);
  }

  String? getUserId() => _prefs.getString(StorageKeys.userId);
  String? getUserName() => _prefs.getString(StorageKeys.userName);
  String? getUserEmail() => _prefs.getString(StorageKeys.userEmail);

  Future<void> setIsAdmin(bool value) async {
    await _prefs.setBool(StorageKeys.isAdmin, value);
  }

  bool getIsAdmin() => _prefs.getBool(StorageKeys.isAdmin) ?? false;

  // --- Admin session ---

  Future<void> updateAdminLastActivity() async {
    await _prefs.setString(
      StorageKeys.adminLastActivity,
      DateTime.now().toIso8601String(),
    );
  }

  DateTime? getAdminLastActivity() {
    final value = _prefs.getString(StorageKeys.adminLastActivity);
    if (value == null) return null;
    return DateTime.tryParse(value);
  }

  bool isAdminSessionExpired() {
    final lastActivity = getAdminLastActivity();
    if (lastActivity == null) return true;
    final elapsed = DateTime.now().difference(lastActivity);
    return elapsed.inMinutes >= AppConstants.adminSessionTimeoutMinutes;
  }

  // --- Favorites ---

  Future<void> saveFavoriteStylists(List<String> stylistIds) async {
    await _prefs.setStringList(StorageKeys.favoriteStylists, stylistIds);
  }

  List<String> getFavoriteStylists() {
    return _prefs.getStringList(StorageKeys.favoriteStylists) ?? [];
  }

  Future<void> toggleFavoriteStylist(String stylistId) async {
    final favorites = getFavoriteStylists();
    if (favorites.contains(stylistId)) {
      favorites.remove(stylistId);
    } else {
      favorites.add(stylistId);
    }
    await saveFavoriteStylists(favorites);
  }

  bool isFavoriteStylist(String stylistId) {
    return getFavoriteStylists().contains(stylistId);
  }

  // --- FCM ---

  Future<void> saveFcmToken(String token) async {
    await _prefs.setString(StorageKeys.fcmToken, token);
  }

  String? getFcmToken() => _prefs.getString(StorageKeys.fcmToken);

  // --- Theme ---

  Future<void> setDarkMode(bool value) async {
    await _prefs.setBool(StorageKeys.darkMode, value);
  }

  bool getDarkMode() => _prefs.getBool(StorageKeys.darkMode) ?? false;

  // --- Generic JSON storage ---

  Future<void> saveJson(String key, Map<String, dynamic> data) async {
    await _prefs.setString(key, jsonEncode(data));
  }

  Map<String, dynamic>? getJson(String key) {
    final value = _prefs.getString(key);
    if (value == null) return null;
    return jsonDecode(value) as Map<String, dynamic>;
  }

  // --- Clear ---

  Future<void> clearCustomerSession() async {
    await _prefs.remove(StorageKeys.accessToken);
    await _prefs.remove(StorageKeys.refreshToken);
    await _prefs.remove(StorageKeys.userId);
    await _prefs.remove(StorageKeys.userName);
    await _prefs.remove(StorageKeys.userEmail);
    await _prefs.setBool(StorageKeys.isAdmin, false);
  }

  Future<void> clearAdminSession() async {
    await _prefs.remove(StorageKeys.adminToken);
    await _prefs.remove(StorageKeys.adminLastActivity);
    await _prefs.setBool(StorageKeys.isAdmin, false);
  }

  Future<void> clearAll() async {
    await _prefs.clear();
  }

  bool get isLoggedIn => getAccessToken() != null;
  bool get isAdminLoggedIn => getAdminToken() != null && !isAdminSessionExpired();
}
