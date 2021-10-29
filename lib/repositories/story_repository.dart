import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:oluko_app/models/dto/story_dto.dart';
import 'package:oluko_app/models/dto/user_stories.dart';
import 'package:oluko_app/models/segment_submission.dart';
import 'package:oluko_app/models/submodels/enrollment_segment.dart';

class StoryRepository {
  StoryRepository();

  static Future<Story> createStoryWithVideo(SegmentSubmission segmentSubmission) async {
    final DocumentReference docRef =
        FirebaseFirestore.instance.collection('projects').doc(GlobalConfiguration().getValue('projectId')).collection('users').doc(segmentSubmission.userId).collection('stories').doc();
    final Story story = Story(content_type: 'video', url: segmentSubmission.video.url, description: 'description', createdBy: segmentSubmission.userId);
    story.createdAt = Timestamp.now();
    story.id = docRef.id;
    docRef.set(story.toJson());
    return story;
  }

  static Future<Story> createStoryForChallenge(EnrollmentSegment enrollmentSegment, String userId) async {
    final DocumentReference docRef = FirebaseFirestore.instance.collection('projects').doc(GlobalConfiguration().getValue('projectId')).collection('users').doc(userId).collection('stories').doc();
    final Story story = Story(content_type: 'image', url: enrollmentSegment.challengeImage, description: enrollmentSegment.name, createdBy: userId);
    story.createdAt = Timestamp.now();
    story.id = docRef.id;
    docRef.set(story.toJson());
    return story;
  }

  static Future<void> setStoryAsSeen(String userId, String userStoryId, String storyId) async {
    final docRef = FirebaseDatabase.instance.reference().child('${GlobalConfiguration().getValue('projectId')}${'/users/$userId/userStories/$userStoryId/stories/$storyId'}');
    docRef.update({'seen': true});
  }

  Future<dynamic> getAll(String userId) async {
    final DataSnapshot snapshot = await FirebaseDatabase.instance.reference().child('${GlobalConfiguration().getValue('projectId')}${'/users/$userId/userStories'}').get();
    final List<UserStories> returnList = [];
    if (snapshot.value == null) {
      return returnList;
    }
    final Map<String, dynamic> json = Map<String, dynamic>.from(snapshot.value as Map);
    if (json == null) {
      return returnList;
    }

    json.forEach((key, userStory) {
      returnList.add(UserStories.fromJson(Map<String, dynamic>.from(userStory as Map)));
    });

    returnList.sort((a, b) {
      final aLength = a?.stories?.length;
      final bLength = b?.stories?.length;
      if ((aLength == null || aLength == 0) && (bLength == null || bLength == 0)) return 0;
      if ((aLength == null || aLength == 0) && (bLength != null && bLength > 0)) return 1;
      if ((aLength != null && aLength > 0) && (bLength == null || bLength == 0)) return -1;
      final aLastStory = a.stories[aLength - 1];
      final bLastStory = b.stories[bLength - 1];
      if (aLastStory.seen && !bLastStory.seen) return 1;
      if (!aLastStory.seen && bLastStory.seen) return -1;
      if (aLastStory.createdAt != null && bLastStory.createdAt != null) return aLastStory.createdAt?.compareTo(bLastStory.createdAt);

      return 0;
    });
    return returnList;
  }

  Stream<Event> getSubscription(String userId) {
    return FirebaseDatabase.instance.reference().child('${GlobalConfiguration().getValue('projectId')}${'/users/$userId/userStories'}').onChildChanged;
  }

  static Future<List<Story>> getByUserId(String userId) async {
    final QuerySnapshot docRef = await FirebaseFirestore.instance.collection('projects').doc(GlobalConfiguration().getValue('projectId')).collection('users').doc(userId).collection('stories').get();

    List<Story> response = [];
    docRef.docs.forEach((doc) {
      final Map<String, dynamic> element = doc.data() as Map<String, dynamic>;
      response.add(Story.fromJson(element));
    });
    return response;
  }
}
