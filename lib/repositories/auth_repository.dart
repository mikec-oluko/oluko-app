import 'dart:convert';
import 'package:http/http.dart';
import 'package:oluko_app/models/dto/api_response.dart';
import 'package:oluko_app/models/dto/login_request.dart';
import 'package:http/http.dart' show Client, Response;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:oluko_app/models/sign_up_request.dart';
import 'package:oluko_app/models/user_response.dart';
import 'package:oluko_app/models/dto/verify_token_request.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthRepository {
  Client http;
  FirebaseAuth firebaseAuthInstance;
  final String url =
      'https://us-central1-oluko-2671e.cloudfunctions.net/api/auth';
  AuthRepository.test({Client http, FirebaseAuth firebaseAuthInstance}) {
    this.http = http;
    this.firebaseAuthInstance = firebaseAuthInstance;
  }

  AuthRepository() {
    this.http = Client();
    this.firebaseAuthInstance = FirebaseAuth.instance;
  }

  Future<ApiResponse> login(LoginRequest loginRequest) async {
    var body = loginRequest.toJson();
    body.removeWhere((key, value) => value == null);
    Response response = await http.post(Uri.parse("$url/login"), body: body);
    var loginResponseBody = jsonDecode(response.body);
    if (loginResponseBody['message'] is String) {
      List<String> messageList = [loginResponseBody['message'].toString()];
      loginResponseBody['message'] = messageList;
    }
    ApiResponse apiResponse = ApiResponse.fromJson(loginResponseBody);
    if (apiResponse.statusCode == 200) {
      await firebaseAuthInstance
          .signInWithCustomToken(apiResponse.data['accessToken']);
    }
    return apiResponse;
  }

  Future<void> sendEmailVerification(SignUpRequest signUpRequest) async {
    await firebaseAuthInstance.signInWithEmailAndPassword(
        email: signUpRequest.email, password: signUpRequest.password);
    final currentUser = firebaseAuthInstance.currentUser;
    await currentUser.sendEmailVerification();
    await firebaseAuthInstance.signOut();
  }

  Future<ApiResponse> verifyToken(VerifyTokenRequest verifyTokenRequest) async {
    Map<String, dynamic> body = verifyTokenRequest.toJson();
    Response response =
        await http.post(Uri.parse("$url/token/verify"), body: body);
    var responseBody = jsonDecode(response.body);
    if (responseBody['message'] != null &&
        responseBody['message'].length == null) {
      List<String> messageList = [responseBody['message']];
      responseBody['message'] = messageList;
    }
    ApiResponse apiResponse = ApiResponse.fromJson(responseBody);
    return apiResponse;
  }

  Future<UserCredential> signInWithGoogle() async {
    // Trigger the authentication flow
    final GoogleSignInAccount googleUser = await GoogleSignIn().signIn();

    // Obtain the auth details from the request
    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;

    // Create a new credential
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    // Once signed in, return the UserCredential
    return await FirebaseAuth.instance.signInWithCredential(credential);
  }

  Future<UserCredential> signInWithFacebook() async {
    // Trigger the sign-in flow
    final result = await FacebookAuth.instance
        .login(permissions: ["public_profile", "email"]);

    if (result.accessToken != null) {
      // Create a credential from the access token
      final facebookAuthCredential =
          FacebookAuthProvider.credential(result.accessToken.token);

      // Once signed in, return the UserCredential
      return await FirebaseAuth.instance
          .signInWithCredential(facebookAuthCredential);
    } else {
      return null;
    }
  }

  Future<ApiResponse> signUp(SignUpRequest signUpRequest) async {
    var body2 = signUpRequest.toJson();
    Response response = await http.post(Uri.parse("$url/signup"), body: body2);
    var signUpResponseBody = jsonDecode(response.body);
    if (signUpResponseBody['message'] != null &&
        signUpResponseBody['message'] is String) {
      signUpResponseBody['message'] = [signUpResponseBody['message']];
    }
    ApiResponse apiResponse = ApiResponse.fromJson(signUpResponseBody);
    return apiResponse;
  }

  Future<bool> storeLoginData(UserResponse loginResponse) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    UserResponse loginInfo = loginResponse.cleanBase();
    String encodedJson = jsonEncode(loginInfo);
    bool loginSaved = await prefs.setString('login-data', encodedJson);
    print('Saved login info.');
    return loginSaved;
  }

  Future<UserResponse> retrieveLoginData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String savedData = prefs.getString('login-data');
    if (savedData == null) {
      return null;
    }
    dynamic decodedJson = jsonDecode(savedData);
    UserResponse loginResponse = UserResponse.fromJson(decodedJson);
    print('Retrieved login info.');
    return loginResponse;
  }

  Future<bool> removeLoginData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    Future<bool> removed = prefs.remove('login-data');
    print('Removed login info.');
    return removed;
  }

  Future<void> sendPasswordResetEmail(String email) {
    return FirebaseAuth.instance.sendPasswordResetEmail(email: email);
  }

  static User getLoggedUser() {
    return FirebaseAuth.instance.currentUser;
  }
}
