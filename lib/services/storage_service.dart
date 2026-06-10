import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../utils/constants.dart';

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

  // --- User data ---

  Future<void> saveUserData({
    required String userId,
    required String name,
    String? phone,
    String? email,
  }) async {
    await _prefs.setString(StorageKeys.userId, userId);
    await _prefs.setString(StorageKeys.userName, name);
    if (phone != null) await _prefs.setString('user_phone', phone);
    if (email != null) await _prefs.setString(StorageKeys.userEmail, email);
  }

  String? getUserId()    => _prefs.getString(StorageKeys.userId);
  String? getUserName()  => _prefs.getString(StorageKeys.userName);
  String? getUserPhone() => _prefs.getString('user_phone');
  String? getUserEmail() => _prefs.getString(StorageKeys.userEmail);

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

  // --- Generic JSON ---

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
  }

  Future<void> clearAll() async {
    await _prefs.clear();
  }

  bool get isLoggedIn => getAccessToken() != null;
}
