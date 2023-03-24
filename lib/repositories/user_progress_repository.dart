import 'package:firebase_database/firebase_database.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:oluko_app/models/dto/user_progress.dart';
import 'package:oluko_app/models/submodels/friend_model.dart';

class UserProgressRepository {
  UserProgressRepository();

  static Future<UserProgress> create(String userId, double progress, List<FriendModel> friends) async {
    UserProgress userProgress = UserProgress(progress: progress);
    for (FriendModel f in friends) {
      final docRef = getUserProgressRef(f, userId);
      userProgress.id = docRef.key;
      await docRef.set(userProgress.toJson());
      await docRef.update({'created_at': ServerValue.timestamp});
    }
    return userProgress;
  }

  static Future<void> update(String userId, double progress, List<FriendModel> friends) async {
    for (FriendModel f in friends) {
      final docRef = getUserProgressRef(f, userId);
      docRef.update({'progress': progress});
    }
  }

  static Future<void> delete(String userId, List<FriendModel> friends) async {
    for (FriendModel f in friends) {
      final docRef = getUserProgressRef(f, userId);
      docRef.remove();
    }
  }

  static Future<Map<String, UserProgress>> getAll(String userId) async {
    final DataSnapshot snapshot = await getReference(userId).get();
    final Map<String, UserProgress> usersProgress = {};
    if (snapshot.value != null) {
      Map<String, dynamic> values = Map<String, dynamic>.from(snapshot.value as Map);
      values.forEach((key, obj) {
        usersProgress[key] = UserProgress(id: obj['id'].toString(), progress: double.parse(obj['progress'].toString()));
      });
    }
    return usersProgress;
  }

  static DatabaseReference getUserProgressRef(FriendModel f, String userId) {
    String friendId = f.id;
    return FirebaseDatabase.instance.ref().child('${GlobalConfiguration().getString('projectId')}${'/activeNowUsers/$friendId/usersProgress/$userId'}');
  }

  static DatabaseReference getReference(String userId) {
    return FirebaseDatabase.instance.ref().child('${GlobalConfiguration().getString('projectId')}${'/activeNowUsers/$userId/usersProgress'}');
  }
}
