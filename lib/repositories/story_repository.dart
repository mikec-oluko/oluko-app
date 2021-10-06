import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:oluko_app/models/dto/story_dto.dart';
import 'package:oluko_app/models/dto/user_stories.dart';
import 'package:oluko_app/models/segment_submission.dart';

class StoryRepository {
  StoryRepository();

  static Future<Story> createStory(SegmentSubmission segmentSubmission) async {
    final DocumentReference docRef =
        FirebaseFirestore.instance.collection('projects').doc(GlobalConfiguration().getValue('projectId')).collection('users').doc(segmentSubmission.userId).collection('stories').doc();
    final Story story = Story(content_type: 'video', url: segmentSubmission.video.url, description: 'description', createdBy: segmentSubmission.userId);
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
    DataSnapshot snapshot = await FirebaseDatabase.instance.reference().child('${GlobalConfiguration().getValue('projectId')}${'/users/$userId/userStories'}').get();
    List<UserStories> returnList = [];
    Map<String, dynamic> json = Map<String, dynamic>.from(snapshot.value as Map);
    if (json != null) {
      json.forEach((key, userStory) {
        returnList.add(UserStories.fromJson(Map<String, dynamic>.from(userStory as Map)));
      });
    }
    returnList.sort((a, b) {
      var aLastStory = a.stories[a.stories.length - 1];
      var bLastStory = b.stories[b.stories.length - 1];
      if (aLastStory.seen && !bLastStory.seen) return 1;
      if (!aLastStory.seen && bLastStory.seen) return -1;
      if (aLastStory.createdAt != null && bLastStory.createdAt != null) return aLastStory.createdAt?.compareTo(bLastStory.createdAt);
      return 0;
    });
    return returnList;
  }
}
