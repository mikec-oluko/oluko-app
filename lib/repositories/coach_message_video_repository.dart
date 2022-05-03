import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:global_configuration/global_configuration.dart';

class CoachMessageVideoRepository {
  FirebaseFirestore firestoreInstance;
  static DocumentReference projectReference =
      FirebaseFirestore.instance.collection('projects').doc(GlobalConfiguration().getValue('projectId'));

  CoachMessageVideoRepository() {
    firestoreInstance = FirebaseFirestore.instance;
  }
  CoachMessageVideoRepository.test({this.firestoreInstance});
}
