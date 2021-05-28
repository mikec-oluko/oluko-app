import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:oluko_app/models/user_response.dart';

class UserRepository {
  Future<UserResponse> get(String email) async {
    QuerySnapshot docRef = await FirebaseFirestore.instance
        .collection('users')
        .where('email', isEqualTo: email)
        .get();
    var response = docRef.docs[0].data();
    var signUpResponseBody = UserResponse.fromJson(response);
    return signUpResponseBody;
  }
}
