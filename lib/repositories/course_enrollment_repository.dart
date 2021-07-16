import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:mvt_fitness/models/challenge.dart';
import 'package:mvt_fitness/models/class.dart';
import 'package:mvt_fitness/models/course.dart';
import 'package:mvt_fitness/models/course_enrollment.dart';
import 'package:mvt_fitness/models/submodels/enrollment_class.dart';
import 'package:mvt_fitness/models/submodels/enrollment_segment.dart';
import 'package:mvt_fitness/models/submodels/object_submodel.dart';
import 'package:mvt_fitness/repositories/course_repository.dart';

class CourseEnrollmentRepository {
  FirebaseFirestore firestoreInstance;

  CourseEnrollmentRepository() {
    firestoreInstance = FirebaseFirestore.instance;
  }

  CourseEnrollmentRepository.test({FirebaseFirestore firestoreInstance}) {
    this.firestoreInstance = firestoreInstance;
  }

  static Future<CourseEnrollment> get(Course course, User user) async {
    CollectionReference reference = FirebaseFirestore.instance
        .collection('projects')
        .doc(GlobalConfiguration().getValue("projectId"))
        .collection('courseEnrollments');

    final QuerySnapshot qs = await reference
        .where("course_id", isEqualTo: course.id)
        .where("user_id", isEqualTo: user.uid)
        .get();

    if (qs.docs.length > 0) {
      return CourseEnrollment.fromJson(qs.docs[0].data());
    }
    return null;
  }

  static Future<CourseEnrollment> create(User user, Course course) async {
    CollectionReference reference = FirebaseFirestore.instance
        .collection('projects')
        .doc(GlobalConfiguration().getValue("projectId"))
        .collection('courseEnrollments');
    DocumentReference courseReference = FirebaseFirestore.instance
        .collection('projects')
        .doc(GlobalConfiguration().getValue("projectId"))
        .collection('course')
        .doc(course.id);
    final DocumentReference docRef = reference.doc();
    DocumentReference userReference =
        FirebaseFirestore.instance.collection('users').doc(user.uid);
    CourseEnrollment courseEnrollment = CourseEnrollment(
        userId: user.uid,
        userReference: userReference,
        courseId: course.id,
        courseReference: courseReference,
        classes: []);
    courseEnrollment.id = docRef.id;
    courseEnrollment = await setEnrollmentClasses(course, courseEnrollment);
    docRef.set(courseEnrollment.toJson());
    return courseEnrollment;
  }

  static Future<CourseEnrollment> setEnrollmentClasses(
      Course course, CourseEnrollment courseEnrollment) async {
    for (ObjectSubmodel classObj in course.classes) {
      EnrollmentClass enrollmentClass = EnrollmentClass(
          id: classObj.id,
          name: classObj.name,
          reference: classObj.reference,
          segments: []);
      enrollmentClass = await setEnrollmentSegments(enrollmentClass);
      courseEnrollment.classes.add(enrollmentClass);
    }
    return courseEnrollment;
  }

  static Future<EnrollmentClass> setEnrollmentSegments(
      EnrollmentClass enrollmentClass) async {
    DocumentSnapshot qs = await enrollmentClass.reference.get();
    Class classObj = Class.fromJson(qs.data());
    classObj.segments.forEach((ObjectSubmodel segment) {
      enrollmentClass.segments.add(EnrollmentSegment(
          id: segment.id, name: segment.name, reference: segment.reference));
    });
    return enrollmentClass;
  }

  static Future<List<CourseEnrollment>> getUserCourseEnrollments(
      String userId) async {
    QuerySnapshot docRef = await FirebaseFirestore.instance
        .collection('projects')
        .doc(GlobalConfiguration().getValue("projectId"))
        .collection('courseEnrollments')
        .where('user_id', isEqualTo: userId)
        .get();

    //TODO: Use courseEnrollment.courseReference to get Course
    if (docRef.docs.isEmpty) {
      return null;
    }
    // var result = docRef.docs[0].data();
    // final courseEnroll = CourseEnrollment.fromJson(result);

    List<CourseEnrollment> courseEnrollmentList = [];
    docRef.docs.forEach((doc) {
      final Map<String, dynamic> course = doc.data();
      courseEnrollmentList.add(CourseEnrollment.fromJson(course));
    });
    return courseEnrollmentList;
  }

  static getCourseByCourseEnrollmentId(String courseId) async {
    Course curso = await CourseRepository.get(courseId);
    return curso;
  }

  static Future<List<Course>> getUserCourseEnrollmentsCourse(
      String userId) async {
    List<CourseEnrollment> listOfCoruseEnrollment =
        await getUserCourseEnrollments(userId);

    List<Course> coursesList = [];
    if (listOfCoruseEnrollment != null) {
      listOfCoruseEnrollment.forEach((courseEnrollment) async {
        final Course course =
            await getCourseByCourseEnrollmentId(courseEnrollment.courseId);
        coursesList.add(course);
      });
    }
    return coursesList;
  }

  Future<List<Challenge>> getUserChallengesuserId(String userId) async {
    List<CourseEnrollment> courseEnrollmentId =
        await getUserCourseEnrollments(userId);
    if (courseEnrollmentId == null) return [];
    QuerySnapshot docRef = await FirebaseFirestore.instance
        .collection('projects')
        .doc(GlobalConfiguration().getValue("projectId"))
        .collection('challenges')
        .where('course_enrollment_id', isEqualTo: courseEnrollmentId[0].id)
        .get();

    // List<Challenge> listOfChallenges = docRef.docs[0].data();
    // return listOfChallenges;

    List<Challenge> challengeList = [];
    docRef.docs.forEach((doc) {
      final Map<String, dynamic> challenge = doc.data();
      challengeList.add(Challenge.fromJson(challenge));
    });
    return challengeList;
  }
}
