import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:global_configuration/global_configuration.dart';

class ProjectConfigurationRepository {
  FirebaseFirestore firestoreInstance;

  ProjectConfigurationRepository() {
    firestoreInstance = FirebaseFirestore.instance;
  }

  static Future<Map> getCourseConfiguration() async {
    final docRef = await FirebaseFirestore.instance.collection('projects').doc(GlobalConfiguration().getString('projectId')).get();
    if (docRef == null && docRef.data() == null) {
      return null;
    }
    var courseConfiguration = docRef.data()['course_configuration'];
    return courseConfiguration is Map ? courseConfiguration : null;
  }
}
