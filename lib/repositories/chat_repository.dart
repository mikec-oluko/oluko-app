import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:oluko_app/models/chat.dart';
import 'package:oluko_app/models/favorite.dart';

class ChatRepository {
  FirebaseFirestore firestoreInstance;

  ChatRepository() {
    firestoreInstance = FirebaseFirestore.instance;
  }

  ChatRepository.test({FirebaseFirestore firestoreInstance}) {
    this.firestoreInstance = firestoreInstance;
  }

  Future<List<Chat>> getByUserId(String userId) async {
    QuerySnapshot docRef = await FirebaseFirestore.instance
        .collection('projects')
        .doc(GlobalConfiguration().getValue('projectId'))
        .collection('users')
        .doc(userId)
        .collection('chat')
        .get();
    List<Chat> response = [];
    docRef.docs.forEach((doc) {
      final Map<String, dynamic> element = doc.data() as Map<String, dynamic>;
      response.add(Chat.fromJson(element));
    });
    return response;
  }

  Future<List<Chat>> getMessages(String userId, String targetUserId) async {
    QuerySnapshot docRef = await FirebaseFirestore.instance
        .collection('projects')
        .doc(GlobalConfiguration().getValue('projectId'))
        .collection('users')
        .doc(userId)
        .collection('chat')
        .where('id', isEqualTo: targetUserId)
        .get();

    //TODO Get messages from inside chat document

    if (docRef.docs.length > 1) {
      var messages = docRef.docs[0].reference.collection('messages').get();
    }
    List<Chat> response = [];
    docRef.docs.forEach((doc) {
      final Map<String, dynamic> element = doc.data() as Map<String, dynamic>;
      response.add(Chat.fromJson(element));
    });
    return response;
  }
}
