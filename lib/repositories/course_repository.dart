import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:oluko_app/models/course.dart';
import 'package:oluko_app/models/course_statistics.dart';
import 'package:oluko_app/models/submodels/object_submodel.dart';

class CourseRepository {
  FirebaseFirestore firestoreInstance;

  CourseRepository() {
    firestoreInstance = FirebaseFirestore.instance;
  }

  CourseRepository.test({FirebaseFirestore firestoreInstance}) {
    this.firestoreInstance = firestoreInstance;
  }

  Future<List<Course>> getAll() async {
    QuerySnapshot docRef = await FirebaseFirestore.instance
        .collection('projects')
        .doc(GlobalConfiguration().getValue("projectId"))
        .collection('courses')
        .get();
    List<Course> response = [];
    docRef.docs.forEach((doc) {
      final Map<String, dynamic> element = doc.data();
      response.add(Course.fromJson(element));
    });
    return response;
  }

  static Future<Course> get(String courseId) async {
    DocumentReference docRef = FirebaseFirestore.instance
        .collection('projects')
        .doc(GlobalConfiguration().getValue("projectId"))
        .collection('courses')
        .doc(courseId);
    DocumentSnapshot ds = await docRef.get();
    return Course.fromJson(ds.data());
  }

  static Future<CourseStatistics> getStatistics(
      DocumentReference reference) async {
    DocumentSnapshot docRef = await reference.get();
    return CourseStatistics.fromJson(docRef.data());
  }

  static Course create(Course course) {
    CollectionReference reference = FirebaseFirestore.instance
        .collection('projects')
        .doc(GlobalConfiguration().getValue("projectId"))
        .collection('courses');
    final DocumentReference docRef = reference.doc();
    course.id = docRef.id;
    docRef.set(course.toJson());
    return course;
  }

  static Future<void> updateClasses(
      ObjectSubmodel classObj, DocumentReference reference) async {
    DocumentSnapshot ds = await reference.get();
    Course course = Course.fromJson(ds.data());
    List<ObjectSubmodel> classes;
    if (course.classes == null) {
      classes = [];
    } else {
      classes = course.classes;
    }
    classes.add(classObj);
    reference.update(
        {'classes': List<dynamic>.from(classes.map((c) => c.toJson()))});
  }
}
