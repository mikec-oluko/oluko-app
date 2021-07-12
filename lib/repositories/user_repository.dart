import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:oluko_app/models/user_response.dart';

class UserRepository {
  FirebaseFirestore firestoreInstance;

  UserRepository() {
    firestoreInstance = FirebaseFirestore.instance;
  }

  UserRepository.test({FirebaseFirestore firestoreInstance}) {
    this.firestoreInstance = firestoreInstance;
  }

  Future<UserResponse> get(String email) async {
    QuerySnapshot docRef = await FirebaseFirestore.instance
        .collection('projects')
        .doc(GlobalConfiguration().getValue("projectId"))
        .collection('users')
        .where('email', isEqualTo: email)
        .get();
    var response = docRef.docs[0].data();
    var loginResponseBody = UserResponse.fromJson(response);
    return loginResponseBody;
  }
}
