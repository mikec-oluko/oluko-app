import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:oluko_app/models/course.dart';
import 'package:oluko_app/models/course_chat.dart';
import 'package:oluko_app/models/message.dart';
import 'package:oluko_app/models/submodels/object_submodel.dart';
import 'package:oluko_app/models/submodels/user_message_submodel.dart';
import 'package:oluko_app/models/user_response.dart';
import 'package:oluko_app/repositories/course_repository.dart';
import 'package:oluko_app/repositories/user_repository.dart';

class CourseChatRepository {
  FirebaseFirestore firestoreInstance;

  CourseChatRepository() {
    firestoreInstance = FirebaseFirestore.instance;
  }

  CourseChatRepository.test({FirebaseFirestore firestoreInstance}) {
    this.firestoreInstance = firestoreInstance;
  }

  static Future<Message> createMessage(Message message, String courseChatId) async {
    final DocumentReference projectReference = FirebaseFirestore.instance.collection('projects').doc(GlobalConfiguration().getValue('projectId'));
    final CollectionReference reference = projectReference.collection('coursesChat').doc(courseChatId).collection('messages');
    DocumentReference docRef = reference.doc();
    message.id = docRef.id;
    await docRef.set(message.toJson());
    return message;
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> listenToMessagesByCourseChatId(String courseChatId, {int limit = 10}) {
    Query<Map<String, dynamic>> query = FirebaseFirestore.instance
        .collection('projects')
        .doc(GlobalConfiguration().getValue('projectId'))
        .collection('coursesChat')
        .doc(courseChatId)
        .collection('messages')
        .orderBy('created_at', descending: true);

    query = query.limit(limit);
    return query.snapshots();
  }

  static Future<CourseChat> getCourseChatById(String courseChatId) async {
    try {
      final docSnapshot = await FirebaseFirestore.instance
          .collection('projects')
          .doc(GlobalConfiguration().getValue('projectId'))
          .collection('coursesChat')
          .doc(courseChatId)
          .get();

      if (docSnapshot.exists) {
        final chatData = docSnapshot.data();
        if (chatData != null) {
          return CourseChat.fromJson(chatData);
        } else {
          return null;
        }
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  static Future<List<Message>> getMessagesAfterMessageId(String courseChatId, String messageId, {int limit = 0}) async {
    if (messageId != null) {
      final messageReference = FirebaseFirestore.instance
          .collection('projects')
          .doc(GlobalConfiguration().getValue('projectId'))
          .collection('coursesChat')
          .doc(courseChatId)
          .collection('messages')
          .doc(messageId);

      final messageReferenceSnapshot = await messageReference.get();

      final query = FirebaseFirestore.instance
          .collection('projects')
          .doc(GlobalConfiguration().getValue('projectId'))
          .collection('coursesChat')
          .doc(courseChatId)
          .collection('messages')
          .where('created_at', isGreaterThan: messageReferenceSnapshot.data()['created_at']);

      final snapshot = await query.get();
      final List<Message> messages = snapshot.docs.map((e) => Message.fromJson(e.data())).toList();
      return messages;
    } else {
      final query = FirebaseFirestore.instance
          .collection('projects')
          .doc(GlobalConfiguration().getValue('projectId'))
          .collection('coursesChat')
          .doc(courseChatId)
          .collection('messages')
          .orderBy('created_at', descending: true);

      final snapshot = await query.get();
      final List<Message> messages = snapshot.docs.map((e) => Message.fromJson(e.data())).toList();
      return messages;
    }
  }

  static Future<void> updateUsersLastSeenMessage(String courseChatId, UserMessageSubmodel newLastSeenMessage) async {
    final DocumentReference projectReference = FirebaseFirestore.instance.collection('projects').doc(GlobalConfiguration().getValue('projectId'));
    final chatRef = projectReference.collection('coursesChat').doc(courseChatId);
    final DocumentSnapshot chatObj = await chatRef.get();
    final chat = chatObj.data() as dynamic;
    final usersLastSeenMessage = chat['users_last_seen_message'] as List<dynamic> ?? [];

    final int index = usersLastSeenMessage.indexWhere((item) => item['user']['id'] == newLastSeenMessage.user.id);

    if (index != -1) {
      usersLastSeenMessage[index]['message_reference'] = newLastSeenMessage.messageReference;
      usersLastSeenMessage[index]['message_id'] = newLastSeenMessage.messageId;
    } else {
      usersLastSeenMessage.add(
          {'user': newLastSeenMessage.user.toJson(), 'message_reference': newLastSeenMessage.messageReference, 'message_id': newLastSeenMessage.messageId});
    }

    await chatRef.update({'users_last_seen_message': usersLastSeenMessage});
  }

  static DocumentReference<Object> getMessageReference(String courseChatId, String messageId) {
    final DocumentReference messageReference = FirebaseFirestore.instance
        .collection('projects')
        .doc(GlobalConfiguration().getValue('projectId'))
        .collection('coursesChat')
        .doc(courseChatId)
        .collection('messages')
        .doc(messageId);
    return messageReference;
  }
}
