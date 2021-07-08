import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:mvt_fitness/models/course_category.dart';

class CourseCategoryRepository {
  FirebaseFirestore firestoreInstance;

  CourseCategoryRepository() {
    firestoreInstance = FirebaseFirestore.instance;
  }

  CourseCategoryRepository.test({FirebaseFirestore firestoreInstance}) {
    this.firestoreInstance = firestoreInstance;
  }

  Future<List<CourseCategory>> getAll() async {
    QuerySnapshot docRef = await FirebaseFirestore.instance
        .collection('projects')
        .doc(GlobalConfiguration().getValue("projectId"))
        .collection('courseCategories')
        .get();
    List<CourseCategory> response = [];
    docRef.docs.forEach((doc) {
      final Map<String, dynamic> element = doc.data();
      response.add(CourseCategory.fromJson(element));
    });
    return response;
  }
}
