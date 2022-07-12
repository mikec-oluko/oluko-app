import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:oluko_app/models/submodels/enrollment_section.dart';
import 'package:oluko_app/models/submodels/section_submodel.dart';
import 'package:oluko_app/models/challenge.dart';
import 'package:oluko_app/models/class.dart';
import 'package:oluko_app/models/course.dart';
import 'package:oluko_app/models/course_enrollment.dart';
import 'package:oluko_app/models/submodels/enrollment_class.dart';
import 'package:oluko_app/models/submodels/enrollment_movement.dart';
import 'package:oluko_app/models/submodels/enrollment_segment.dart';
import 'package:oluko_app/models/submodels/movement_submodel.dart';
import 'package:oluko_app/models/submodels/object_submodel.dart';
import 'package:oluko_app/models/submodels/segment_submodel.dart';
import 'package:oluko_app/repositories/course_repository.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

class CourseEnrollmentRepository {
  FirebaseFirestore firestoreInstance;

  CourseEnrollmentRepository() {
    firestoreInstance = FirebaseFirestore.instance;
  }

  CourseEnrollmentRepository.test({this.firestoreInstance});

  static Future<CourseEnrollment> get(Course course, User user) async {
    final CollectionReference reference =
        FirebaseFirestore.instance.collection('projects').doc(GlobalConfiguration().getValue('projectId')).collection('courseEnrollments');

    final QuerySnapshot qs = await reference.where('course.id', isEqualTo: course.id).where('created_by', isEqualTo: user.uid).get();

    if (qs.docs.isNotEmpty) {
      if (qs.docs.length > 1) {
        final List<CourseEnrollment> _listOfCourseEnrollmentsForCourse = [];
        for (final doc in qs.docs) {
          _listOfCourseEnrollmentsForCourse.add(CourseEnrollment.fromJson(doc.data() as Map<String, dynamic>));
        }
        _listOfCourseEnrollmentsForCourse.sort((a, b) => b.createdAt.toDate().compareTo(a.createdAt.toDate()));
        return _listOfCourseEnrollmentsForCourse.first;
      } else {
        return CourseEnrollment.fromJson(qs.docs[0].data() as Map<String, dynamic>);
      }
    }
    return null;
  }

  static Future<CourseEnrollment> getById(String id) async {
    final CollectionReference reference =
        FirebaseFirestore.instance.collection('projects').doc(GlobalConfiguration().getValue('projectId')).collection('courseEnrollments');

    final QuerySnapshot qs = await reference.where('id', isEqualTo: id).get();

    if (qs.docs.isNotEmpty) {
      return CourseEnrollment.fromJson(qs.docs[0].data() as Map<String, dynamic>);
    }
    return null;
  }

  static Future<List<CourseEnrollment>> getByCourse(String courseId, String userId) async {
    try {
      final QuerySnapshot qs = await FirebaseFirestore.instance
          .collection('projects')
          .doc(GlobalConfiguration().getValue('projectId'))
          .collection('courseEnrollments')
          .where('course.id', isEqualTo: courseId)
          .where('created_by', isNotEqualTo: userId)
          .get();

      if (qs != null && qs.docs != null && qs.docs.isNotEmpty) {
        return qs.docs.map((courseData) {
          final data = courseData.data() as Map<String, dynamic>;
          return CourseEnrollment.fromJson(data);
        }).toList();
      }
    } catch (e) {
      return [];
    }

    return [];
  }

  static Future<void> markSegmentAsCompleted(CourseEnrollment courseEnrollment, int segmentIndex, int classIndex) async {
    final DocumentReference reference = FirebaseFirestore.instance
        .collection('projects')
        .doc(GlobalConfiguration().getValue('projectId'))
        .collection('courseEnrollments')
        .doc(courseEnrollment.id);
    final List<EnrollmentClass> classes = courseEnrollment.classes;
    classes[classIndex].segments[segmentIndex].completedAt = Timestamp.now();

    final bool isClassCompleted = segmentIndex == classes[classIndex].segments.length - 1;
    if (isClassCompleted) {
      if (classIndex == courseEnrollment.classes.length - 1) {
        courseEnrollment.completion = 1;
        courseEnrollment.isUnenrolled = true;
      } else {
        if (courseEnrollment.classes[classIndex].completedAt == null) {
          final double courseProgress = 1 / courseEnrollment.classes.length;
          courseEnrollment.completion += courseProgress;
        }
      }
      classes[classIndex].completedAt = Timestamp.now();
    }
    reference.update({
      'classes': List<dynamic>.from(classes.map((c) => c.toJson())),
      'completion': courseEnrollment.completion,
      'completed_at': FieldValue.serverTimestamp(),
      'is_unenrolled': courseEnrollment.isUnenrolled,
      'updated_at': FieldValue.serverTimestamp()
    });
  }

  static Future<CourseEnrollment> create(User user, Course course) async {
    final DocumentReference projectReference =
        FirebaseFirestore.instance.collection('projects').doc(GlobalConfiguration().getValue('projectId'));
    final CollectionReference reference = projectReference.collection('courseEnrollments');
    final DocumentReference courseReference = projectReference.collection('courses').doc(course.id);
    final DocumentReference docRef = reference.doc();
    final DocumentReference userReference = projectReference.collection('users').doc(user.uid);
    final ObjectSubmodel courseSubmodel = ObjectSubmodel(id: course.id, reference: courseReference, name: course.name, image: course.image);
    CourseEnrollment courseEnrollment =
        CourseEnrollment(createdBy: user.uid, userId: user.uid, userReference: userReference, course: courseSubmodel, classes: []);
    courseEnrollment.id = docRef.id;
    courseEnrollment = await setEnrollmentClasses(course, courseEnrollment);
    docRef.set(courseEnrollment.toJson());
    return courseEnrollment;
  }

  static Future<CourseEnrollment> setEnrollmentClasses(Course course, CourseEnrollment courseEnrollment) async {
    for (final ObjectSubmodel classObj in course.classes) {
      EnrollmentClass enrollmentClass =
          EnrollmentClass(id: classObj.id, name: classObj.name, image: classObj.image, reference: classObj.reference, segments: []);

      //enrollmentClass = await setEnrollmentSegments(enrollmentClass);
      courseEnrollment.classes.add(enrollmentClass);
    }
    return courseEnrollment;
  }

  static Future<EnrollmentClass> setEnrollmentSegments(EnrollmentClass enrollmentClass) async {
    final DocumentSnapshot qs = await enrollmentClass.reference.get();
    final Class classObj = Class.fromJson(qs.data() as Map<String, dynamic>);
    for (final segment in classObj.segments) {
      enrollmentClass.segments.add(
        EnrollmentSegment(
          id: segment.id,
          name: segment.name,
          reference: segment.reference,
          isChallenge: segment.isChallenge,
          image: segment.image,
          sections: getEnrollmentSections(segment),
        ),
      );
    }
    return enrollmentClass;
  }

  static List<EnrollmentSection> getEnrollmentSections(SegmentSubmodel segment) {
    final List<EnrollmentSection> sections = [];
    if (segment.sections != null) {
      for (final section in segment.sections) {
        sections.add(EnrollmentSection(movements: getEnrollmentMovements(section)));
      }
    }
    return sections;
  }

  static List<EnrollmentMovement> getEnrollmentMovements(SectionSubmodel section) {
    final List<EnrollmentMovement> movements = [];
    for (final movement in section.movements) {
      movements.add(EnrollmentMovement(id: movement.id, reference: movement.reference, name: movement.name));
    }
    return movements;
  }

  static Future<List<CourseEnrollment>> getUserCourseEnrollments(String userId) async {
    final List<CourseEnrollment> courseEnrollmentList = [];
    try {
      final QuerySnapshot docRef = await FirebaseFirestore.instance
          .collection('projects')
          .doc(GlobalConfiguration().getValue('projectId'))
          .collection('courseEnrollments')
          .where('created_by', isEqualTo: userId)
          .orderBy('created_at', descending: true)
          .get();

      if (docRef.docs.isEmpty) {
        return [];
      }

      for (final doc in docRef.docs) {
        final Map<String, dynamic> course = doc.data() as Map<String, dynamic>;
        final CourseEnrollment courseEnrollment = CourseEnrollment.fromJson(course);
        if (courseEnrollment.completion < 1) {
          courseEnrollmentList.add(courseEnrollment);
        }
      }
    } catch (e, stackTrace) {
      await Sentry.captureException(
        e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
    return courseEnrollmentList;
  }

  static Future<Course> getCourseByCourseEnrollmentId(String courseId) async {
    final Course curso = await CourseRepository.get(courseId);
    return curso;
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> getUserChallengesByUserIdSubscription(String userId) {
    final Stream<QuerySnapshot<Map<String, dynamic>>> challengesStream = FirebaseFirestore.instance
        .collection('projects')
        .doc(GlobalConfiguration().getValue('projectId'))
        .collection('challenges')
        .where('user.id', isEqualTo: userId)
        .where('is_active', isEqualTo: true)
        .where('completed_at', isEqualTo: null)
        .snapshots();

    return challengesStream;
  }

  Future<List<Challenge>> getUserChallengesByUserId(String userId) async {
    final List<Challenge> challengeList = [];
    final List<CourseEnrollment> courseEnrollments = await getUserCourseEnrollments(userId);

    if (courseEnrollments == null) {
      return [];
    }
    try {
      for (final courseEnrollment in courseEnrollments) {
        if (courseEnrollment.isUnenrolled == false || courseEnrollment.isUnenrolled == null) {
          await getChallengesFromCourseEnrollment(courseEnrollment, challengeList);
        }
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
    final QuerySnapshot query = await FirebaseFirestore.instance
        .collection('projects')
        .doc(GlobalConfiguration().getValue('projectId'))
        .collection('challenges')
        .where('course_enrollment_id', isEqualTo: courseEnrollment.id)
        .get();
    for (final challengeDoc in query.docs) {
      final Map<String, dynamic> challenge = challengeDoc.data() as Map<String, dynamic>;
      final Challenge newChallenge = Challenge.fromJson(challenge);
      if (challenges.where((challenge) => challenge.classId == newChallenge.classId).isEmpty) {
        challenges.add(newChallenge);
      }
    }
  }

  static Future<void> saveMovementCounter(
    CourseEnrollment courseEnrollment,
    int segmentIndex,
    int classIndex,
    int sectionIndex,
    MovementSubmodel movement,
    int totalRounds,
    int currentRound,
    int counter,
  ) async {
    final DocumentReference reference = FirebaseFirestore.instance
        .collection('projects')
        .doc(GlobalConfiguration().getValue('projectId'))
        .collection('courseEnrollments')
        .doc(courseEnrollment.id);

    final List<EnrollmentClass> classes = courseEnrollment.classes;

    final List<EnrollmentMovement> movements = classes[classIndex].segments[segmentIndex].sections[sectionIndex].movements;

    for (final mov in movements) {
      if (mov.id == movement.id) {
        mov.counters ??= List<int>.filled(totalRounds, 0);
        mov.counters[currentRound] = counter;
        break;
      }
    }

    reference.update({'classes': List<dynamic>.from(classes.map((c) => c.toJson()))});
  }

  static Future<CourseEnrollment> updateSelfie(
    CourseEnrollment courseEnrollment,
    int classIndex,
    String thumbnailUrl,
    String miniThumbnailUrl,
  ) async {
    final DocumentReference reference = FirebaseFirestore.instance
        .collection('projects')
        .doc(GlobalConfiguration().getValue('projectId'))
        .collection('courseEnrollments')
        .doc(courseEnrollment.id);
    courseEnrollment.classes[classIndex].selfieThumbnailUrl = thumbnailUrl;
    courseEnrollment.classes[classIndex].miniSelfieThumbnailUrl = miniThumbnailUrl;

    reference.update({
      'classes': List<dynamic>.from(courseEnrollment.classes.map((c) => c.toJson())),
    });

    return courseEnrollment;
  }

  static Future<CourseEnrollment> markCourseEnrollmentAsUnenrolled(CourseEnrollment courseEnrollment, {bool isUnenrolled}) async {
    try {
      final DocumentReference courseEnrollmentReference = FirebaseFirestore.instance
          .collection('projects')
          .doc(GlobalConfiguration().getValue('projectId'))
          .collection('courseEnrollments')
          .doc(courseEnrollment.id);

      courseEnrollment.isUnenrolled = isUnenrolled;

      await courseEnrollmentReference.update(courseEnrollment.toJson());
      return courseEnrollment;
    } catch (e, stackTrace) {
      await Sentry.captureException(
        e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> getUserCourseEnrollmentsSubscription(String userId) {
    final Stream<QuerySnapshot<Map<String, dynamic>>> courseEnrollmentsStream = FirebaseFirestore.instance
        .collection('projects')
        .doc(GlobalConfiguration().getValue('projectId'))
        .collection('courseEnrollments')
        .where('created_by', isEqualTo: userId)
        .orderBy('created_at', descending: true)
        .snapshots();
    return courseEnrollmentsStream;
  }

  static Future<void> saveSectionStopwatch(CourseEnrollment courseEnrollment, int segmentIndex, int classIndex, int sectionIndex,
      int totalRounds, int currentRound, int stopwatch) async {
    final DocumentReference reference = FirebaseFirestore.instance
        .collection('projects')
        .doc(GlobalConfiguration().getValue('projectId'))
        .collection('courseEnrollments')
        .doc(courseEnrollment.id);

    final List<EnrollmentClass> classes = courseEnrollment.classes;

    final EnrollmentSection section = classes[classIndex].segments[segmentIndex].sections[sectionIndex];

    if (section.stopwatchs == null) {
      section.stopwatchs = List<int>.filled(totalRounds, 0);
    }
    section.stopwatchs[currentRound] = stopwatch;

    reference.update({'classes': List<dynamic>.from(classes.map((c) => c.toJson()))});
  }

  static Future<List<CourseEnrollment>> getByActiveCourse(String courseId, String userId) async {
    final CollectionReference reference =
        FirebaseFirestore.instance.collection('projects').doc(GlobalConfiguration().getValue('projectId')).collection('courseEnrollments');

    final QuerySnapshot qs = await reference.where('course.id', isEqualTo: courseId).where('is_unenrolled', isNotEqualTo: true).get();

    if (qs.docs.isNotEmpty) {
      return qs.docs.map((courseData) {
        final data = courseData.data() as Map<String, dynamic>;
        return CourseEnrollment.fromJson(data);
      }).toList();
    }
    return [];
  }
}
