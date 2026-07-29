import 'package:shared_preferences/shared_preferences.dart';

setToken(String token)async{
  final prefs= await SharedPreferences.getInstance();
  prefs.setString('token', token);
}

setUserId(String userId)async{
  final prefs= await SharedPreferences.getInstance();
  prefs.setString('userId', userId);
}

Future<String?> getUserId() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString('userId');
}

setIsAdmin(bool isAdmin)async{
  final prefs= await SharedPreferences.getInstance();
  prefs.setBool('isAdmin', isAdmin);
}
