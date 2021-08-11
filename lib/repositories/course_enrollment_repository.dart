import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:oluko_app/blocs/course_enrollment_bloc.dart';
import 'package:oluko_app/models/challenge.dart';
import 'package:oluko_app/models/class.dart';
import 'package:oluko_app/models/course.dart';
import 'package:oluko_app/models/course_enrollment.dart';
import 'package:oluko_app/models/submodels/enrollment_class.dart';
import 'package:oluko_app/models/submodels/enrollment_segment.dart';
import 'package:oluko_app/models/submodels/object_submodel.dart';
import 'package:oluko_app/models/submodels/segment_submodel.dart';
import 'package:oluko_app/repositories/course_repository.dart';
import 'package:oluko_app/services/course_enrollment_service.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

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

  static Future<CourseEnrollment> markSegmentAsCompleted(
      CourseEnrollment courseEnrollment,
      int segmentIndex,
      int classIndex) async {
    DocumentReference reference = FirebaseFirestore.instance
        .collection('projects')
        .doc(GlobalConfiguration().getValue("projectId"))
        .collection('courseEnrollments')
        .doc(courseEnrollment.id);
    List<EnrollmentClass> classes = courseEnrollment.classes;
    classes[classIndex].segments[segmentIndex].compleatedAt = Timestamp.now();

    bool isClassCompleted =
        CourseEnrollmentService.getFirstUncompletedSegmentIndex(
                classes[classIndex]) ==
            -1;
    if (isClassCompleted) {
      double courseProgress =
          1 / courseEnrollment.classes.length * (classIndex + 1);
      classes[classIndex].compleatedAt = Timestamp.now();
      courseEnrollment.completion = courseProgress;
    }
    reference.update({
      'classes': List<dynamic>.from(classes.map((c) => c.toJson())),
      'completion': courseEnrollment.completion
    });
  }

  static Future<CourseEnrollment> create(User user, Course course) async {
    CollectionReference reference = FirebaseFirestore.instance
        .collection('projects')
        .doc(GlobalConfiguration().getValue("projectId"))
        .collection('courseEnrollments');
    DocumentReference courseReference = FirebaseFirestore.instance
        .collection('projects')
        .doc(GlobalConfiguration().getValue("projectId"))
        .collection('courses')
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
    classObj.segments.forEach((SegmentSubmodel segment) {
      enrollmentClass.segments.add(EnrollmentSegment(
          id: segment.id, name: segment.name, reference: segment.reference));
    });
    return enrollmentClass;
  }

  static Future<List<CourseEnrollment>> getUserCourseEnrollments(
      String userId) async {
    List<CourseEnrollment> courseEnrollmentList = [];
    try {
      QuerySnapshot docRef = await FirebaseFirestore.instance
          .collection('projects')
          .doc(GlobalConfiguration().getValue("projectId"))
          .collection('courseEnrollments')
          .where('user_id', isEqualTo: userId)
          .get();

      if (docRef.docs.isEmpty) {
        return [];
      }

      docRef.docs.forEach((doc) {
        final Map<String, dynamic> course = doc.data();
        courseEnrollmentList.add(CourseEnrollment.fromJson(course));
      });
    } catch (e, stackTrace) {
      await Sentry.captureException(
        e,
        stackTrace: stackTrace,
      );
      throw e;
    }
    return courseEnrollmentList;
  }

  static getCourseByCourseEnrollmentId(String courseId) async {
    Course curso = await CourseRepository.get(courseId);
    return curso;
  }

  Future<List<Challenge>> getUserChallengesByUserId(String userId) async {
    List<Challenge> challengeList = [];
    List<CourseEnrollment> courseEnrollments =
        await getUserCourseEnrollments(userId);

    if (courseEnrollments == null) {
      return [];
    }
    try {
      var futures = <Future>[];
      for (var courseEnrollment in courseEnrollments) {
        futures.add(await getChallengesFromCourseEnrollment(
            courseEnrollment, challengeList));
      }
      Future.wait(futures);
    } catch (e, stackTrace) {
      await Sentry.captureException(
        e,
        stackTrace: stackTrace,
      );
      return [];
    }
    return challengeList;
  }

  Future getChallengesFromCourseEnrollment(
      CourseEnrollment courseEnrollment, List<Challenge> challenges) async {
    QuerySnapshot query = await FirebaseFirestore.instance
        .collection('projects')
        .doc(GlobalConfiguration().getValue("projectId"))
        .collection('challenges')
        // .where('course_enrollment_id', isEqualTo: courseEnrollment.id)
        .get();
    for (var challengeDoc in query.docs) {
      Map<String, dynamic> challenge = challengeDoc.data();
      challenges.add(Challenge.fromJson(challenge));
    }
  }
}
