import 'dart:convert';
import 'package:oluko_app/models/user-response.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginService {
  static Future<bool> storeLoginData(UserResponse signUpResponse) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String encodedJson = jsonEncode(signUpResponse);
    bool loginSaved = await prefs.setString('login-data', encodedJson);
    print('Saved login info.');
    return loginSaved;
  }

  static Future<UserResponse> retrieveLoginData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String savedData = prefs.getString('login-data');
    if (savedData == null) {
      return null;
    }
    dynamic decodedJson = jsonDecode(savedData);
    UserResponse signUpResponse = UserResponse.fromJson(decodedJson);
    print('Retrieved login info.');
    return signUpResponse;
  }

  static Future<bool> removeLoginData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    Future<bool> removed = prefs.remove('login-data');
    print('Removed login info.');
    return removed;
  }

  static isLoggedIn() async {
    UserResponse loginData = await retrieveLoginData();
    return loginData != null;
  }
}
