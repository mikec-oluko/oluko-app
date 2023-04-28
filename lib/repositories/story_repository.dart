import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:oluko_app/models/dto/story_dto.dart';
import 'package:oluko_app/models/dto/user_stories.dart';
import 'package:oluko_app/models/enums/story_content_enum.dart';
import 'package:oluko_app/models/segment.dart';
import 'package:oluko_app/models/segment_submission.dart';

class StoryRepository {
  StoryRepository();

  static Future<Story> createStoryWithVideo(SegmentSubmission segmentSubmission, String segmentTitle, String result, String description) async {
    final DocumentReference docRef = FirebaseFirestore.instance
        .collection('projects')
        .doc(GlobalConfiguration().getString('projectId'))
        .collection('users')
        .doc(segmentSubmission.userId)
        .collection('stories')
        .doc();
    final Story story = Story(
        contentType: storyContentLabels[StoryContentEnum.Video],
        url: segmentSubmission.video.url,
        description: description,
        createdBy: segmentSubmission.userId,
        segmentTitle: segmentTitle,
        result: result);
    story.createdAt = Timestamp.now();
    story.id = docRef.id;
    docRef.set(story.toJson());
    return story;
  }

  static Future<Story> createStoryForChallenge(Segment segment, String userId, String segmentTitle, String result, String description) async {
    final DocumentReference docRef = FirebaseFirestore.instance
        .collection('projects')
        .doc(GlobalConfiguration().getString('projectId'))
        .collection('users')
        .doc(userId)
        .collection('stories')
        .doc();
    final Story story = Story(
        contentType: storyContentLabels[StoryContentEnum.Image],
        url: segment.challengeImage ?? segment.image,
        description: description,
        createdBy: userId,
        segmentTitle: segmentTitle,
        result: result);
    story.id = docRef.id;
    docRef.set(story.toJson());
    return story;
  }

  static Future<void> setStoryAsSeen(String userId, String userStoryId, String storyId) async {
    final docRef =
        FirebaseDatabase.instance.ref().child('${GlobalConfiguration().getString('projectId')}${'/users/$userId/userStories/$userStoryId/stories/$storyId'}');
    docRef.update({'seen': true});
  }

  Future<bool> checkForUnseenStories(String userId, String userStoryId) async {
    final DataSnapshot snapshot =
        await FirebaseDatabase.instance.ref().child('${GlobalConfiguration().getString('projectId')}${'/users/$userId/userStories/$userStoryId'}').get();
    if (snapshot.value == null) {
      return false;
    }
    final Map<String, dynamic> json = Map<String, dynamic>.from(snapshot.child('stories') as Map);
    if (json == null) {
      return false;
    }
    bool ret = false;
    json.forEach((key, story) {
      if (story['seen'] != null && story['seen'] is bool && story['seen'] as bool != true) {
        ret = true;
      }
    });
    return ret;
  }

  Future<dynamic> getAll(String userId) async {
    final DataSnapshot snapshot =
        await FirebaseDatabase.instance.ref().child('${GlobalConfiguration().getString('projectId')}${'/users/$userId/userStories'}').get();
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

  Future<bool> hasStories(String userId) async {
    final DataSnapshot snapshot =
        await FirebaseDatabase.instance.ref().child('${GlobalConfiguration().getString('projectId')}${'/users/$userId/userStories'}').get();
    if (snapshot.value == null) {
      return false;
    }
    return true;
  }

  Stream<DatabaseEvent> getSubscription(String userId) {
    return FirebaseDatabase.instance.ref().child('${GlobalConfiguration().getString('projectId')}${'/users/$userId/userStories'}').onChildChanged;
  }

  static Future<List<Story>> getByUserId(String userId) async {
    final QuerySnapshot docRef = await FirebaseFirestore.instance
        .collection('projects')
        .doc(GlobalConfiguration().getString('projectId'))
        .collection('users')
        .doc(userId)
        .collection('stories')
        .get();

    final List<Story> response = [];
    for (final doc in docRef.docs) {
      final Map<String, dynamic> element = doc.data() as Map<String, dynamic>;
      response.add(Story.fromJson(element));
    }
    return response;
  }

  Future<List<Story>> getStoriesFromUser(String userId, String userStoryId) async {
    final DataSnapshot snapshot =
        await FirebaseDatabase.instance.ref().child('${GlobalConfiguration().getString('projectId')}${'/users/$userId/userStories/$userStoryId'}').get();
    if (snapshot.value == null) {
      return [];
    }
    final Map<String, dynamic> json = Map<String, dynamic>.from(snapshot.child('stories') as Map);
    if (json == null) {
      return [];
    }
    final List<Story> response = [];
    json.forEach((key, story) {
      response.add(Story.fromJson(Map<String, dynamic>.from(story as Map)));
    });
    return response;
  }
}
