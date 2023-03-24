import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:oluko_app/helpers/enum_collection.dart';
import 'package:oluko_app/models/like.dart';
import 'package:oluko_app/models/recommendation.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

class CourseUserInteractionRepository {
  FirebaseFirestore firestoreInstance;

  CourseUserInteractionRepository() {
    firestoreInstance = FirebaseFirestore.instance;
  }

  CourseUserInteractionRepository.test({FirebaseFirestore firestoreInstance}) {
    this.firestoreInstance = firestoreInstance;
  }

  static final CollectionReference _courseCollectionInstance =
      FirebaseFirestore.instance.collection('projects').doc(GlobalConfiguration().getString('projectId')).collection('courses');

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
      Like _courseLiked = await courseIsLiked(courseId: courseId, userId: userId);
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
    courseLiked.isActive = !courseLiked.isActive;
    _updateLikeValue(_courseLikedReference, courseLiked);
    return courseLiked;
  }

  void _updateLikeValue(DocumentReference<Object> courseLikedReference, Like courseLiked) {
    courseLikedReference.update({'updated_at': FieldValue.serverTimestamp(), 'is_active': courseLiked.isActive});
  }

  Future<bool> setCourseRecommendedByUser(
      {@required String originUserId, @required String courseToShareId, @required List<String> usersIdsToShareCourse}) async {
    try {
      if (usersIdsToShareCourse.isNotEmpty) {
        final DocumentReference _originUserReference = _getUserReference(originUserId);
        final DocumentReference _courseReference = _getCourseReference(courseToShareId);

        usersIdsToShareCourse.forEach((friendUserId) async {
          Recommendation friendCourseRecommendation = await _checkIfRecommendationExists(
            originUserId: originUserId,
            courseId: courseToShareId,
            userId: friendUserId,
          );

          if (friendCourseRecommendation == null) {
            final DocumentReference _destinationUserReference = _getUserReference(friendUserId);
            final CollectionReference _courseRecommendationReference = _courseCollectionInstance.doc(courseToShareId).collection('recommendations');
            final DocumentReference _docRef = _courseRecommendationReference.doc();

            final Recommendation newFriendRecommendedCourse = Recommendation(
                id: _docRef.id,
                originUserId: originUserId,
                originUserReference: _originUserReference,
                destinationUserId: friendUserId,
                destinationUserReference: _destinationUserReference,
                entityId: courseToShareId,
                entityReference: _courseReference,
                entityType: TimelineInteractionType.course,
                createdBy: originUserId);

            _docRef.set(newFriendRecommendedCourse.toJson());
          }
        });
      }
      return true;
    } catch (e, stackTrace) {
      await Sentry.captureException(
        e,
        stackTrace: stackTrace,
      );
      return false;
    }
  }

  Future<Recommendation> _checkIfRecommendationExists({@required String originUserId, @required String userId, @required String courseId}) async {
    try {
      final Query<Map<String, dynamic>> docRef = _courseCollectionInstance
          .doc(courseId)
          .collection('recommendations')
          .where('destination_user_id', isEqualTo: userId)
          .where('origin_user_id', isEqualTo: originUserId);
      final QuerySnapshot existingRecommendationForUser = await docRef.get();
      if (existingRecommendationForUser.docs == null || existingRecommendationForUser.docs.isEmpty) {
        return null;
      }
      final courseLikeDoc = existingRecommendationForUser.docs.first.data() as Map<String, dynamic>;
      final Recommendation friendCourseRecommendation = Recommendation.fromJson(courseLikeDoc);
      return friendCourseRecommendation;
    } catch (e, stackTrace) {
      await Sentry.captureException(
        e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getLikedCoursesSubscription({@required String userId}) {
    Stream<QuerySnapshot<Map<String, dynamic>>> _courseLikedStream = FirebaseFirestore.instance
        .collection('projects')
        .doc(GlobalConfiguration().getString('projectId'))
        .collection('users')
        .doc(userId)
        .collection('likes')
        .where('is_active', isEqualTo: true)
        .snapshots();
    return _courseLikedStream;
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getRecommendedCoursesByFriends({@required String userId}) {
    Stream<QuerySnapshot<Map<String, dynamic>>> _friendRecommendationsStream = FirebaseFirestore.instance
        .collection('projects')
        .doc(GlobalConfiguration().getString('projectId'))
        .collection('users')
        .doc(userId)
        .collection('recommendations')
        .snapshots();
    return _friendRecommendationsStream;
  }

  DocumentReference<Object> _getUserReference(String userRequestedId) {
    final DocumentReference userReference =
        firestoreInstance.collection('projects').doc(GlobalConfiguration().getString('projectId')).collection('users').doc(userRequestedId);
    return userReference;
  }

  DocumentReference<Object> _getCourseReference(String courseId) {
    final DocumentReference courseReference =
        firestoreInstance.collection('projects').doc(GlobalConfiguration().getString('projectId')).collection('courses').doc(courseId);
    return courseReference;
  }
}
