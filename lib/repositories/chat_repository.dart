import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:oluko_app/models/chat.dart';
import 'package:oluko_app/models/favorite.dart';
import 'package:oluko_app/models/message.dart';

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
      response.add(Chat.fromJson(doc.data() as Map<String, dynamic>));
    });
    return response;
  }

  Future<List<Message>> getMessages(String userId, String targetUserId) async {
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
      var messagesData =
          await docRef.docs[0].reference.collection('messages').get();
      List<Message> messages =
          messagesData.docs.map((e) => Message.fromJson(e.data())).toList();
      return messages;
    } else {
      return [];
    }
  }
}
