import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:oluko_app/models/course_category.dart';

class CourseCategoryRepository {
  FirebaseFirestore firestoreInstance;

  CourseCategoryRepository() {
    firestoreInstance = FirebaseFirestore.instance;
  }

  CourseCategoryRepository.test({FirebaseFirestore firestoreInstance}) {
    this.firestoreInstance = firestoreInstance;
  }

  Future<List<CourseCategory>> getAll() async {
    QuerySnapshot docRef =
        await FirebaseFirestore.instance.collection('projects').doc(GlobalConfiguration().getString('projectId')).collection('courseCategories').get();
    List<CourseCategory> response = [];
    docRef.docs.forEach((doc) {
      final Map<String, dynamic> element = doc.data() as Map<String, dynamic>;
      response.add(CourseCategory.fromJson(element));
    });
    return response;
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getCategoriesSubscription() {
    Stream<QuerySnapshot<Map<String, dynamic>>> categoriesStream = FirebaseFirestore.instance
        .collection('projects')
        .doc(GlobalConfiguration().getString('projectId'))
        .collection('courseCategories')
        .where('is_deleted', isNotEqualTo: true)
        .snapshots();
    return categoriesStream;
  }
}
