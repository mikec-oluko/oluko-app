import 'dart:convert';
import 'package:http/http.dart';
import 'package:oluko_app/models/api_response.dart';
import 'package:oluko_app/models/login_request.dart';
import 'package:http/http.dart' show Client, Response;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:oluko_app/models/project_login_request.dart';
import 'package:oluko_app/models/sign_up_request.dart';
import 'package:oluko_app/models/user_response.dart';
import 'package:oluko_app/models/verify_token_request.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthRepository {
  Client http;
  FirebaseAuth firebaseAuthInstance;
  String url = 'https://us-central1-oluko-2671e.cloudfunctions.net/api';
  AuthRepository.test({Client http, FirebaseAuth firebaseAuthInstance}) {
    this.http = http;
    this.firebaseAuthInstance = firebaseAuthInstance;
  }

  AuthRepository() {
    this.http = Client();
    this.firebaseAuthInstance = FirebaseAuth.instance;
  }

  Future<ApiResponse> login(LoginRequest loginRequest) async {
    var body2 = loginRequest.toJson();
    Response response =
        await http.post(Uri.parse("$url/auth/login"), body: body2);
    var signUpResponseBody = jsonDecode(response.body);
    if (signUpResponseBody['message'] is String) {
      List<String> messageList = [signUpResponseBody['message'].toString()];
      signUpResponseBody['message'] = messageList;
    }
    ApiResponse apiResponse = ApiResponse.fromJson(signUpResponseBody);
    if (apiResponse.statusCode == 200) {
      await firebaseAuthInstance
          .signInWithCustomToken(apiResponse.data['accessToken']);
    }
    return apiResponse;
  }

  Future<bool> loginProject(ProjectLoginRequest projectLoginRequest) async {
    var body = projectLoginRequest.toJson();
    Response response = await http.post(
        Uri.parse(
            "https://us-central1-oluko-2671e.cloudfunctions.net/api/auth/loginproject"),
        body: body);
    var signInProjectResponseBody = jsonDecode(response.body);
    if (signInProjectResponseBody['message'] is String) {
      List<String> messageList = [
        signInProjectResponseBody['message'].toString()
      ];
      signInProjectResponseBody['message'] = messageList;
    }
    ApiResponse apiResponse = ApiResponse.fromJson(signInProjectResponseBody);
    if (apiResponse.statusCode == 200) {
      var user = await getLoggedUser();
      await user.getIdToken(true);
      //TODO: check if loaded with new claims
      return true;
    }
    return false;
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
        await http.post(Uri.parse("$url/auth/token/verify"), body: body);
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
    Response response =
        await http.post(Uri.parse("$url/auth/signup"), body: body2);
    var signUpResponseBody = jsonDecode(response.body);
    ApiResponse apiResponse = ApiResponse.fromJson(signUpResponseBody);
    return apiResponse;
  }

  Future<bool> storeLoginData(UserResponse signUpResponse) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String encodedJson = jsonEncode(signUpResponse);
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
    UserResponse signUpResponse = UserResponse.fromJson(decodedJson);
    print('Retrieved login info.');
    return signUpResponse;
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
