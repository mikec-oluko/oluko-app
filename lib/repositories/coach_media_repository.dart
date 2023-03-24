import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:oluko_app/models/coach_media.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

class CoachMediaRepository {
  FirebaseFirestore firestoreInstance;

  static DocumentReference projectReference = FirebaseFirestore.instance.collection('projects').doc(GlobalConfiguration().getString('projectId'));

  CoachMediaRepository() {
    firestoreInstance = FirebaseFirestore.instance;
  }

  CoachMediaRepository.test({this.firestoreInstance});

  Future<List<CoachMedia>> getUploadedMediaByCoachId(String coachId) async {
    try {
      final QuerySnapshot docRef = await FirebaseFirestore.instance
          .collection('projects')
          .doc(GlobalConfiguration().getString('projectId'))
          .collection('users')
          .doc(coachId)
          .collection('myMedia')
          .where('video', isNotEqualTo: null)
          .get();
      final List<CoachMedia> coachMediaUploaded = [];
      for (final doc in docRef.docs) {
        final Map<String, dynamic> content = doc.data() as Map<String, dynamic>;
        coachMediaUploaded.add(CoachMedia.fromJson(content));
      }
      return coachMediaUploaded;
    } catch (e, stackTrace) {
      await Sentry.captureException(
        e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getCoachUploadedMediaStream(String coachId) {
    Stream<QuerySnapshot<Map<String, dynamic>>> coachMediaStream = FirebaseFirestore.instance
        .collection('projects')
        .doc(GlobalConfiguration().getString('projectId'))
        .collection('users')
        .doc(coachId)
        .collection('myMedia')
        .where('is_deleted', isNotEqualTo: true)
        .snapshots();
    return coachMediaStream;
  }
}
