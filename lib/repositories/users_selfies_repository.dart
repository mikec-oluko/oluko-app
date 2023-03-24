import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:oluko_app/models/users_selfies.dart';

class UsersSelfiesRepository {
  FirebaseFirestore firestoreInstance;

  UsersSelfiesRepository() {
    firestoreInstance = FirebaseFirestore.instance;
  }

  UsersSelfiesRepository.test({this.firestoreInstance});

  static Future<UsersSelfies> get() async {
    QuerySnapshot querySnapshot =
        await FirebaseFirestore.instance.collection('projects').doc(GlobalConfiguration().getString('projectId')).collection('usersSelfies').get();
    List<UsersSelfies> usersSelfies = mapQueryToUsersSelfies(querySnapshot);
    return usersSelfies != null ? usersSelfies[0] : null;
  }

  static void update(String selfie) async {
    UsersSelfies usersSelfies = await get();
    final DocumentReference docRef = await FirebaseFirestore.instance
        .collection('projects')
        .doc(GlobalConfiguration().getString('projectId'))
        .collection('usersSelfies')
        .doc(usersSelfies.id);
    if (usersSelfies.selfies.length < 70) {
      usersSelfies.selfies.add(selfie);
    } else {
      usersSelfies.selfies[usersSelfies.indexToReplace] = selfie;
      usersSelfies.indexToReplace = usersSelfies.indexToReplace < 69 ? usersSelfies.indexToReplace + 1 : 0;
    }
    docRef.update({'selfies': usersSelfies.selfies, 'index_to_replace': usersSelfies.indexToReplace});
  }

  static List<UsersSelfies> mapQueryToUsersSelfies(QuerySnapshot qs) {
    return qs.docs.map((DocumentSnapshot ds) {
      return UsersSelfies.fromJson(ds.data() as Map<String, dynamic>);
    }).toList();
  }
}
