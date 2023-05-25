import 'dart:convert';
import 'dart:math';
import 'package:global_configuration/global_configuration.dart';
import 'package:http/http.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:oluko_app/models/dto/api_response.dart';
import 'package:oluko_app/models/dto/forgot_password_dto.dart';
import 'package:oluko_app/models/dto/login_request.dart';
import 'package:http/http.dart' show Client, Response;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:oluko_app/models/dto/user_dto.dart';
import 'package:oluko_app/models/sign_up_request.dart';
import 'package:oluko_app/models/user_response.dart';
import 'package:oluko_app/models/dto/verify_token_request.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

class AuthRepository {
  Client http;
  FirebaseAuth firebaseAuthInstance;
  final String url = GlobalConfiguration().getString('firebaseFunctions').toString() + '/auth';

  AuthRepository.test({Client http, FirebaseAuth firebaseAuthInstance}) {
    http = http;
    firebaseAuthInstance = firebaseAuthInstance;
  }

  AuthRepository() {
    http = Client();
    firebaseAuthInstance = FirebaseAuth.instance;
  }

  Future<String> getApiToken() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String apiToken = prefs.getString('apiToken');
    final bool hasExpired = JwtDecoder.isExpired(apiToken);
    if (hasExpired) {
      return null;
    }
    return apiToken;
  }

  Future<ApiResponse> login(LoginRequest loginRequest) async {
    final body = loginRequest.toJson();
    body.removeWhere((key, value) => value == null);
    final Response response = await http.post(Uri.parse('$url/login'), body: body);
    final loginResponseBody = jsonDecode(response.body);
    if (loginResponseBody['message'] is String) {
      final List<String> messageList = [loginResponseBody['message'].toString()];
      loginResponseBody['message'] = messageList;
    }
    final ApiResponse apiResponse = ApiResponse.fromJson(loginResponseBody as Map<String, dynamic>);
    if (apiResponse.statusCode == 200) {
      final accesToken = apiResponse.data['accessToken'] as String;
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('apiToken', accesToken);
      await firebaseAuthInstance.signInWithCustomToken(accesToken);
    }
    return apiResponse;
  }

  /*Future<void> sendEmailVerification(SignUpRequest signUpRequest) async {
    await firebaseAuthInstance.signInWithEmailAndPassword(email: signUpRequest.email, password: signUpRequest.password);
    final currentUser = firebaseAuthInstance.currentUser;
    await currentUser.sendEmailVerification();
    await firebaseAuthInstance.signOut();
  }*/

  Future<ApiResponse> verifyToken(VerifyTokenRequest verifyTokenRequest) async {
    final Map<String, dynamic> body = verifyTokenRequest.toJson();
    final Response response = await http.post(Uri.parse('$url/token/verify'), body: body);
    final responseBody = jsonDecode(response.body);
    if (responseBody['message'] != null && responseBody['message'].length == null) {
      final List<String> messageList = [responseBody['message'].toString()];
      responseBody['message'] = messageList;
    }
    final ApiResponse apiResponse = ApiResponse.fromJson(responseBody as Map<String, dynamic>);
    return apiResponse;
  }

  Future<UserCredential> signInWithGoogle() async {
    await firebaseAuthInstance.signOut();
    try {
      return await externalLoginFlow('google');
    } catch (exception) {
      print(e.toString());
      return null;
    }
  }

  Future<UserCredential> signInWithFacebook() async {
    await FacebookAuth.instance.logOut();
    // Trigger the sign-in flow
    final result = await FacebookAuth.instance.login(permissions: ['public_profile', 'email']);

    if (result.accessToken != null) {
      // Create a credential from the access token
      final facebookAuthCredential = FacebookAuthProvider.credential(result.accessToken.token);
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('apiToken', result.accessToken.token);
      try {
        //TODO: handle account with same email exception
        // Once signed in, return the UserCredential
        return await FirebaseAuth.instance.signInWithCredential(facebookAuthCredential);
      } on FirebaseAuthException catch (error) {
        //   await FirebaseAuth.instance.sendSignInLinkToEmail(email: error.email);
        //   log(error.toString());
        rethrow;
      }
    } else {
      return null;
    }
  }

  /// Generates a cryptographically secure random nonce, to be included in a
  /// credential request.
  String generateNonce([int length = 32]) {
    const charset = '568793420IHDFBGGNSOID9YGFOUAhsibdvoublvqpwnecla-._';
    final random = Random.secure();
    return List.generate(length, (_) => charset[random.nextInt(charset.length)]).join();
  }

  /// Returns the sha256 hash of [input] in hex notation.
  String sha256ofString(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  Future<UserCredential> signInWithApple() async {
    await firebaseAuthInstance.signOut();
    try {
      return await externalLoginFlow('apple');
    } catch (exception) {
      print(e.toString());
      return null;
    }
  }

  Future<UserCredential> externalLoginFlow(String provider) async {
    final response = await externalLoginPopup(provider);
    var model = {};
    if (response.additionalUserInfo.profile[provider == 'facebook' ? 'first_name' : 'given_name'] != null &&
        response.additionalUserInfo.profile[provider == 'facebook' ? 'first_name' : 'given_name'] != '') {
      model['firstName'] = response.additionalUserInfo.profile[provider == 'facebook' ? 'first_name' : 'given_name'];
    } else {
      model['firstName'] = response.user.displayName;
    }
    model['lastName'] = response.additionalUserInfo.profile[provider == 'facebook' ? 'last_name' : 'family_name'];
    model['avatar'] = response.user.photoURL;
    model['email'] = response.user.email;
    model['tokenId'] = await response.user.getIdToken();
    model['projectId'] = GlobalConfiguration().getString('projectId');

    try {
      final externalAuthResponse = await http.post(Uri.parse('$url/externalAuth'), body: jsonEncode(model), headers: {'content-type': 'application/json'});
      if (externalAuthResponse.statusCode >= 200 && externalAuthResponse.statusCode < 300) {
        final SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('apiToken', model['tokenId']?.toString());
        return response;
      }
      return null;
    } catch (e) {
      print('Error: ' + e.toString());
      return null;
    }
  }

  Future<UserCredential> externalLoginPopup(String provider) async {
    AuthCredential credentials;
    switch (provider) {
      case 'facebook':
        credentials = null;
        break;
      case 'apple':
        // To prevent replay attacks with the credential returned from Apple, we
        // include a nonce in the credential request. When signing in in with
        // Firebase, the nonce in the id token returned by Apple, is expected to
        // match the sha256 hash of `rawNonce`.
        final rawNonce = generateNonce();
        final nonce = sha256ofString(rawNonce);
        final AuthorizationCredentialAppleID appleCredential = await SignInWithApple.getAppleIDCredential(
          scopes: [
            AppleIDAuthorizationScopes.email,
            AppleIDAuthorizationScopes.fullName,
          ],
          nonce: nonce,
        );

        credentials = OAuthProvider('apple.com').credential(
          idToken: appleCredential.identityToken,
          rawNonce: rawNonce,
        );
        break;
      default:
        final googleSignIn = GoogleSignIn(
          scopes: [
            'email',
            'https://www.googleapis.com/auth/contacts.readonly',
          ],
        );
        // Trigger the authentication flow
        final googleUser = await googleSignIn.signIn();
        // Obtain the auth details from the request
        final GoogleSignInAuthentication googleAuth = await googleUser?.authentication;

        // Create a new credential
        credentials = GoogleAuthProvider.credential(
          accessToken: googleAuth?.accessToken,
          idToken: googleAuth?.idToken,
        );
        break;
    }
    return firebaseAuthInstance.signInWithCredential(credentials);
  }

  Future<ApiResponse> signUp(SignUpRequest signUpRequest) async {
    final Map<String, dynamic> signUpBody = signUpRequest.toDTOJson();
    final Response response = await http.post(Uri.parse('$url/signup'), body: jsonEncode(signUpBody), headers: {'content-type': 'application/json'});
    final signUpResponseBody = jsonDecode(response.body);
    if (signUpResponseBody['message'] != null && signUpResponseBody['message'] is String) {
      signUpResponseBody['message'] = [signUpResponseBody['message']];
    }
    final ApiResponse apiResponse = ApiResponse.fromJson(signUpResponseBody as Map<String, dynamic>);
    return apiResponse;
  }

  Future<bool> storeLoginData(UserResponse loginResponse) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final UserDto userDto = UserDto.fromUserResponse(loginResponse);
    final String encodedJson = jsonEncode(userDto);
    final bool loginSaved = await prefs.setString('login-data', encodedJson);
    print('Saved login info.');
    return loginSaved;
  }

  Future<UserResponse> retrieveLoginData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String savedData = prefs.getString('login-data');
    if (savedData == null) {
      return null;
    }
    final dynamic decodedJson = jsonDecode(savedData);
    final UserResponse loginResponse = UserResponse.fromJson(decodedJson as Map<String, dynamic>);
    print('Retrieved login info.');
    return loginResponse;
  }

  Future<bool> removeLoginData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final Future<bool> removedLoginData = prefs.remove('login-data');
    final Future<bool> removedApiToken = prefs.remove('apiToken');
    final Future<bool> removeFutures = Future.wait([removedLoginData, removedApiToken]).then((results) => !results.any((element) => element == false));
    FirebaseAuth.instance.signOut();
    print('Removed login info.');
    return removeFutures;
  }

  Future<void> sendPasswordResetEmail(ForgotPasswordDto body) async {
    final Response response = await http.post(Uri.parse('$url/forgot-password'), body: body.toJson());
  }

  static User getLoggedUser() {
    return FirebaseAuth.instance.currentUser;
  }
}
