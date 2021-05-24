import 'package:oluko_app/models/SignUpRequest.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oluko_app/repositories/AuthRepository.dart';

void main() {
  group('Sign Up', () {
    test('user should be created correctly', () async {
      final request = SignUpRequest(
          email: 'testemail-${DateTime.now().millisecondsSinceEpoch}@gmail.com',
          password: 'testpassword',
          firstName: 'testFirstName',
          lastName: 'testLastName');

      final response = await AuthRepository().signUp(request);

      expect(response, isNotNull);
      expect(response.statusCode, 200);
      expect(response.error, isNull);
      expect(response.data, isNotNull);
    });
  });
}
