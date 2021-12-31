import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:global_configuration/global_configuration.dart';

class IntroductionMediaRepository {
  FirebaseFirestore firestoreInstance;
  final String introductionVideoDefaultId = 'introVideo';
  IntroductionMediaRepository() {
    firestoreInstance = FirebaseFirestore.instance;
  }

  Future<String> getIntroVideoURL() async {
    final QuerySnapshot docRef = await FirebaseFirestore.instance
        .collection('projects')
        .doc(GlobalConfiguration().getValue('projectId'))
        .collection('introductionMedia')
        .where('title', isEqualTo: 'intro video')
        .get();
    if (docRef.docs == null || docRef.docs.isEmpty) {
      return null;
    }
    final response = docRef.docs[0].data() as Map<String, dynamic>;
    return response['url'] as String;
  }
}
