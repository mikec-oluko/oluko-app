import 'dart:convert';

import 'package:http/http.dart';
import 'package:oluko_app/models/api-response.dart';
import 'package:oluko_app/models/login-request.dart';
import 'package:http/http.dart' as http;

class LoginProvider {
  Future<ApiResponse> login(LoginRequest loginRequest) async {
    var body2 = loginRequest.toJson();
    Response response = await http.post(
        Uri.parse(
            "https://us-central1-oluko-2671e.cloudfunctions.net/auth/login"),
        body: body2);
    var signUpResponseBody = jsonDecode(response.body);
    ApiResponse apiResponse = ApiResponse.fromJson(signUpResponseBody);
    return apiResponse;
  }
}
