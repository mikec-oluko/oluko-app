import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:oluko_app/models/sign_up_request.dart';
import 'package:oluko_app/models/sign_up_response.dart';
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
    if (docRef.docs == null || docRef.docs.length == 0) {
      return null;
    }
    var response = docRef.docs[0].data();
    var loginResponseBody = UserResponse.fromJson(response);
    return loginResponseBody;
  }

  Future<UserResponse> createSSO(SignUpRequest signUpRequest) async {
    CollectionReference reference = FirebaseFirestore.instance
        .collection('projects')
        .doc(GlobalConfiguration().getValue("projectId"))
        .collection('users');

    UserResponse user = UserResponse(
        firstName: signUpRequest.firstName,
        lastName: signUpRequest.lastName,
        email: signUpRequest.email);
    final DocumentReference docRef = reference.doc();
    user.id = docRef.id;
    user.username = docRef.id;
    try {
      await docRef.set(user.toJson());
      return user;
    } on Exception catch (e) {
      return null;
    }
  }
}
