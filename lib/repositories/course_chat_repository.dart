import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:oluko_app/models/course.dart';
import 'package:oluko_app/models/course_chat.dart';
import 'package:oluko_app/models/message.dart';
import 'package:oluko_app/models/submodels/object_submodel.dart';
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

  // static Future<Message> createMessage(String userId, String courseId, String message) async {

  //   final DocumentReference projectReference = FirebaseFirestore.instance.collection('projects').doc(GlobalConfiguration().getValue('projectId'));
  //   final CollectionReference reference = projectReference.collection('coursesChat').doc(courseChatId).collection('messages');
  //   DocumentReference docRef = reference.doc();
  //   message.id = docRef.id;
  //   await docRef.set(message.toJson());
  //   return message;
  // }

  static Stream<QuerySnapshot<Map<String, dynamic>>> getAllMessagesByCourseChatId(String courseChatId) {
    final Stream<QuerySnapshot<Map<String, dynamic>>> docRef = FirebaseFirestore.instance
        .collection('projects')
        .doc(GlobalConfiguration().getValue('projectId'))
        .collection('coursesChat')
        .doc(courseChatId)
        .collection('messages')
        .snapshots();
    // I have to add startAfter and endBefore and limit
    return docRef;
  }

}