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
        .doc(GlobalConfiguration().getString('projectId'))
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
        .doc(GlobalConfiguration().getString('projectId'))
        .collection('users')
        .doc(userId)
        .collection('chat')
        .doc(targetUserId)
        .get();

    var messagesData = await docRef.reference.collection('messages').orderBy('created_at').get();
    List<Message> messages = messagesData.docs.map((e) => Message.fromJson(e.data())).toList();
    return messages;
  }

  static Future<Map<Chat, List<Message>>> getChatsWithMessages(String userId) async {
    QuerySnapshot<Map<String, dynamic>> chatRefs = await FirebaseFirestore.instance
        .collection('projects')
        .doc(GlobalConfiguration().getString('projectId'))
        .collection('users')
        .doc(userId)
        .collection('chat')
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
        .doc(GlobalConfiguration().getString('projectId'))
        .collection('users')
        .doc(userId)
        .collection('chat')
        .snapshots();

    //TODO Get messages from inside chat document
    return docRef;
  }

  static Future<Message> sendHiFive(String userId, String targetUserId) async {
    final CollectionReference userChatCollection =
        FirebaseFirestore.instance.collection('projects').doc(GlobalConfiguration().getString('projectId')).collection('users').doc(userId).collection('chat');

    //Check if chat document exists. If not, create the base properties inside.
    final DocumentSnapshot<Object> userChat = await userChatCollection.doc(targetUserId).get();
    if (!userChat.exists) {
      await userChat.reference.set(Chat(id: targetUserId).toJson());
    }

    //Create Message to send with HiFive code and store as a document
    final Message messageToSend = Message(message: Message().hifiveMessageCode, createdBy: userId);
    final DocumentReference createdMessageDocument = await userChatCollection.doc(targetUserId).collection('messages').add({});
    messageToSend.id = createdMessageDocument.id;
    final Map<String, dynamic> messageToSendJson = messageToSend.toJson();
    messageToSendJson['created_at'] = FieldValue.serverTimestamp();
    await createdMessageDocument.set(messageToSendJson);

    //Get message to return
    final DocumentSnapshot createdMessage = await FirebaseFirestore.instance
        .collection('projects')
        .doc(GlobalConfiguration().getString('projectId'))
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
        .doc(GlobalConfiguration().getString('projectId'))
        .collection('users')
        .doc(userId)
        .collection('chat')
        .doc(targetUserId)
        .collection('messages')
        .orderBy('created_at')
        .get();

    Message lastMessage = Message.fromJson(messages.docs.last.data() as Map<String, dynamic>);

    if (lastMessage.message == Message().hifiveMessageCode) {
      await messages.docs.last.reference.delete();
      return true;
    } else {
      return false;
    }
  }

  static void removeAllHiFives(String userId, String targetUserId) async {
    final QuerySnapshot messages = await FirebaseFirestore.instance
        .collection('projects')
        .doc(GlobalConfiguration().getString('projectId'))
        .collection('users')
        .doc(userId)
        .collection('chat')
        .doc(targetUserId)
        .collection('messages')
        .where('message', isEqualTo: Message().hifiveMessageCode)
        .get();

    if (messages?.docs != null) {
      for (final message in messages.docs) {
        await message.reference.delete();
      }
    }
  }

  static Future<void> removeNotification(String userId, String targetUserId) async {
    final QuerySnapshot<Map<String, dynamic>> notifications = await FirebaseFirestore.instance
        .collection('projects')
        .doc(GlobalConfiguration().getString('projectId'))
        .collection('users')
        .doc(userId)
        .collection('notifications')
        .where('user.id', isEqualTo: targetUserId)
        .where('message', isEqualTo: Message().hifiveMessageCode)
        .get();

    if (notifications?.docs != null) {
      for (final notification in notifications.docs) {
        if (notification.data()['is_deleted'] != true) {
          await notification.reference.delete();
        }
      }
    }
  }
}
