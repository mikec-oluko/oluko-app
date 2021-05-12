import 'dart:convert';

import 'package:http/http.dart';
import 'package:oluko_app/models/api-response.dart';
import 'package:oluko_app/models/login-request.dart';
import 'package:http/http.dart' as http;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:oluko_app/models/verify-token-request.dart';

class LoginProvider {
  Future<ApiResponse> login(LoginRequest loginRequest) async {
    var body2 = loginRequest.toJson();
    Response response = await http.post(
        Uri.parse(
            "https://us-central1-oluko-2671e.cloudfunctions.net/auth/login"),
        body: body2);
    var signUpResponseBody = jsonDecode(response.body);
    if (signUpResponseBody['message'] is String) {
      List<String> messageList = [signUpResponseBody['message'].toString()];
      signUpResponseBody['message'] = messageList;
    }
    ApiResponse apiResponse = ApiResponse.fromJson(signUpResponseBody);
    return apiResponse;
  }

  Future<ApiResponse> verifyToken(VerifyTokenRequest verifyTokenRequest) async {
    Map<String, dynamic> body = verifyTokenRequest.toJson();
    Response response = await http.post(
        Uri.parse(
            "https://us-central1-oluko-2671e.cloudfunctions.net/auth/token/verify"),
        body: body);
    var responseBody = jsonDecode(response.body);
    if (responseBody['message'].length == null) {
      List<String> messageList = [responseBody['message']];
      responseBody['message'] = messageList;
    }
    ApiResponse apiResponse = ApiResponse.fromJson(responseBody);
    return apiResponse;
  }

  Future<AuthResult> signInWithGoogle() async {
    // Trigger the authentication flow
    final GoogleSignInAccount googleUser = await GoogleSignIn().signIn();

    // Obtain the auth details from the request
    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;

    // Create a new credential
    final credential = GoogleAuthProvider.getCredential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    // Once signed in, return the UserCredential
    return await FirebaseAuth.instance.signInWithCredential(credential);
  }

  Future<AuthResult> signInWithFacebook() async {
    // Trigger the sign-in flow
    final result = await FacebookAuth.instance
        .login(permissions: ["public_profile", "email"]);

    if (result.token != null) {
      // Create a credential from the access token
      final facebookAuthCredential =
          FacebookAuthProvider.getCredential(accessToken: result.token);

      // Once signed in, return the UserCredential
      return await FirebaseAuth.instance
          .signInWithCredential(facebookAuthCredential);
    } else {
      return null;
    }
  }
}
