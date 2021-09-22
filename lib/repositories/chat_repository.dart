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

  Stream<QuerySnapshot<Map<String, dynamic>>> listenToChats(
    String userId,
  ) {
    final Stream<QuerySnapshot<Map<String, dynamic>>> docRef = FirebaseFirestore
        .instance
        .collection('projects')
        .doc(GlobalConfiguration().getValue('projectId'))
        .collection('users')
        .doc(userId)
        .collection('chat')
        .snapshots();

    //TODO Get messages from inside chat document
    return docRef;
  }

  Future<Message> sendHiFive(String userId, String targetUserId) async {
    final CollectionReference chatCollection = await FirebaseFirestore.instance
        .collection('projects')
        .doc(GlobalConfiguration().getValue('projectId'))
        .collection('users')
        .doc(userId)
        .collection('chat');

    //Check if chat document exists. If not, create the base properties inside.
    final DocumentSnapshot<Object> chat =
        await chatCollection.doc(targetUserId).get();
    if (!chat.exists) {
      chat.reference.set(Chat(id: targetUserId).toJson());
    }

    //Create Message to send with HiFive code and store as a document
    final Message messageToSend = Message(message: Message().hifiveMessageCode);
    DocumentReference createdMessageDocument =
        await chatCollection.doc(targetUserId).collection('messages').add({});
    messageToSend.id = createdMessageDocument.id;
    final Map<String, dynamic> messageToSendJson = messageToSend.toJson();
    createdMessageDocument.set(messageToSendJson);

    //Get message to return
    final DocumentSnapshot createdMessage = await FirebaseFirestore.instance
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

  Future<bool> removeHiFive(String userId, String targetUserId) async {
    Message messageToSend = Message(message: Message().hifiveMessageCode);

    QuerySnapshot messages = await FirebaseFirestore.instance
        .collection('projects')
        .doc(GlobalConfiguration().getValue('projectId'))
        .collection('users')
        .doc(userId)
        .collection('chat')
        .doc(targetUserId)
        .collection('messages')
        .orderBy('created_at')
        .get();

    Message lastMessage =
        Message.fromJson(messages.docs[0].data() as Map<String, dynamic>);

    if (lastMessage.message == Message().hifiveMessageCode) {
      messages.docs[0].reference.delete();
      return true;
    } else {
      return false;
    }
  }
}
