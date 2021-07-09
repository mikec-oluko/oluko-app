import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:oluko_app/models/class.dart';
import 'package:oluko_app/models/course.dart';
import 'package:oluko_app/models/course_enrollment.dart';
import 'package:oluko_app/models/submodels/enrollment_class.dart';
import 'package:oluko_app/models/submodels/enrollment_segment.dart';
import 'package:oluko_app/models/submodels/object_submodel.dart';

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
          classId: classObj.id,
          className: classObj.name,
          classReference: classObj.reference,
          segments: []);
      enrollmentClass = await setEnrollmentSegments(enrollmentClass);
      courseEnrollment.classes.add(enrollmentClass);
    }
    return courseEnrollment;
  }

  static Future<EnrollmentClass> setEnrollmentSegments(
      EnrollmentClass enrollmentClass) async {
    DocumentSnapshot qs = await enrollmentClass.classReference.get();
    Class classObj = Class.fromJson(qs.data());
    classObj.segments.forEach((ObjectSubmodel segment) {
      enrollmentClass.segments.add(EnrollmentSegment(
          segmentId: segment.id,
          segmentName: segment.name,
          segmentReference: segment.reference));
    });
    return enrollmentClass;
  }
}
