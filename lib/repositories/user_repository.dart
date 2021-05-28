import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:oluko_app/models/user_response.dart';

class UserRepository {
  Firestore firestoreInstance;

  UserRepository() {
    firestoreInstance = Firestore.instance;
  }

  UserRepository.test({Firestore firestoreInstance}) {
    this.firestoreInstance = firestoreInstance;
  }

  Future<UserResponse> get(String email) async {
    QuerySnapshot docRef = await firestoreInstance
        .collection('users')
        .where('email', isEqualTo: email)
        .getDocuments();
    var response = docRef.documents[0].data;
    var signUpResponseBody = UserResponse.fromJson(response);
    return signUpResponseBody;
  }
}
