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
  Future<List<TransformationJourneyUpload>> getUploadedContentByUserId(
      String username) async {
    try {
      QuerySnapshot docRef = await FirebaseFirestore.instance
          .collection('projects')
          .doc(GlobalConfiguration().getValue("projectId"))
          .collection('users')
          .doc(username)
          .collection('transformationJourneyUploads')
          .get();
      List<TransformationJourneyUpload> listOfContent = [];
      docRef.docs.forEach((doc) {
        final Map<String, dynamic> element = doc.data();
        listOfContent.add(TransformationJourneyUpload.fromJson(element));
      });
      return listOfContent;
    } catch (e) {
      throw e;
    }
  }
}
