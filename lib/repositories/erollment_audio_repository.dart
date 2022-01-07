import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:oluko_app/models/enrollment_audio.dart';

class EnrollmentAudioRepository {
  FirebaseFirestore firestoreInstance;

  EnrollmentAudioRepository() {
    firestoreInstance = FirebaseFirestore.instance;
  }

  static Future<EnrollmentAudio> get(String courseEnrollmentId) async {
    final QuerySnapshot docRef = await FirebaseFirestore.instance
        .collection('projects')
        .doc(GlobalConfiguration().getValue('projectId'))
        .collection('enrollmentAudios')
        .where('course_enrollment_id', isEqualTo: courseEnrollmentId)
        .get();
    if (docRef.docs == null || docRef.docs.isEmpty) {
      return null;
    }
    final response = docRef.docs[0].data() as Map<String, dynamic>;
    final enrollmentAudio = EnrollmentAudio.fromJson(response);
    return enrollmentAudio;
  }
}
