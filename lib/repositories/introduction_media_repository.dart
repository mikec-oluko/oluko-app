import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:oluko_app/helpers/enum_collection.dart';

class IntroductionMediaRepository {
  FirebaseFirestore firestoreInstance;
  final String introductionVideoDefaultId = 'introVideo';
  IntroductionMediaRepository() {
    firestoreInstance = FirebaseFirestore.instance;
  }

  static Future<String> getVideoURL(IntroductionMediaTypeEnum type, {bool useStreamUrl = false}) async {
    final QuerySnapshot docRef = await FirebaseFirestore.instance
        .collection('projects')
        .doc(GlobalConfiguration().getString('projectId'))
        .collection('introductionMedia')
        .where('title', isEqualTo: introductionMediaType[type])
        .get();
    if (docRef.docs == null || docRef.docs.isEmpty) {
      return null;
    }
    final response = docRef.docs[0].data() as Map<String, dynamic>;
    return !useStreamUrl ? response['url'] as String : response['video_hls'] as String ?? response['url'] as String;
  }
}
