import 'package:oluko_app/models/user-response.dart';
import 'package:oluko_app/providers/firebase_provider.dart';

class UserProvider {
  Future<UserResponse> get(String email) async {
    var response = await FirebaseProvider.getUserByEmail(email);
    var signUpResponseBody = UserResponse.fromJson(response);
    return signUpResponseBody;
  }
}
