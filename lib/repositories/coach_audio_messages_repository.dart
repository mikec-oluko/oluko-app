import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:oluko_app/models/coach_audio_message.dart';
import 'package:oluko_app/models/submodels/audio_message_submodel.dart';

class CoachAudioMessagesRepository {
  FirebaseFirestore firestoreInstance;

  static DocumentReference projectReference = FirebaseFirestore.instance.collection('projects').doc(GlobalConfiguration().getString('projectId'));

  CoachAudioMessagesRepository() {
    firestoreInstance = FirebaseFirestore.instance;
  }

  CoachAudioMessagesRepository.test({this.firestoreInstance});

  Stream<QuerySnapshot<Map<String, dynamic>>> getMessagesForCoachStream(String userId, String coachUserId) {
    Stream<QuerySnapshot<Map<String, dynamic>>> coachMessagesStream = firestoreInstance
        .collection('projects')
        .doc(GlobalConfiguration().getString('projectId'))
        .collection('audioSubmissions')
        .where('user_id', isEqualTo: userId)
        .where('coach_id', isEqualTo: coachUserId)
        .where('is_deleted', isNotEqualTo: true)
        .where('created_at', isNotEqualTo: null)
        .snapshots(includeMetadataChanges: true);
    return coachMessagesStream;
  }

  Future<CoachAudioMessage> saveAudioForCoach(AudioMessageSubmodel audioMessage, String userId, String coachId) async {
    DocumentReference userReference = getUserReference(userId);
    DocumentReference coachReference = getUserReference(coachId);

    CollectionReference reference = firestoreInstance.collection('projects').doc(GlobalConfiguration().getString('projectId')).collection('audioSubmissions');

    final DocumentReference docRef = reference.doc();

    CoachAudioMessage audioMessageToSave = CoachAudioMessage(
        id: docRef.id, userId: userId, userReference: userReference, coachId: coachId, coachReference: coachReference, audioMessage: audioMessage);
    await docRef.set(audioMessageToSave.toJson());
    return audioMessageToSave;
  }

  Future<CoachAudioMessage> markAudioAsDeleted(CoachAudioMessage audioMessage) async {
    DocumentReference<Object> audioReference = getMessageReference(audioMessage);
    audioMessage.isDeleted = true;
    await audioReference.update(audioMessage.toJson());
    return audioMessage;
  }

  DocumentReference<Object> getUserReference(String userRequestedId) {
    final DocumentReference userReference =
        firestoreInstance.collection('projects').doc(GlobalConfiguration().getString('projectId')).collection('users').doc(userRequestedId);
    return userReference;
  }

  DocumentReference<Object> getMessageReference(CoachAudioMessage audioMessage) {
    final DocumentReference audioMessageReference =
        firestoreInstance.collection('projects').doc(GlobalConfiguration().getString('projectId')).collection('audioSubmissions').doc(audioMessage.id);
    return audioMessageReference;
  }

  Future<CoachAudioMessage> getAudioMessage(String audioMessageId) async {
    DocumentReference docRef =
        FirebaseFirestore.instance.collection('projects').doc(GlobalConfiguration().getString('projectId')).collection('audioSubmissions').doc(audioMessageId);
    DocumentSnapshot updatedAudioMessage = await docRef.get();
    return CoachAudioMessage.fromJson(updatedAudioMessage.data() as Map<String, dynamic>);
  }
}
