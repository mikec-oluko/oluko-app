import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:oluko_app/models/transformation_journey_uploads.dart';

class TransformationJourneyRepository {
  FirebaseFirestore firestoreInstance;

  TransformationJourneyRepository() {
    firestoreInstance = FirebaseFirestore.instance;
  }

  TransformationJourneyRepository.test({FirebaseFirestore firestoreInstance}) {
    this.firestoreInstance = firestoreInstance;
  }

  //TODO: Filter or not, userInfo to return only the List
  Future<List<TransformationJourneyUpload>> getUploadedContentByUserName(
      String userName) async {
    try {
      QuerySnapshot docRef = await FirebaseFirestore.instance
          .collection('projects')
          .doc(GlobalConfiguration().getValue("projectId"))
          .collection('users')
          .doc(userName)
          .collection('transformationJourneyUploads')
          .get();

      // var first = docRef.docs[0].data();
      // final content = TransformationJourneyUpload.fromJson(first);
      List<TransformationJourneyUpload> contentUploaded = [];
      docRef.docs.forEach((doc) {
        final Map<String, dynamic> content = doc.data();
        contentUploaded.add(TransformationJourneyUpload.fromJson(content));
      });

      return contentUploaded;
    } catch (e) {
      print("ESTO:" + e);
    }
  }
}
