import 'dart:convert';

import 'package:http/http.dart';
import 'package:oluko_app/models/api-response.dart';
import 'package:oluko_app/models/login-request.dart';
import 'package:http/http.dart' as http;

class UserProvider {
  Future<ApiResponse> get(LoginRequest loginRequest) async {
    //TODO Add get user
    var body2 = loginRequest.toJson();
    Response response = await http.put(
        Uri.parse("https://us-central1-oluko-2671e.cloudfunctions.net/user"),
        body: body2);
    var signUpResponseBody = jsonDecode(response.body);
    ApiResponse apiResponse = ApiResponse.fromJson(signUpResponseBody);
    return apiResponse;
  }
}
