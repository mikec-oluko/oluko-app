import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:oluko_app/models/enrollment_audio.dart';
import 'package:oluko_app/models/submodels/audio.dart';
import 'package:oluko_app/models/submodels/class_audio.dart';

class EnrollmentAudioRepository {
  FirebaseFirestore firestoreInstance;

  EnrollmentAudioRepository() {
    firestoreInstance = FirebaseFirestore.instance;
  }

  static Future<EnrollmentAudio> get(String courseEnrollmentId, String classId) async {
    final QuerySnapshot docRef = await FirebaseFirestore.instance
        .collection('projects')
        .doc(GlobalConfiguration().getString('projectId'))
        .collection('enrollmentAudios')
        .where('course_class.id', isEqualTo: classId)
        .where('course_enrollment.id', isEqualTo: courseEnrollmentId)
        .get();
    if (docRef.docs == null || docRef.docs.isEmpty) {
      return null;
    }
    final response = docRef.docs[0].data() as Map<String, dynamic>;
    final enrollmentAudio = EnrollmentAudio.fromJson(response);
    return enrollmentAudio;
  }

  static Future<void> markAudioAsDeleted(EnrollmentAudio enrollmentAudio, List<Audio> audios) async {
    final DocumentReference reference = FirebaseFirestore.instance
        .collection('projects')
        .doc(GlobalConfiguration().getString('projectId'))
        .collection('enrollmentAudios')
        .doc(enrollmentAudio.id);

        enrollmentAudio.audios = audios;
    await reference.update({'audios': List<dynamic>.from(enrollmentAudio.audios.map((audio) => audio.toJson()))});
  }
}
