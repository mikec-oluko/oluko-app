import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:oluko_app/models/course.dart';
import 'package:oluko_app/models/course_chat.dart';
import 'package:oluko_app/models/course_enrollment.dart';
import 'package:oluko_app/models/message.dart';
import 'package:oluko_app/models/submodels/object_submodel.dart';
import 'package:oluko_app/models/submodels/user_message_submodel.dart';
import 'package:oluko_app/models/user_response.dart';
import 'package:oluko_app/repositories/auth_repository.dart';
import 'package:oluko_app/repositories/course_enrollment_repository.dart';
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

  Future<Message> createMessage(Message message, String courseChatId) async {
    final DocumentReference projectReference = FirebaseFirestore.instance.collection('projects').doc(GlobalConfiguration().getString('projectId'));
    final CollectionReference reference = projectReference.collection('coursesChat').doc(courseChatId).collection('messages');
    DocumentReference docRef = reference.doc();
    message.id = docRef.id;
    await docRef.set(message.toJson());
    return message;
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> listenToMessagesByCourseChatId(String courseChatId, {int limit = 10, DocumentSnapshot<Object> message}) {
    Query<Map<String, dynamic>> query = FirebaseFirestore.instance
        .collection('projects')
        .doc(GlobalConfiguration().getString('projectId'))
        .collection('coursesChat')
        .doc(courseChatId)
        .collection('messages')
        .orderBy('created_at', descending: true);

    query = query.limit(limit);
    
    if(message != null){
      query = query.where('created_at', isGreaterThan: message['created_at']);
    }
    return query.snapshots();
  }

  Future<CourseChat> getCourseChatById(String courseChatId) async {
    final docSnapshot = await FirebaseFirestore.instance
        .collection('projects')
        .doc(GlobalConfiguration().getString('projectId'))
        .collection('coursesChat')
        .doc(courseChatId)
        .get();

    if (docSnapshot.exists && docSnapshot.data() != null) {
      final chatData = docSnapshot.data();
      return CourseChat.fromJson(chatData);
    } else {
      return null;
    }
  }

  Future<DocumentSnapshot> getMessageByMessageIdAndChatId(String courseChatId, String messageId) async {
    if(messageId == null || courseChatId == null){
      return null;
    }
    final docSnapshot = await FirebaseFirestore.instance
        .collection('projects')
        .doc(GlobalConfiguration().getString('projectId'))
        .collection('coursesChat')
        .doc(courseChatId)
        .collection('messages')
        .doc(messageId)
        .get();

    return docSnapshot;
  }

  Future<List<Message>> getMessagesAfterMessageId(String courseChatId, String messageId, {int limit = 10}) async {
    final messageReferenceSnapshot = await getMessageByMessageIdAndChatId(courseChatId, messageId);

    Query query = FirebaseFirestore.instance
        .collection('projects')
        .doc(GlobalConfiguration().getString('projectId'))
        .collection('coursesChat')
        .doc(courseChatId)
        .collection('messages')
        .orderBy('created_at', descending: true)
        .limit(limit);

    if(messageReferenceSnapshot != null){
      query = query.startAfterDocument(messageReferenceSnapshot);
    }
    final snapshot = await query.get();
    final List<Message> messages = snapshot.docs.map((e) => Message.fromJson(e.data() as Map<String, dynamic>)).toList();
    return messages;
  }

  Future<void> updateUsersLastSeenMessage(String courseChatId, Message message) async {
    final UserRepository repository = UserRepository();
    final DocumentReference<Object> messageReference = CourseChatRepository.getChatMessageReference(courseChatId, message.id);
    final User userLogged = AuthRepository.getLoggedUser();
    final DocumentReference<Object> userReference = repository.getUserReference(userLogged.uid);
    ObjectSubmodel userSubmodel = ObjectSubmodel(id: userLogged.uid, name: userLogged.displayName, reference: userReference);
    UserMessageSubmodel newLastSeenMessage = UserMessageSubmodel(messageReference: messageReference, messageId: message.id, user: userSubmodel);

    final DocumentReference projectReference = FirebaseFirestore.instance.collection('projects').doc(GlobalConfiguration().getString('projectId'));
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

  static DocumentReference<Object> getChatMessageReference(String courseChatId, String messageId) {
    final DocumentReference messageReference = FirebaseFirestore.instance
        .collection('projects')
        .doc(GlobalConfiguration().getString('projectId'))
        .collection('coursesChat')
        .doc(courseChatId)
        .collection('messages')
        .doc(messageId);
    return messageReference;
  }

  static Future getCoursesWithChatByUserId(String userId) async {
    final List<CourseEnrollment> courseEnrollments = await CourseEnrollmentRepository.getUserCourseEnrollments(userId);
    final List<CourseEnrollment> courseList = courseEnrollments.where((element) => element.isUnenrolled != true).toList();
    final List<CourseEnrollment> coursesWithChat = [];

    final List<Future<DocumentSnapshot<Object>>> promises = courseList.map((element) => element.course.reference.get()).toList();
    final List<DocumentSnapshot<Object>> courses = await Future.wait(promises);
    Course courseElement;
    courses
        .map((course) => {
              courseElement = Course.fromJson(course.data() as Map<String, dynamic>),
              if (courseElement?.hasChat != false) {coursesWithChat.add(courseEnrollments.firstWhere((element) => courseElement.id == element.course.id))}
            })
        .toList();

    return coursesWithChat;
  }
}
