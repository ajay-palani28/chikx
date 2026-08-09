import 'package:shared_preferences/shared_preferences.dart';

setToken(String token) async {
  final prefs = await SharedPreferences.getInstance();
  prefs.setString('token', token);
}

setUserId(String userId) async {
  final prefs = await SharedPreferences.getInstance();
  prefs.setString('userId', userId);
}

Future<String?> getUserId() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString('userId');
}

setIsAdmin(bool isAdmin) async {
  final prefs = await SharedPreferences.getInstance();
  prefs.setBool('isAdmin', isAdmin);
}

// Remember Me Functionality
setRememberMe(bool value) async {
  final prefs = await SharedPreferences.getInstance();
  prefs.setBool('rememberMe', value);
}

Future<bool> getRememberMe() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getBool('rememberMe') ?? false;
}

setRememberedPhone(String phone) async {
  final prefs = await SharedPreferences.getInstance();
  prefs.setString('rem_phone', phone);
}

Future<String?> getRememberedPhone() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString('rem_phone');
}

setRememberedPassword(String password) async {
  final prefs = await SharedPreferences.getInstance();
  prefs.setString('rem_password', password);
}

Future<String?> getRememberedPassword() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString('rem_password');
}

clearRememberedCredentials() async {
  final prefs = await SharedPreferences.getInstance();
  prefs.remove('rem_phone');
  prefs.remove('rem_password');
  prefs.remove('rememberMe');
}
