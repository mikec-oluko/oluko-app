import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:oluko_app/models/coach_audio_message.dart';
import 'package:oluko_app/models/submodels/audio_message_submodel.dart';

class CoachAudioMessagesRepository {
  FirebaseFirestore firestoreInstance;

  static DocumentReference projectReference =
      FirebaseFirestore.instance.collection('projects').doc(GlobalConfiguration().getValue('projectId'));

  CoachAudioMessagesRepository() {
    firestoreInstance = FirebaseFirestore.instance;
  }

  CoachAudioMessagesRepository.test({this.firestoreInstance});

  Stream<QuerySnapshot<Map<String, dynamic>>> getMessagesForCoachStream(String userId, String coachUserId) {
    Stream<QuerySnapshot<Map<String, dynamic>>> coachMessagesStream = FirebaseFirestore.instance
        .collection('projects')
        .doc(GlobalConfiguration().getValue('projectId'))
        .collection('audioSubmissions')
        .where('user_id', isEqualTo: userId)
        .where('coach_id', isEqualTo: coachUserId)
        .where('is_deleted', isNotEqualTo: true)
        .snapshots();

    return coachMessagesStream;
  }

  Future<CoachAudioMessage> saveAudioForCoach(AudioMessageSubmodel audioMessage, String userId, String coachId) async {
    DocumentReference userReference = getUserReference(userId);
    DocumentReference coachReference = getUserReference(coachId);

    CollectionReference reference =
        FirebaseFirestore.instance.collection('projects').doc(GlobalConfiguration().getValue('projectId')).collection('audioSubmissions');

    final DocumentReference docRef = reference.doc();

    CoachAudioMessage audioMessageToSave = CoachAudioMessage(
        id: docRef.id,
        userId: userId,
        userReference: userReference,
        coachId: coachId,
        coachReference: coachReference,
        audioMessage: audioMessage);
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
    final DocumentReference userReference = FirebaseFirestore.instance
        .collection('projects')
        .doc(GlobalConfiguration().getValue('projectId'))
        .collection('users')
        .doc(userRequestedId);
    return userReference;
  }

  DocumentReference<Object> getMessageReference(CoachAudioMessage audioMessage) {
    final DocumentReference audioMessageReference = FirebaseFirestore.instance
        .collection('projects')
        .doc(GlobalConfiguration().getValue('projectId'))
        .collection('audioSubmissions')
        .doc(audioMessage.id);
    return audioMessageReference;
  }
}
