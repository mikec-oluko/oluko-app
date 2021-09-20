import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
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
    DocumentSnapshot docRef = await FirebaseFirestore.instance
        .collection('projects')
        .doc(GlobalConfiguration().getValue('projectId'))
        .collection('users')
        .doc(userId)
        .collection('chat')
        .doc(targetUserId)
        .get();

    //TODO Get messages from inside chat document

    var messagesData = await docRef.reference.collection('messages').get();
    List<Message> messages =
        messagesData.docs.map((e) => Message.fromJson(e.data())).toList();
    return messages;
  }

  Future<Message> sendHiFive(String userId, String targetUserId) async {
    Message messageToSend = Message(message: Message().hifiveMessageCode);

    DocumentReference createdMessageDocument = await FirebaseFirestore.instance
        .collection('projects')
        .doc(GlobalConfiguration().getValue('projectId'))
        .collection('users')
        .doc(userId)
        .collection('chat')
        .doc(targetUserId)
        .collection('messages')
        .add({});

    messageToSend.id = createdMessageDocument.id;

    Map<String, dynamic> messageToSendJson = messageToSend.toJson();
    createdMessageDocument.set(messageToSendJson);

    DocumentSnapshot createdMessage = await FirebaseFirestore.instance
        .collection('projects')
        .doc(GlobalConfiguration().getValue('projectId'))
        .collection('users')
        .doc(userId)
        .collection('chat')
        .doc(targetUserId)
        .collection('messages')
        .doc(messageToSend.id)
        .get();

    return Message.fromJson(createdMessage.data() as Map<String, dynamic>);
  }
}
