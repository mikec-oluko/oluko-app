import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:oluko_app/models/dto/story_dto.dart';
import 'package:oluko_app/models/movement_submission.dart';

class StoryRepository {
  StoryRepository();

  static Future<Story> createStory(MovementSubmission movementSubmission) async {
    final DocumentReference docRef =
        FirebaseFirestore.instance.collection('projects').doc(GlobalConfiguration().getValue('projectId')).collection('users').doc(movementSubmission.userId).collection('stories').doc();
    final Story story = Story(content_type: 'video', url: movementSubmission.video.url, description: 'description', createdBy: movementSubmission.userId);
    story.createdAt = Timestamp.now();
    story.id = docRef.id;
    docRef.set(story.toJson());
    return story;
  }
}
