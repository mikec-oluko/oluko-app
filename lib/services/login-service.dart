import 'dart:convert';

import 'package:oluko_app/models/sign-up-response.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginService {
  static Future<bool> storeLoginData(SignUpResponse signUpResponse) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String encodedJson = jsonEncode(signUpResponse);
    bool loginSaved = await prefs.setString('login-data', encodedJson);
    print('Saved login info.');
    return loginSaved;
  }

  static Future<SignUpResponse> retrieveLoginData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String savedData = prefs.getString('login-data');
    dynamic decodedJson = jsonDecode(savedData);
    SignUpResponse signUpResponse = SignUpResponse.fromJson(decodedJson);
    print('Retrieved login info.');
    return signUpResponse;
  }
}
