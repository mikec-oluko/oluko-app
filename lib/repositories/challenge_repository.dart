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
        .doc(GlobalConfiguration().getString('projectId'))
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

  static Future<List<Challenge>> getUserChallengesBySegmentId(String segmentId, String userId) async {
    final QuerySnapshot docRef = await FirebaseFirestore.instance
        .collection('projects')
        .doc(GlobalConfiguration().getString('projectId'))
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
    DocumentReference reference =
        FirebaseFirestore.instance.collection('projects').doc(GlobalConfiguration().getString('projectId')).collection('challenges').doc(id);
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

  static Future<List<Challenge>> getByClass(String courseEnrollmentId, String classId) async {
    final QuerySnapshot docRef = await FirebaseFirestore.instance
        .collection('projects')
        .doc(GlobalConfiguration().getString('projectId'))
        .collection('challenges')
        .where('course_enrollment_id', isEqualTo: courseEnrollmentId)
        .where('class_id', isEqualTo: classId)
        .get();
    if (docRef.docs.isNotEmpty) {
      return docRef.docs.map((challengeData) {
        final data = challengeData.data() as Map<String, dynamic>;
        return Challenge.fromJson(data);
      }).toList();
    }
    return null;
  }

  static Future<void> markAudioAsDeleted(Challenge challenge, List<Audio> audios) async {
    final DocumentReference reference =
        FirebaseFirestore.instance.collection('projects').doc(GlobalConfiguration().getString('projectId')).collection('challenges').doc(challenge.id);
    await reference.update({'audios': List<dynamic>.from(audios.map((audio) => audio.toJson()))});
  }

  static Future<void> markAudiosAsSeen(String challengeId, List<Audio> audios) async {
    final DocumentReference reference =
        FirebaseFirestore.instance.collection('projects').doc(GlobalConfiguration().getString('projectId')).collection('challenges').doc(challengeId);
    await reference.update({'audios': List<dynamic>.from(audios.map((audio) => audio.toJson()))});
  }

  static Future<List<Challenge>> getChallengesForUserRequested(
    String userRequestedId,
  ) async {
    List<Challenge> challengeList = [];
    final QuerySnapshot query = await FirebaseFirestore.instance
        .collection('projects')
        .doc(GlobalConfiguration().getString('projectId'))
        .collection('challenges')
        .where('user.id', isEqualTo: userRequestedId)
        .where('completed_at', isEqualTo: null)
        .get();
    for (var challengeDoc in query.docs) {
      final Map<String, dynamic> challenge = challengeDoc.data() as Map<String, dynamic>;
      Challenge newChallenge = Challenge.fromJson(challenge);
      if (challengeList.where((challenge) => challenge.classId == newChallenge.classId).isEmpty) {
        challengeList.add(newChallenge);
      }
    }
    return challengeList;
  }
}
