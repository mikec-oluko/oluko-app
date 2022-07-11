import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:oluko_app/models/users_selfies.dart';

class UsersSelfiesRepository {
  FirebaseFirestore firestoreInstance;

  UsersSelfiesRepository() {
    firestoreInstance = FirebaseFirestore.instance;
  }

  UsersSelfiesRepository.test({this.firestoreInstance});

  static Future<UsersSelfies> getUsersSelfies() async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('projects')
        .doc(GlobalConfiguration().getValue('projectId'))
        .collection('usersSelfies')
        .get();
    List<UsersSelfies> usersSelfies = mapQueryToUsersSelfies(querySnapshot);
    return usersSelfies != null ? usersSelfies[0] : null;
  }

  static List<UsersSelfies> mapQueryToUsersSelfies(QuerySnapshot qs) {
    return qs.docs.map((DocumentSnapshot ds) {
      return UsersSelfies.fromJson(ds.data() as Map<String, dynamic>);
    }).toList();
  }
}
