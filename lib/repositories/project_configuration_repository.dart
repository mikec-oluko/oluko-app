import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:oluko_app/models/enrollment_audio.dart';
import 'package:oluko_app/models/submodels/audio.dart';
import 'package:oluko_app/models/submodels/class_audio.dart';

class ProjectConfigurationRepository {
  FirebaseFirestore firestoreInstance;

  ProjectConfigurationRepository() {
    firestoreInstance = FirebaseFirestore.instance;
  }

  static Future<Map> getCourseConfiguration() async {
    final docRef = await FirebaseFirestore.instance.collection('projects').doc(GlobalConfiguration().getValue('projectId')).get();
    if (docRef == null && docRef.data() == null) {
      return null;
    }
    var courseConfiguration = docRef.data()['course_configuration'];
    return courseConfiguration is Map ? courseConfiguration : null;
  }

  static Future<void> markAudioAsDeleted(EnrollmentAudio enrollmentAudio, List<Audio> audios, String classId) async {
    final DocumentReference reference = FirebaseFirestore.instance
        .collection('projects')
        .doc(GlobalConfiguration().getValue('projectId'))
        .collection('enrollmentAudios')
        .doc(enrollmentAudio.id);
    for (ClassAudio classAudio in enrollmentAudio.classAudios) {
      if (classAudio.classId == classId) {
        classAudio.audios = audios;
        break;
      }
    }
    await reference.update({'class_audios': List<dynamic>.from(enrollmentAudio.classAudios.map((audio) => audio.toJson()))});
  }
}
