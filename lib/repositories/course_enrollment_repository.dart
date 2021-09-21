import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:oluko_app/helpers/s3_provider.dart';
import 'package:oluko_app/models/challenge.dart';
import 'package:oluko_app/models/class.dart';
import 'package:oluko_app/models/course.dart';
import 'package:oluko_app/models/course_enrollment.dart';
import 'package:oluko_app/models/submodels/counter.dart';
import 'package:oluko_app/models/submodels/enrollment_class.dart';
import 'package:oluko_app/models/submodels/enrollment_movement.dart';
import 'package:oluko_app/models/submodels/enrollment_segment.dart';
import 'package:oluko_app/models/submodels/movement_submodel.dart';
import 'package:oluko_app/models/submodels/object_submodel.dart';
import 'package:oluko_app/models/submodels/segment_submodel.dart';
import 'package:oluko_app/repositories/course_repository.dart';
import 'package:oluko_app/services/course_enrollment_service.dart';
import 'package:oluko_app/utils/image_utils.dart';
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
        .doc(GlobalConfiguration().getValue('projectId'))
        .collection('courseEnrollments');

    final QuerySnapshot qs =
        await reference.where('course.id', isEqualTo: course.id).where('created_by', isEqualTo: user.uid).get();

    if (qs.docs.length > 0) {
      return CourseEnrollment.fromJson(qs.docs[0].data() as Map<String, dynamic>);
    }
    return null;
  }

  static Future<List<CourseEnrollment>> getByCourse(String courseId, String userId) async {
    CollectionReference reference = FirebaseFirestore.instance
        .collection('projects')
        .doc(GlobalConfiguration().getValue('projectId'))
        .collection('courseEnrollments');

    final QuerySnapshot qs = await reference.where('course.id', isEqualTo: courseId).where('created_by', isNotEqualTo: userId).get();

    if (qs.docs.length > 0) {
      return qs.docs.map((courseData) {
        var data = courseData.data() as Map<String, dynamic>;
        return CourseEnrollment.fromJson(data);
      }).toList();
    }
    return null;
  }

  static Future<CourseEnrollment> markSegmentAsCompleted(
      CourseEnrollment courseEnrollment, int segmentIndex, int classIndex) async {
    DocumentReference reference = FirebaseFirestore.instance
        .collection('projects')
        .doc(GlobalConfiguration().getValue('projectId'))
        .collection('courseEnrollments')
        .doc(courseEnrollment.id);
    List<EnrollmentClass> classes = courseEnrollment.classes;
    classes[classIndex].segments[segmentIndex].compleatedAt = Timestamp.now();

    bool isClassCompleted = CourseEnrollmentService.getFirstUncompletedSegmentIndex(classes[classIndex]) == -1;
    if (isClassCompleted) {
      double courseProgress = 1 / courseEnrollment.classes.length * (classIndex + 1);
      classes[classIndex].compleatedAt = Timestamp.now();
      courseEnrollment.completion = courseProgress;
    }
    reference.update(
        {'classes': List<dynamic>.from(classes.map((c) => c.toJson())), 'completion': courseEnrollment.completion});
  }

  static Future<CourseEnrollment> create(User user, Course course) async {
    DocumentReference projectReference =
        FirebaseFirestore.instance.collection('projects').doc(GlobalConfiguration().getValue('projectId'));
    CollectionReference reference = projectReference.collection('courseEnrollments');
    DocumentReference courseReference = projectReference.collection('courses').doc(course.id);
    final DocumentReference docRef = reference.doc();
    DocumentReference userReference = projectReference.collection('users').doc(user.uid);
    ObjectSubmodel courseSubmodel =
        ObjectSubmodel(id: course.id, reference: courseReference, name: course.name, image: course.image);
    CourseEnrollment courseEnrollment =
        CourseEnrollment(createdBy: user.uid, userReference: userReference, course: courseSubmodel, classes: []);
    courseEnrollment.id = docRef.id;
    courseEnrollment = await setEnrollmentClasses(course, courseEnrollment);
    docRef.set(courseEnrollment.toJson());
    return courseEnrollment;
  }

  static Future<CourseEnrollment> setEnrollmentClasses(Course course, CourseEnrollment courseEnrollment) async {
    for (ObjectSubmodel classObj in course.classes) {
      EnrollmentClass enrollmentClass = EnrollmentClass(
          id: classObj.id, name: classObj.name, image: classObj.image, reference: classObj.reference, segments: []);
      enrollmentClass = await setEnrollmentSegments(enrollmentClass);
      courseEnrollment.classes.add(enrollmentClass);
    }
    return courseEnrollment;
  }

  static Future<EnrollmentClass> setEnrollmentSegments(EnrollmentClass enrollmentClass) async {
    DocumentSnapshot qs = await enrollmentClass.reference.get();
    Class classObj = Class.fromJson(qs.data() as Map<String, dynamic>);
    classObj.segments.forEach((SegmentSubmodel segment) {
      enrollmentClass.segments.add(EnrollmentSegment(id: segment.id, name: segment.name, reference: segment.reference));
    });
    return enrollmentClass;
  }

  static Future<List<CourseEnrollment>> getUserCourseEnrollments(String userId) async {
    List<CourseEnrollment> courseEnrollmentList = [];
    try {
      QuerySnapshot docRef = await FirebaseFirestore.instance
          .collection('projects')
          .doc(GlobalConfiguration().getValue('projectId'))
          .collection('courseEnrollments')
          .where('created_by', isEqualTo: userId)
          .orderBy('created_at', descending: true)
          .get();

      if (docRef.docs.isEmpty) {
        return [];
      }

      docRef.docs.forEach((doc) {
        final Map<String, dynamic> course = doc.data() as Map<String, dynamic>;
        courseEnrollmentList.add(CourseEnrollment.fromJson(course));
      });
    } catch (e, stackTrace) {
      await Sentry.captureException(
        e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
    return courseEnrollmentList;
  }

  static getCourseByCourseEnrollmentId(String courseId) async {
    Course curso = await CourseRepository.get(courseId);
    return curso;
  }

  Future<List<Challenge>> getUserChallengesByUserId(String userId) async {
    List<Challenge> challengeList = [];
    List<CourseEnrollment> courseEnrollments = await getUserCourseEnrollments(userId);

    if (courseEnrollments == null) {
      return [];
    }
    try {
      for (var courseEnrollment in courseEnrollments) {
        await getChallengesFromCourseEnrollment(courseEnrollment, challengeList);
      }
    } catch (e, stackTrace) {
      await Sentry.captureException(
        e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
    return challengeList;
  }

  Future getChallengesFromCourseEnrollment(CourseEnrollment courseEnrollment, List<Challenge> challenges) async {
    QuerySnapshot query = await FirebaseFirestore.instance
        .collection('projects')
        .doc(GlobalConfiguration().getValue('projectId'))
        .collection('challenges')
        // .where('course_enrollment_id', isEqualTo: courseEnrollment.id)
        .get();
    for (var challengeDoc in query.docs) {
      Map<String, dynamic> challenge = challengeDoc.data() as Map<String, dynamic>;
      challenges.add(Challenge.fromJson(challenge));
    }
  }

  static Future<CourseEnrollment> saveMovementCounter(CourseEnrollment courseEnrollment, int segmentIndex,
      int classIndex, MovementSubmodel movement, Counter counter) async {
    DocumentReference reference = FirebaseFirestore.instance
        .collection('projects')
        .doc(GlobalConfiguration().getValue('projectId'))
        .collection('courseEnrollments')
        .doc(courseEnrollment.id);

    EnrollmentMovement enrollmentMovement =
        EnrollmentMovement(id: movement.id, reference: movement.reference, name: movement.name, counter: counter);
    List<EnrollmentClass> classes = courseEnrollment.classes;
    List<EnrollmentMovement> movements = classes[classIndex].segments[segmentIndex].movements;

    if (movements == null || counter.round == 1) {
      classes[classIndex].segments[segmentIndex].movements = [];
    }

    classes[classIndex].segments[segmentIndex].movements.add(enrollmentMovement);

    reference.update({'classes': List<dynamic>.from(classes.map((c) => c.toJson()))});
  }

  static Future<CourseEnrollment> updateSelfie(
      CourseEnrollment courseEnrollment, int classIndex, PickedFile file) async {
    DocumentReference reference = FirebaseFirestore.instance
        .collection('projects')
        .doc(GlobalConfiguration().getValue("projectId"))
        .collection('courseEnrollments')
        .doc(courseEnrollment.id);

    final thumbnail = await ImageUtils().getThumbnailForImage(file, 250);
    final thumbnailUrl = await _uploadFile(thumbnail, '${reference.path}/class' + classIndex.toString());
    final downloadUrl = await _uploadFile(file.path, reference.path);

    courseEnrollment.classes[classIndex].selfieDownloadUrl = downloadUrl;
    courseEnrollment.classes[classIndex].selfieThumbnailUrl = thumbnailUrl;

    reference.update({
      'classes': List<dynamic>.from(courseEnrollment.classes.map((c) => c.toJson())),
    });

    return courseEnrollment;
  }

  static Future<String> _uploadFile(String filePath, String folderName) async {
    final file = File(filePath);

    final basename = p.basename(filePath);

    final S3Provider s3Provider = S3Provider();
    String downloadUrl = await s3Provider.putFile(file.readAsBytesSync(), folderName, basename);

    return downloadUrl;
  }
}
