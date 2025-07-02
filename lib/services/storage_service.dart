import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class StorageService {
  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'user_data';
  static const String _selectedAccountIdKey = 'selected_account_id';
  static const String _sharedUsersKey = 'shared_users';
  static const String _rememberLoginKey = 'remember_login';

  late SharedPreferences _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Authentication token management
  Future<void> saveToken(String token) async {
    await _prefs.setString(_tokenKey, token);
  }

  Future<String?> getToken() async {
    return _prefs.getString(_tokenKey);
  }

  Future<void> clearToken() async {
    await _prefs.remove(_tokenKey);
  }

  // User data management
  Future<void> saveUserData(Map<String, dynamic> userData) async {
    await _prefs.setString(_userKey, jsonEncode(userData));
  }

  Future<Map<String, dynamic>?> getUserData() async {
    final userString = _prefs.getString(_userKey);
    if (userString != null) {
      return jsonDecode(userString) as Map<String, dynamic>;
    }
    return null;
  }

  Future<void> clearUserData() async {
    await _prefs.remove(_userKey);
  }

  // Selected account ID management
  Future<void> saveSelectedAccountId(String accountId) async {
    await _prefs.setString(_selectedAccountIdKey, accountId);
  }

  Future<String?> getSelectedAccountId() async {
    return _prefs.getString(_selectedAccountIdKey);
  }

  Future<void> clearSelectedAccountId() async {
    await _prefs.remove(_selectedAccountIdKey);
  }

  // Shared users management
  Future<void> saveSharedUsers(List<Map<String, dynamic>> sharedUsers) async {
    await _prefs.setString(_sharedUsersKey, jsonEncode(sharedUsers));
  }

  Future<List<Map<String, dynamic>>?> getSharedUsers() async {
    final sharedUsersString = _prefs.getString(_sharedUsersKey);
    if (sharedUsersString != null) {
      final List<dynamic> decoded = jsonDecode(sharedUsersString);
      return decoded.cast<Map<String, dynamic>>();
    }
    return null;
  }

  Future<void> clearSharedUsers() async {
    await _prefs.remove(_sharedUsersKey);
  }

  // Remember login preference
  Future<void> setRememberLogin(bool remember) async {
    await _prefs.setBool(_rememberLoginKey, remember);
  }

  Future<bool> getRememberLogin() async {
    return _prefs.getBool(_rememberLoginKey) ?? false;
  }

  // Check if user is logged in
  Future<bool> isLoggedIn() async {
    final token = await getToken();
    final userData = await getUserData();
    return token != null && userData != null;
  }

  // Clear all stored data (logout)
  Future<void> clearAll() async {
    await Future.wait([
      clearToken(),
      clearUserData(),
      clearSelectedAccountId(),
      clearSharedUsers(),
    ]);
  }

  // Generic storage methods
  Future<void> saveString(String key, String value) async {
    await _prefs.setString(key, value);
  }

  Future<String?> getString(String key) async {
    return _prefs.getString(key);
  }

  Future<void> saveBool(String key, bool value) async {
    await _prefs.setBool(key, value);
  }

  Future<bool?> getBool(String key) async {
    return _prefs.getBool(key);
  }

  Future<void> saveInt(String key, int value) async {
    await _prefs.setInt(key, value);
  }

  Future<int?> getInt(String key) async {
    return _prefs.getInt(key);
  }

  Future<void> removeKey(String key) async {
    await _prefs.remove(key);
  }

  Future<bool> containsKey(String key) async {
    return _prefs.containsKey(key);
  }
}