import 'dart:convert';

import 'package:http/http.dart';
import 'package:oluko_app/models/api-response.dart';
import 'package:oluko_app/models/sign-up-request.dart';
import 'package:oluko_app/models/sign-up-response.dart';
import 'package:http/http.dart' as http;

class SignUpProvider {
  Future<ApiResponse> signUp(SignUpRequest signUpRequest) async {
    var body2 = signUpRequest.toJson();
    Response response = await http.post(
        Uri.parse(
            "https://us-central1-oluko-2671e.cloudfunctions.net/auth/signup"),
        body: body2);
    var signUpResponseBody = jsonDecode(response.body);
    ApiResponse apiResponse = ApiResponse.fromJson(signUpResponseBody);
    return apiResponse;
  }
}
