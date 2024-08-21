import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferenceHelper {
  static const String userIdKey = "USERKEY";
  static const String userNameKey = "USERNAMEKEY";
  static const String userEmailKey = "USEREMAILKEY";
  static const String userPicKey = "USERPICKEY";
  static const String userDisplayNameKey = "USERDISPLAYNAMEKEY";

  Future<SharedPreferences> _getPrefs() async {
    return await SharedPreferences.getInstance();
  }

  Future<bool> _saveValue(String key, String value) async {
    final prefs = await _getPrefs();
    return prefs.setString(key, value);
  }

  Future<String?> _getValue(String key) async {
    final prefs = await _getPrefs();
    return prefs.getString(key);
  }

  Future<bool> saveUserId(String userId) => _saveValue(userIdKey, userId);
  Future<bool> saveUserName(String userName) =>
      _saveValue(userNameKey, userName);
  Future<bool> saveUserEmail(String userEmail) =>
      _saveValue(userEmailKey, userEmail);
  Future<bool> saveUserPic(String userPic) => _saveValue(userPicKey, userPic);
  Future<bool> saveUserDisplayName(String userDisplayName) =>
      _saveValue(userDisplayNameKey, userDisplayName);

  Future<String?> getUserId() => _getValue(userIdKey);
  Future<String?> getUserName() => _getValue(userNameKey);
  Future<String?> getUserEmail() => _getValue(userEmailKey);
  Future<String?> getUserPic() => _getValue(userPicKey);
  Future<String?> getUserDisplayName() => _getValue(userDisplayNameKey);

  Future<void> clearCurrentUserData() async {
    final prefs = await _getPrefs();
    await prefs.remove(userIdKey);
    await prefs.remove(userNameKey);
    await prefs.remove(userEmailKey);
    await prefs.remove(userPicKey);
    await prefs.remove(userDisplayNameKey);
  }
}
