import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:oluko_app/models/challenge.dart';
import 'package:oluko_app/models/submodels/audio.dart';

class ChallengeRepository {
  FirebaseFirestore firestoreInstance;

  ChallengeRepository() {
    firestoreInstance = FirebaseFirestore.instance;
  }

  ChallengeRepository.test({FirebaseFirestore firestoreInstance}) {
    this.firestoreInstance = firestoreInstance;
  }

  static Future<List<Challenge>> getBySegmentId(String segmentId) async {
    final QuerySnapshot docRef = await FirebaseFirestore.instance
        .collection('projects')
        .doc(GlobalConfiguration().getValue('projectId'))
        .collection('challenges')
        .where('segment_id', isEqualTo: segmentId)
        .get();
    if (docRef.docs.isNotEmpty) {
      return docRef.docs.map((challengeData) {
        final data = challengeData.data() as Map<String, dynamic>;
        return Challenge.fromJson(data);
      }).toList();
    }
    return null;
  }

  static Future<List<Challenge>> getUserChallengesBySegmentId(
      String segmentId, String userId) async {
    final QuerySnapshot docRef = await FirebaseFirestore.instance
        .collection('projects')
        .doc(GlobalConfiguration().getValue('projectId'))
        .collection('challenges')
        .where('segment_id', isEqualTo: segmentId)
        .where('user.id', isEqualTo: userId)
        .get();
    if (docRef.docs.isNotEmpty) {
      return docRef.docs.map((challengeData) {
        final data = challengeData.data() as Map<String, dynamic>;
        return Challenge.fromJson(data);
      }).toList();
    }
    return null;
  }

  static Future<void> saveAudio(String id, Audio audio) async {
    DocumentReference reference = FirebaseFirestore.instance
        .collection('projects')
        .doc(GlobalConfiguration().getValue('projectId'))
        .collection('challenges')
        .doc(id);
    DocumentSnapshot ds = await reference.get();
    Challenge challenge = Challenge.fromJson(ds.data() as Map<String, dynamic>);
    List<Audio> audios;
    if (challenge.audios == null) {
      audios = [];
    } else {
      audios = challenge.audios;
    }
    audios.add(audio);

    reference.update({
      'audios': List<dynamic>.from(audios.map((a) => a.toJson())),
    });
  }
}
