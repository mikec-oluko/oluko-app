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

  static Future<CourseChat> create(CourseChat courseChat) async {
    final DocumentReference projectReference = FirebaseFirestore.instance.collection('projects').doc(GlobalConfiguration().getValue('projectId'));
    final CollectionReference reference = projectReference.collection('coursesChat');
    DocumentReference docRef = reference.doc();
    courseChat.id = docRef.id;
    await docRef.set(courseChat.toJson());
    return courseChat;
  }

  static Future<Message> createMessage(Message message, String courseChatId) async {
    final DocumentReference projectReference = FirebaseFirestore.instance.collection('projects').doc(GlobalConfiguration().getValue('projectId'));
    final CollectionReference reference = projectReference.collection('coursesChat').doc(courseChatId).collection('messages');
    DocumentReference docRef = reference.doc();
    message.id = docRef.id;
    await docRef.set(message.toJson());
    return message;
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> getAllMessagesByCourseChatId(String courseChatId) {
    final Stream<QuerySnapshot<Map<String, dynamic>>> docRef = FirebaseFirestore.instance
        .collection('projects')
        .doc(GlobalConfiguration().getValue('projectId'))
        .collection('coursesChat')
        .doc(courseChatId)
        .collection('messages')
        .orderBy('created_at', descending: false)
        .snapshots();
    return docRef;
  }

  static Future<void> updateUsersLastSeenMessage(String courseChatId, UserMessageSubmodel newLastSeenMessage) async {
    final DocumentReference projectReference = FirebaseFirestore.instance.collection('projects').doc(GlobalConfiguration().getValue('projectId'));
    final chatRef = projectReference.collection('coursesChat').doc(courseChatId);
    final DocumentSnapshot chatObj = await chatRef.get();
    final chat = chatObj.data() as dynamic;
    final usersLastSeenMessage = chat['users_last_seen_message'] as List<dynamic> ?? [];

    int index = usersLastSeenMessage.indexWhere((item) => item['user.id'] == newLastSeenMessage.user.id);

    if (index != -1) {
      usersLastSeenMessage[index]['message_reference'] = newLastSeenMessage.messageReference;
      usersLastSeenMessage[index]['message_id'] = newLastSeenMessage.messageId;

    } else {
      usersLastSeenMessage.add({
        newLastSeenMessage
      });
    }
    
    await chatRef.update({
      'users_last_seen_message': usersLastSeenMessage
    }); 
  }
}
