import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:oluko_app/models/course.dart';
import 'package:oluko_app/models/course_enrollment.dart';
import 'package:oluko_app/models/course_statistics.dart';
import 'package:oluko_app/models/submodels/object_submodel.dart';
import 'package:oluko_app/repositories/course_enrollment_repository.dart';

class CourseRepository {
  FirebaseFirestore firestoreInstance;

  CourseRepository() {
    firestoreInstance = FirebaseFirestore.instance;
  }

  CourseRepository.test({FirebaseFirestore firestoreInstance}) {
    this.firestoreInstance = firestoreInstance;
  }

  static final CollectionReference _courseCollectionInstance =
      FirebaseFirestore.instance.collection('projects').doc(GlobalConfiguration().getString('projectId')).collection('courses');

  Future<List<Course>> getAll() async {
    QuerySnapshot docRef = await _courseCollectionInstance.get();
    List<Course> response = [];
    docRef.docs.forEach((doc) {
      final Map<String, dynamic> element = doc.data() as Map<String, dynamic>;
      response.add(Course.fromJson(element));
    });
    return response;
  }

  static Future<Course> get(String courseId) async {
    DocumentReference docRef = _courseCollectionInstance.doc(courseId);
    DocumentSnapshot ds = await docRef.get();
    return Course.fromJson(ds.data() as Map<String, dynamic>);
  }

  static Course create(Course course) {
    final DocumentReference docRef = _courseCollectionInstance.doc();
    course.id = docRef.id;
    docRef.set(course.toJson());
    return course;
  }

  static Future<void> updateClasses(ObjectSubmodel classObj, DocumentReference reference) async {
    DocumentSnapshot ds = await reference.get();
    Course course = Course.fromJson(ds.data() as Map<String, dynamic>);
    List<ObjectSubmodel> classes;
    if (course.classes == null) {
      classes = [];
    } else {
      classes = course.classes;
    }
    classes.add(classObj);
    reference.update({'classes': List<dynamic>.from(classes.map((c) => c.toJson()))});
  }

  static Future<List<Course>> getUserEnrolled(String userId) async {
    List<Course> coursesList = [];
    List<CourseEnrollment> coruseEnrollments = await CourseEnrollmentRepository.getUserCourseEnrollments(userId);
    for (CourseEnrollment courseEnrollment in coruseEnrollments) {
      final DocumentSnapshot ds = await courseEnrollment.course.reference.get();
      if (courseEnrollment.isUnenrolled != true) {
        coursesList.add(Course.fromJson(ds.data() as Map<String, dynamic>));
      }
    }
    return coursesList;
  }

  static Future<List<Course>> getByCourseEnrollments(List<CourseEnrollment> courseEnrollments) async {
    List<Course> courses = [];
    for (CourseEnrollment courseEnrollment in courseEnrollments) {
      DocumentSnapshot ds = await courseEnrollment.course.reference.get();
      if (courseEnrollment.isUnenrolled != true) {
        courses.add(Course.fromJson(ds.data() as Map<String, dynamic>));
      }
    }
    return courses;
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getCoursesSubscription() {
    Stream<QuerySnapshot<Map<String, dynamic>>> coursesStream =
        FirebaseFirestore.instance.collection('projects').doc(GlobalConfiguration().getString('projectId')).collection('courses').snapshots();
    return coursesStream;
  }

  static Future<CourseStatistics> getStatistics(DocumentReference reference) async {
    if (reference == null) {
      return null;
    }
    DocumentSnapshot docRef = await reference.get();

    if (!docRef.exists) {
      return null;
    }

    return CourseStatistics.fromJson(docRef.data() as Map<String, dynamic>);
  }

  static Future<CourseStatistics> getStatisticsById(String courseId) async {
    final DocumentReference reference =
        FirebaseFirestore.instance.collection('projects').doc(GlobalConfiguration().getString('projectId')).collection('courseStatistics').doc(courseId);
    final DocumentSnapshot ds = await reference.get();
    return CourseStatistics.fromJson(ds.data() as Map<String, dynamic>);
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> getStatisticsSubscription() {
    Stream<QuerySnapshot<Map<String, dynamic>>> statisticsStream =
        FirebaseFirestore.instance.collection('projects').doc(GlobalConfiguration().getString('projectId')).collection('courseStatistics').snapshots();
    return statisticsStream;
  }

  static Future<void> addSelfie(String courseId, String image) async {
    final DocumentReference reference =
        FirebaseFirestore.instance.collection('projects').doc(GlobalConfiguration().getString('projectId')).collection('courses').doc(courseId);
    final DocumentSnapshot ds = await reference.get();
    final Course courseObj = Course.fromJson(ds.data() as Map<String, dynamic>);
    final List<String> images = courseObj.userSelfies ?? [];
    images.add(image);
    await reference.update({'user_selfies': images});
  }
}
