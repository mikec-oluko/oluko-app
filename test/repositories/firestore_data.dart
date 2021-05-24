import 'package:http/http.dart' as http;
import 'package:mockito/mockito.dart';
import 'package:oluko_app/models/sign_up_request.dart';
import 'package:flutter_test/flutter_test.dart';
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
  });
}
