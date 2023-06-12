import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:oluko_app/models/dto/completion_dto.dart';
import 'package:oluko_app/models/movement.dart';
import 'package:oluko_app/models/segment.dart';
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
import 'package:oluko_app/models/utils/weight_helper.dart';
import 'package:oluko_app/repositories/course_repository.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:oluko_app/utils/schedule_utils.dart';

class CourseEnrollmentRepository {
  FirebaseFirestore firestoreInstance;

  CourseEnrollmentRepository() {
    firestoreInstance = FirebaseFirestore.instance;
  }

  CourseEnrollmentRepository.test({this.firestoreInstance});

  static Future<CourseEnrollment> get(Course course, String userId) async {
    final CollectionReference reference =
        FirebaseFirestore.instance.collection('projects').doc(GlobalConfiguration().getString('projectId')).collection('courseEnrollments');

    final Query<Object> userEnrollments = reference.where('created_by', isEqualTo: userId);
    final QuerySnapshot qs = await userEnrollments.where('course.id', isEqualTo: course.id).get();

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

  Stream<QuerySnapshot<Map<String, dynamic>>> getCourseEnrollmentStream(String userId) {
    Stream<QuerySnapshot<Map<String, dynamic>>> courseEnrollmentStream = firestoreInstance
        .collection('projects')
        .doc(GlobalConfiguration().getString('projectId'))
        .collection('courseEnrollments')
        .where('created_by', isEqualTo: userId)
        .snapshots(includeMetadataChanges: true);
    return courseEnrollmentStream;
  }

  static Future<CourseEnrollment> getById(String id) async {
    final CollectionReference reference =
        FirebaseFirestore.instance.collection('projects').doc(GlobalConfiguration().getString('projectId')).collection('courseEnrollments');

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
          .doc(GlobalConfiguration().getString('projectId'))
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

  static Future<Completion> markSegmentAsCompleted(CourseEnrollment courseEnrollment, int segmentIndex, int classIndex,
      {bool useWeigth = false, int sectionIndex, int movementIndex, double weightUsed}) async {
    Completion completionObj = Completion();
    final DocumentReference reference = FirebaseFirestore.instance
        .collection('projects')
        .doc(GlobalConfiguration().getString('projectId'))
        .collection('courseEnrollments')
        .doc(courseEnrollment.id);
    final List<EnrollmentClass> classes = courseEnrollment.classes;
    classes[classIndex].segments[segmentIndex].completedAt = Timestamp.now();
    if (useWeigth) {
      classes[classIndex].segments[segmentIndex].sections[sectionIndex].movements[movementIndex].weight = weightUsed;
    }

    final bool isClassCompleted = segmentIndex == classes[classIndex].segments.length - 1;
    if (isClassCompleted) {
      completionObj.completedClassId = classes[classIndex].id;
      if (classIndex == courseEnrollment.classes.length - 1) {
        courseEnrollment.completion = 1;
        courseEnrollment.isUnenrolled = true;
        completionObj.completedCourseId = courseEnrollment.course.reference.id;
      } else {
        if (courseEnrollment.classes[classIndex].completedAt == null) {
          final double courseProgress = 1 / courseEnrollment.classes.length;
          courseEnrollment.completion += courseProgress;
        }
      }
      classes[classIndex].completedAt = Timestamp.now();
      ScheduleUtils.reScheduleClasses(classes, courseEnrollment.weekDays, classIndex);
    }
    reference.update({
      'classes': List<dynamic>.from(classes.map((c) => c.toJson())),
      'completion': courseEnrollment.completion,
      'completed_at': FieldValue.serverTimestamp(),
      'is_unenrolled': courseEnrollment.isUnenrolled is bool ? courseEnrollment.isUnenrolled : false,
      'updated_at': FieldValue.serverTimestamp()
    });
    return completionObj;
  }

  static Future<void> addWeightToWorkout({@required CourseEnrollment currentCourseEnrollment, List<WorkoutWeight> movementsAndWeights}) async {
    final DocumentReference courseEnrollmentReference = FirebaseFirestore.instance
        .collection('projects')
        .doc(GlobalConfiguration().getString('projectId'))
        .collection('courseEnrollments')
        .doc(currentCourseEnrollment.id);

    movementsAndWeights.forEach((workoutElement) {
      final EnrollmentMovement movementForUpdate = getActualMovementToUpdate(currentCourseEnrollment, workoutElement);
      setNewWeightForEnrollmentMovement(currentCourseEnrollment, workoutElement, movementForUpdate);
    });
    courseEnrollmentReference.update({
      'classes': List<dynamic>.from(currentCourseEnrollment.classes.map((c) => c.toJson())),
    });
  }

  static Future<CourseEnrollment> create(User user, Course course) async {
    final DocumentReference projectReference = FirebaseFirestore.instance.collection('projects').doc(GlobalConfiguration().getString('projectId'));
    final CollectionReference reference = projectReference.collection('courseEnrollments');
    final DocumentReference courseReference = projectReference.collection('courses').doc(course.id);
    final DocumentReference docRef = reference.doc();
    final DocumentReference userReference = projectReference.collection('users').doc(user.uid);
    final ObjectSubmodel courseSubmodel = ObjectSubmodel(id: course.id, reference: courseReference, name: course.name, image: course.image);
    CourseEnrollment courseEnrollment =
        CourseEnrollment(createdBy: user.uid, userId: user.uid, userReference: userReference, course: courseSubmodel, classes: [], weekDays: course.weekDays);
    courseEnrollment.id = docRef.id;
    courseEnrollment = await setEnrollmentClasses(course, courseEnrollment);
    await docRef.set(courseEnrollment.toJson());
    return courseEnrollment;
  }

  static Future<CourseEnrollment> scheduleCourse(CourseEnrollment enrolledCourse) async {
    final DocumentReference projectReference = FirebaseFirestore.instance.collection('projects').doc(GlobalConfiguration().getString('projectId'));
    final CollectionReference reference = projectReference.collection('courseEnrollments');
    final DocumentReference docRef = reference.doc(enrolledCourse.id);
    await docRef.set(enrolledCourse.toJson(), SetOptions(merge: true));
    return enrolledCourse;
  }

  static Future<CourseEnrollment> setEnrollmentClasses(Course course, CourseEnrollment courseEnrollment) async {
    final enrollmentClasses = List.generate(
      course.classes.length,
      (i) => EnrollmentClass(
        id: course.classes[i].id,
        name: course.classes[i].name,
        image: course.classes[i].image,
        reference: course.classes[i].reference,
        segments: [],
        scheduledDate: course.scheduledDates != null && course.scheduledDates.isNotEmpty ? Timestamp.fromDate(course.scheduledDates[i]) : null,
      ),
    );

    await Future.wait(enrollmentClasses.map((enrollmentClass) async {
      await setEnrollmentSegments(enrollmentClass);
    }));

    courseEnrollment.classes.addAll(enrollmentClasses);
    return courseEnrollment;
  }

  static Future<EnrollmentClass> setEnrollmentSegments(EnrollmentClass enrollmentClass) async {
    final DocumentSnapshot qs = await enrollmentClass.reference.get();
    final Class classObj = Class.fromJson(qs.data() as Map<String, dynamic>);

    final enrollmentSegments = await Future.wait(List.generate(classObj.segments.length, (index) async {
      final SegmentSubmodel segment = classObj.segments[index];
      final DocumentSnapshot currentSegmentData = await segment.reference.get();
      final Segment segmentInfo = Segment.fromJson(currentSegmentData.data() as Map<String, dynamic>);
      final sections = await getEnrollmentSections(segment);
      return EnrollmentSegment(
        id: segment.id,
        name: segment.name,
        reference: segment.reference,
        isChallenge: segment.isChallenge,
        setsMaxWeight: segmentInfo.setMaxWeights,
        image: segment.image,
        sections: sections,
      );
    }));

    enrollmentClass.segments.addAll(enrollmentSegments);
    return enrollmentClass;
  }

  static Future<List<EnrollmentSection>> getEnrollmentSections(SegmentSubmodel segment) async {
    final List<EnrollmentSection> sections = [];
    if (segment.sections != null) {
      for (final section in segment.sections) {
        final movements = await getEnrollmentMovements(section);
        sections.add(EnrollmentSection(movements: movements));
      }
    }
    return sections;
  }

  static Future<List<EnrollmentMovement>> getEnrollmentMovements(SectionSubmodel section) async {
    final List<EnrollmentMovement> movements = [];
    bool storeWeight = false;
    int percentOfMaxWeight;
    final promises = section.movements.map((movementFromEnrollmentSegment) async {
      if (movementFromEnrollmentSegment.reference != null) {
        final DocumentSnapshot qs = await movementFromEnrollmentSegment.reference.get();
        final Movement movement = Movement.fromJson(qs.data() as Map<String, dynamic>);
        storeWeight = movement.storeWeight;
        percentOfMaxWeight = movementFromEnrollmentSegment.percentOfMaxWeight;
      }
      movements.add(EnrollmentMovement(
          id: movementFromEnrollmentSegment.id,
          reference: movementFromEnrollmentSegment.reference,
          name: movementFromEnrollmentSegment.name,
          weight: null,
          storeWeight: storeWeight,
          percentOfMaxWeight: percentOfMaxWeight));
    });
    await Future.wait(promises);
    return movements;
  }

  static Future<List<CourseEnrollment>> getUserCourseEnrollments(String userId) async {
    final List<CourseEnrollment> courseEnrollmentList = [];
    try {
      final QuerySnapshot docRef = await FirebaseFirestore.instance
          .collection('projects')
          .doc(GlobalConfiguration().getString('projectId'))
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
        .doc(GlobalConfiguration().getString('projectId'))
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
        .doc(GlobalConfiguration().getString('projectId'))
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
        .doc(GlobalConfiguration().getString('projectId'))
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
        .doc(GlobalConfiguration().getString('projectId'))
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
          .doc(GlobalConfiguration().getString('projectId'))
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
        .doc(GlobalConfiguration().getString('projectId'))
        .collection('courseEnrollments')
        .where('created_by', isEqualTo: userId)
        .where('is_unenrolled', isEqualTo: false)
        .orderBy('created_at', descending: true)
        .snapshots();
    return courseEnrollmentsStream;
  }

  static Future<void> saveSectionStopwatch(
      CourseEnrollment courseEnrollment, int segmentIndex, int classIndex, int sectionIndex, int totalRounds, int currentRound, int stopwatch) async {
    final DocumentReference reference = FirebaseFirestore.instance
        .collection('projects')
        .doc(GlobalConfiguration().getString('projectId'))
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
        FirebaseFirestore.instance.collection('projects').doc(GlobalConfiguration().getString('projectId')).collection('courseEnrollments');

    final QuerySnapshot qs = await reference.where('course.id', isEqualTo: courseId).where('is_unenrolled', isNotEqualTo: true).get();

    if (qs.docs.isNotEmpty) {
      return qs.docs.map((courseData) {
        final data = courseData.data() as Map<String, dynamic>;
        return CourseEnrollment.fromJson(data);
      }).toList();
    }
    return [];
  }

  static void setNewWeightForEnrollmentMovement(
      CourseEnrollment currentCourseEnrollment, WorkoutWeight workoutElement, EnrollmentMovement movementForUpdateWeight) {
    currentCourseEnrollment
        .classes[workoutElement.classIndex]
        .segments[workoutElement.segmentIndex]
        .sections[workoutElement.sectionIndex]
        .movements[currentCourseEnrollment
            .classes[workoutElement.classIndex].segments[workoutElement.segmentIndex].sections[workoutElement.sectionIndex].movements
            .indexOf(movementForUpdateWeight)]
        .weight = workoutElement.weight.toDouble();
  }

  static EnrollmentMovement getActualMovementToUpdate(CourseEnrollment currentCourseEnrollment, WorkoutWeight workoutElement) {
    return currentCourseEnrollment.classes[workoutElement.classIndex].segments[workoutElement.segmentIndex].sections[workoutElement.sectionIndex].movements
        .where((movement) => movement.id == workoutElement.movementId)
        .first;
  }
}
