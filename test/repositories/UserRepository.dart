import 'package:flutter_test/flutter_test.dart';
import 'package:oluko_app/models/UserResponse.dart';
import 'package:oluko_app/repositories/UserRepository.dart';

void main() {
  group('Sign Up', () {
    test('user should be retrieved correctly', () async {
      final UserResponse response =
          await UserRepository().get('testacc@gmail.com');

      expect(response, isNotNull);
      expect(response.email, 'testacc@gmail.com');
    });
  });
}
