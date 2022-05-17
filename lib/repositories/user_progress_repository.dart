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

  static Future<Map<String,UserProgress>> getAll() async {
    final DataSnapshot snapshot =
        await FirebaseDatabase.instance.ref().child('${GlobalConfiguration().getValue('projectId')}${'/usersProgress'}').get();
    final Map<String,UserProgress> usersProgress = {};
    if (snapshot.value != null) {
      Map<String, dynamic> values = Map<String, dynamic>.from(snapshot.value as Map);
      values.forEach((key, obj) {
        usersProgress[key] = UserProgress(id: obj['id'].toString(), progress: double.parse(obj['progress'].toString()));
      });
    }
    return usersProgress;
  }

    static DatabaseReference getReference() {
    return FirebaseDatabase.instance.ref().child('${GlobalConfiguration().getValue('projectId')}${'/usersProgress'}');
  }
}
