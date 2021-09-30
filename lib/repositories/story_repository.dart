import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:oluko_app/models/dto/story_dto.dart';
import 'package:oluko_app/models/dto/user_stories.dart';
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

  Future<dynamic> getAll(String userId) async {
    DataSnapshot snapshot = await FirebaseDatabase.instance.reference().child('${GlobalConfiguration().getValue('projectId')}${'/users/$userId/stories'}').get();
    List<UserStories> returnList = [];
    var mappedStories = [];
    snapshot.value.forEach((k, v) => mappedStories.add(v));
    mappedStories.forEach((element) {
      UserStories toAdd = UserStories(
        id: element['id'].toString(),
        createdBy: element['userId'].toString(),
        name: element['name'].toString(),
        avatar: element['avatar'].toString(),
        avatar_thumbnail: element['avatar_thumbnail'].toString(),
        createdAt: element['created_at'] is FieldValue
            ? null
            : element['created_at'] is Timestamp
                ? element['created_at'] as Timestamp
                : element['created_at'] is Map
                    ? Timestamp(element['created_at']['_seconds'] as int, element['created_at']['_nanoseconds'] as int)
                    : element['created_at'] is int
                        ? Timestamp.fromMillisecondsSinceEpoch(element['created_at'] as int)
                        : null,
        updatedAt: element['updatedAt'] is FieldValue
            ? null
            : element['updatedAt'] is Timestamp
                ? element['updatedAt'] as Timestamp
                : element['updatedAt'] is Map
                    ? Timestamp(element['updatedAt']['_seconds'] as int, element['updatedAt']['_nanoseconds'] as int)
                    : element['created_at'] is int
                        ? Timestamp.fromMillisecondsSinceEpoch(element['updatedAt'] as int)
                        : null,
      );
      returnList.add(toAdd);
    });
    return returnList;
  }
}
