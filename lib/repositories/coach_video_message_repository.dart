import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:oluko_app/models/coach_media_message.dart';

class CoachVideoMessageRepository {
  FirebaseFirestore firestoreInstance;
  static DocumentReference projectReference = FirebaseFirestore.instance.collection('projects').doc(GlobalConfiguration().getString('projectId'));

  CoachVideoMessageRepository() {
    firestoreInstance = FirebaseFirestore.instance;
  }
  CoachVideoMessageRepository.test({this.firestoreInstance});

  Stream<QuerySnapshot<Map<String, dynamic>>> getStream({@required String userId, @required String coachId}) {
    Stream<QuerySnapshot<Map<String, dynamic>>> coachVideoMessage = FirebaseFirestore.instance
        .collection('projects')
        .doc(GlobalConfiguration().getString('projectId'))
        .collection('coachAssignments')
        .doc(userId)
        .collection('mediaMessages')
        .where('coach_id', isEqualTo: coachId)
        .snapshots();
    return coachVideoMessage;
  }

  Future<void> markVideoMessageAsSeeen({String userId, CoachMediaMessage messageVideoContent}) async {
    DocumentReference reference = FirebaseFirestore.instance
        .collection('projects')
        .doc(GlobalConfiguration().getString('projectId'))
        .collection('coachAssignments')
        .doc(userId)
        .collection('mediaMessages')
        .doc(messageVideoContent.id);
    reference.update({'viewed': true});
  }

  Future<void> markVideoMessageAsFavorite({String userId, CoachMediaMessage messageVideoContent}) async {
    DocumentReference reference = FirebaseFirestore.instance
        .collection('projects')
        .doc(GlobalConfiguration().getString('projectId'))
        .collection('coachAssignments')
        .doc(userId)
        .collection('mediaMessages')
        .doc(messageVideoContent.id);
    reference.update({'favorite': !messageVideoContent.favorite});
  }
}
