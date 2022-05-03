import 'package:firebase_database/firebase_database.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:oluko_app/models/dto/user_progress.dart';

class UserProgressRepository {
  UserProgressRepository();

  static Future<UserProgress> create(String userId, double progress) async {
    final docRef = FirebaseDatabase.instance.ref().child('${GlobalConfiguration().getValue('projectId')}${'/usersProgress/$userId'}');
    UserProgress userProgress = UserProgress(progress: progress, id: docRef.key);
    await docRef.set(userProgress.toJson());
    await docRef.update({'created_at': ServerValue.timestamp});
    return userProgress;
  }

  static Future<void> update(String userId, double progress) async {
    final docRef = FirebaseDatabase.instance.ref().child('${GlobalConfiguration().getValue('projectId')}${'/usersProgress/$userId'}');
    docRef.update({'progress': progress});
  }

  static Future<void> delete(String userId) async {
    final docRef = FirebaseDatabase.instance.ref().child('${GlobalConfiguration().getValue('projectId')}${'/usersProgress/$userId'}');
    docRef.remove();
  }

  static Future<List<UserProgress>> getAll(String userId) async {
    final DataSnapshot snapshot =
        await FirebaseDatabase.instance.ref().child('${GlobalConfiguration().getValue('projectId')}${'/usersProgress'}').get();
    final List<UserProgress> userProgresses = [];
    final Map<String, dynamic> json = Map<String, dynamic>.from(snapshot.value as Map);
    json.forEach((key, userStory) {
      userProgresses.add(UserProgress.fromJson(Map<String, dynamic>.from(userStory as Map)));
    });
    return userProgresses;
  }

  static Stream<DatabaseEvent> getSubscription() {
    Stream<DatabaseEvent> userProgressStream = FirebaseDatabase.instance.ref().child('${GlobalConfiguration().getValue('projectId')}${'/usersProgress'}').onChildChanged;
    return userProgressStream;
  }
}
