import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:oluko_app/models/user-response.dart';

class UserRepository {
  Future<UserResponse> get(String email) async {
    QuerySnapshot docRef = await Firestore.instance
        .collection('users')
        .where('email', isEqualTo: email)
        .getDocuments();
    var response = docRef.documents[0].data;
    var signUpResponseBody = UserResponse.fromJson(response);
    return signUpResponseBody;
  }
}
