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

    var messagesData = await docRef.reference.collection('messages').get();
    List<Message> messages = messagesData.docs.map((e) => Message.fromJson(e.data())).toList();
    return messages;
  }

  Future<Map<Chat, List<Message>>> getChatsWithMessages(String userId) async {
    QuerySnapshot<Map<String, dynamic>> chatRefs = await FirebaseFirestore.instance
        .collection('projects')
        .doc(GlobalConfiguration().getValue('projectId'))
        .collection('users')
        .doc(userId)
        .collection('chat')
        .orderBy('created_at')
        .get();

    //Chat List
    List<Chat> chats = chatRefs.docs.map((e) => Chat.fromJson(e.data())).toList();

    //Get all message collection references
    List<QuerySnapshot<Map<String, dynamic>>> messageCollectionRefs = await Future.wait(
      chatRefs.docs.map((e) => e.reference.collection('messages').orderBy('created_at').get()),
    );

    //Get all message collections for all chats
    List<List<Message>> messageLists = messageCollectionRefs
        .map(
          (messageCollection) => messageCollection.docs
              .map(
                (messageDoc) => Message.fromJson(messageDoc.data()),
              )
              .toList(),
        )
        .toList();

    //Iterate over chats to generate a map of Chats with their corresponding message list
    Map<Chat, List<Message>> chatsWithMessages = {};
    for (var i = 0; i < chats.length; i++) {
      chatsWithMessages[chats[i]] = messageLists[i];
    }

    return chatsWithMessages;
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> listenToChats(
    String userId,
  ) {
    final Stream<QuerySnapshot<Map<String, dynamic>>> docRef = FirebaseFirestore.instance
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
    final CollectionReference userChatCollection = FirebaseFirestore.instance
        .collection('projects')
        .doc(GlobalConfiguration().getValue('projectId'))
        .collection('users')
        .doc(userId)
        .collection('chat');

    //TODO: Remove after trigger implementation.
    final CollectionReference targetUserChatCollection = FirebaseFirestore.instance
        .collection('projects')
        .doc(GlobalConfiguration().getValue('projectId'))
        .collection('users')
        .doc(targetUserId)
        .collection('chat');

    //Check if chat document exists. If not, create the base properties inside.
    final DocumentSnapshot<Object> userChat = await userChatCollection.doc(targetUserId).get();
    if (!userChat.exists) {
      userChat.reference.set(Chat(id: targetUserId).toJson());
    }

    //TODO: Remove after trigger implementation.
    //Check if chat document exists on Target User. If not, create the base properties inside.
    final DocumentSnapshot<Object> targetUserChat = await targetUserChatCollection.doc(userId).get();
    if (!targetUserChat.exists) {
      targetUserChat.reference.set(Chat(id: userId).toJson());
    }

    //Create Message to send with HiFive code and store as a document
    final Message messageToSend = Message(message: Message().hifiveMessageCode, createdBy: userId);
    final DocumentReference createdMessageDocument = await userChatCollection.doc(targetUserId).collection('messages').add({});
    messageToSend.id = createdMessageDocument.id;
    final Map<String, dynamic> messageToSendJson = messageToSend.toJson();
    createdMessageDocument.set(messageToSendJson);

    //TODO: Remove after trigger implementation
    //Create Message to send with HiFive code and store as a document in target user collection
    final Message messageToSendTarget = Message(message: Message().hifiveMessageCode, createdBy: userId);
    final DocumentReference createdMessageDocumentTarget = await targetUserChatCollection.doc(userId).collection('messages').add({});
    messageToSendTarget.id = createdMessageDocumentTarget.id;
    final Map<String, dynamic> messageToSendJsonTarget = messageToSendTarget.toJson();
    createdMessageDocumentTarget.set(messageToSendJsonTarget);

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

    //TODO: Remove after trigger implementation.
    QuerySnapshot targetUserMessages = await FirebaseFirestore.instance
        .collection('projects')
        .doc(GlobalConfiguration().getValue('projectId'))
        .collection('users')
        .doc(userId)
        .collection('chat')
        .doc(targetUserId)
        .collection('messages')
        .orderBy('created_at')
        .get();

    Message lastMessage = Message.fromJson(messages.docs.last.data() as Map<String, dynamic>);
    //TODO: Remove after trigger implementation.
    Message targetUserLastMessage = Message.fromJson(targetUserMessages.docs.last.data() as Map<String, dynamic>);

    //TODO: Remove after trigger implementation
    if (targetUserLastMessage.message == Message().hifiveMessageCode) {
      targetUserMessages.docs.last.reference.delete();
    }

    if (lastMessage.message == Message().hifiveMessageCode) {
      messages.docs.last.reference.delete();
      return true;
    } else {
      return false;
    }
  }
}