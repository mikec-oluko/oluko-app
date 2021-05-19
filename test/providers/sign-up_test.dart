import 'package:oluko_app/models/sign-up-request.dart';
import 'package:test/test.dart';
import 'package:oluko_app/providers/sign-up-provider.dart';

void main() {
  group('Sign Up', () {
    test('user should be created correctly', () async {
      final request = SignUpRequest(
          email: 'testemail-${DateTime.now().millisecondsSinceEpoch}@gmail.com',
          password: 'testpassword',
          firstName: 'testFirstName',
          lastName: 'testLastName');

      final response = await SignUpProvider().signUp(request);

      expect(response, isNotNull);
      expect(response.statusCode, 200);
      expect(response.error, isNull);
      expect(response.data, isNotNull);
    });
  });
}
