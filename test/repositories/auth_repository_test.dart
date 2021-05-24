import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/mockito.dart';
import 'package:oluko_app/models/api_response.dart';
import 'package:oluko_app/models/login_request.dart';
import 'package:oluko_app/models/sign_up_request.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oluko_app/models/user_response.dart';
import 'package:oluko_app/models/verify_token_request.dart';
import 'package:oluko_app/repositories/auth_repository.dart';

class MockClient extends Mock implements http.Client {}

void main() {
  group('Sign Up', () {
    test('user should be created correctly', () async {
      final request = SignUpRequest(
          email: 'testemail-${DateTime.now().millisecondsSinceEpoch}@gmail.com',
          password: 'testpassword',
          firstName: 'testFirstName',
          lastName: 'testLastName');

      MockClient mockClient = MockClient();
      when(mockClient.post(any, body: request.toJson())).thenAnswer((_) =>
          Future.value(http.Response(
              '{"statusCode": 200, "data": {"id":"testtest22"}}', 200)));

      final response =
          await AuthRepository.test(http: mockClient).signUp(request);

      expect(response, isNotNull);
      expect(response.statusCode, 200);
      expect(response.error, isNull);
      expect(response.data, isNotNull);
    });

    test('user should be logged in', () async {
      final request = LoginRequest(
        email: 'testacc@gmail.com',
        password: 'testacc',
      );

      MockClient mockClient = MockClient();
      when(mockClient.post(any, body: request.toJson())).thenAnswer((_) =>
          Future.value(http.Response(
              '{"statusCode": 200, "data": {"accessToken":"testtest22"}}',
              200)));
      final response =
          await AuthRepository.test(http: mockClient).login(request);
      expect(response, isNotNull);
      expect(response.statusCode, 200);
      expect(response.error, isNull);
      expect(response.data, isNotNull);
    });

    test('user should be stored', () async {
      final UserResponse request = UserResponse();

      final response = await AuthRepository().storeLoginData(request);
      expect(response, isNotNull);
      expect(response, true);
    });

    test('user should be retrieved', () async {
      final UserResponse request =
          UserResponse(id: 'awo2j5t1o', email: 'testEmail@gmail.com');

      await AuthRepository().storeLoginData(request);
      final retrieveResponse = await AuthRepository().retrieveLoginData();
      expect(retrieveResponse, isNotNull);
      expect(retrieveResponse.id, request.id);
      expect(retrieveResponse.email, request.email);
    });

    test('token should be verified', () async {
      final request = VerifyTokenRequest(tokenId: 'myToken');
      MockClient mockClient = MockClient();
      ApiResponse httpMockResponse = ApiResponse(
          statusCode: 200,
          data: {'accessToken': 'testtest22'},
          error: null,
          message: ['Retrieved Successfully']);
      when(mockClient.post(any, body: request.toJson())).thenAnswer((_) =>
          Future.value(http.Response(jsonEncode(httpMockResponse), 200)));

      final response =
          await AuthRepository.test(http: mockClient).verifyToken(request);
      expect(response, isNotNull);
      expect(response.data, isNotNull);
      expect(response.data['accessToken'], isA<String>());
    });
  });
}
