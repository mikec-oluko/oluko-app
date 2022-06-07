import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:oluko_app/blocs/course/course_bloc.dart';
import 'package:oluko_app/helpers/enum_collection.dart';
import 'package:oluko_app/models/course.dart';
import 'package:oluko_app/models/course_enrollment.dart';
import 'package:oluko_app/models/course_statistics.dart';
import 'package:oluko_app/models/like.dart';
import 'package:oluko_app/models/submodels/object_submodel.dart';
import 'package:oluko_app/repositories/course_enrollment_repository.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

class CourseRepository {
  FirebaseFirestore firestoreInstance;

  CourseRepository() {
    firestoreInstance = FirebaseFirestore.instance;
  }

  CourseRepository.test({FirebaseFirestore firestoreInstance}) {
    this.firestoreInstance = firestoreInstance;
  }

  static final CollectionReference _courseCollectionInstance =
      FirebaseFirestore.instance.collection('projects').doc(GlobalConfiguration().getValue('projectId')).collection('courses');

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
    Stream<QuerySnapshot<Map<String, dynamic>>> coursesStream = FirebaseFirestore.instance
        .collection('projects')
        .doc(GlobalConfiguration().getValue('projectId'))
        .collection('courses')
        .snapshots();
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

  static Stream<QuerySnapshot<Map<String, dynamic>>> getStatisticsSubscription() {
    Stream<QuerySnapshot<Map<String, dynamic>>> statisticsStream = FirebaseFirestore.instance
        .collection('projects')
        .doc(GlobalConfiguration().getValue('projectId'))
        .collection('courseStatistics')
        .snapshots();
    return statisticsStream;
  }

  Future<Like> courseIsLiked({@required String courseId, @required String userId, bool isCheck = false}) async {
    final _likedCourseQuery = _courseCollectionInstance.doc(courseId).collection('likes').where('user_id', isEqualTo: userId);

    final Query<Map<String, dynamic>> docRef = isCheck ? _likedCourseQuery : _likedCourseQuery.where('is_active', isEqualTo: true);

    final QuerySnapshot courseLikeSnapshot = await docRef.get();
    if (courseLikeSnapshot.docs == null || courseLikeSnapshot.docs.isEmpty) {
      return null;
    }
    final _courseLikeDoc = courseLikeSnapshot.docs.first.data() as Map<String, dynamic>;
    final _courseLikeResponse = Like.fromJson(_courseLikeDoc);
    return _courseLikeResponse;
  }

  Future<Like> updateCourseLike(String userId, String courseId) async {
    try {
      Like _courseLiked = await courseIsLiked(courseId: courseId, userId: userId, isCheck: true);
      if (_courseLiked != null) {
        return _updateLikedCourse(courseId, _courseLiked);
      } else {
        return _createNewLikedCourse(courseId, userId);
      }
    } catch (e, stackTrace) {
      await Sentry.captureException(
        e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  Like _createNewLikedCourse(String courseId, String userId) {
    final CollectionReference _courseLikesReference = _courseCollectionInstance.doc(courseId).collection('likes');
    final DocumentReference _docRef = _courseLikesReference.doc();
    final DocumentReference _userReference = _getUserReference(userId);
    final DocumentReference _courseReference = _getCourseReference(courseId);

    final Like _newLikeElement = Like(
        id: _docRef.id,
        userId: userId,
        userReference: _userReference,
        entityId: courseId,
        entityReference: _courseReference,
        entityType: EntityTypeEnum.course,
        isActive: true);

    _docRef.set(_newLikeElement.toJson());
    return _newLikeElement;
  }

  Like _updateLikedCourse(String courseId, Like courseLiked) {
    final DocumentReference _courseLikedReference = _courseCollectionInstance.doc(courseId).collection('likes').doc(courseLiked.id);
    if (courseLiked.isActive) {
      courseLiked.isActive = false;
      _updateLikeValue(_courseLikedReference, courseLiked);
    } else {
      courseLiked.isActive = true;
      _updateLikeValue(_courseLikedReference, courseLiked);
    }
    return courseLiked;
  }

  void _updateLikeValue(DocumentReference<Object> courseLikedReference, Like courseLiked) {
    courseLikedReference.update({'updated_at': FieldValue.serverTimestamp(), 'is_active': courseLiked.isActive});
  }

  getCourseRecommendations(String userId, String courseId) async {
    try {
      final Query<Map<String, dynamic>> docRef =
          _courseCollectionInstance.doc(courseId).collection('recommendations').where('destination_user_id', isEqualTo: userId);
      final QuerySnapshot courseRecommendationsForUser = await docRef.get();
      if (courseRecommendationsForUser.docs == null || courseRecommendationsForUser.docs.isEmpty) {
        return null;
      }
      // final courseLikeDoc = courseLikeSnapshot.docs.first.data() as Map<String, dynamic>;
      // final courseLikeResponse = Like.fromJson(courseLikeDoc);
      // return courseLikeResponse;
    } catch (e) {}
  }

  setCourseRecommendedByUser(String originUserId, List<String> destinationUsers, Course courseRecommended) {}

  DocumentReference<Object> _getUserReference(String userRequestedId) {
    final DocumentReference userReference =
        firestoreInstance.collection('projects').doc(GlobalConfiguration().getValue('projectId')).collection('users').doc(userRequestedId);
    return userReference;
  }

  DocumentReference<Object> _getCourseReference(String courseId) {
    final DocumentReference courseReference =
        firestoreInstance.collection('projects').doc(GlobalConfiguration().getValue('projectId')).collection('courses').doc(courseId);
    return courseReference;
  }
}
