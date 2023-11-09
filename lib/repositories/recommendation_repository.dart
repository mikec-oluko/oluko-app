import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:oluko_app/models/recommendation.dart';

class RecommendationRepository {
  FirebaseFirestore firestoreInstance;

  RecommendationRepository() {
    firestoreInstance = FirebaseFirestore.instance;
  }

  RecommendationRepository.test({FirebaseFirestore firestoreInstance}) {
    this.firestoreInstance = firestoreInstance;
  }

  Future<List<Recommendation>> getAll() async {
    QuerySnapshot docRef =
        await FirebaseFirestore.instance.collection('projects').doc(GlobalConfiguration().getString('projectId')).collection('recommendations').get();
    List<Recommendation> response = [];
    docRef.docs.forEach((doc) {
      final Map<String, dynamic> element = doc.data() as Map<String, dynamic>;
      response.add(Recommendation.fromJson(element));
    });
    return response;
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getRecommendationSubscriptionByDestinationUser(userId, coachId) {
    Stream<QuerySnapshot<Map<String, dynamic>>> annotationStream = FirebaseFirestore.instance
        .collection('projects')
        .doc(GlobalConfiguration().getString('projectId'))
        .collection('recommendations')
        .where('destination_user_id', isEqualTo: userId)
        .where('origin_user_id', isEqualTo: coachId)
        .where('is_deleted', isEqualTo: false)
        .snapshots();
    return annotationStream;
  }

  Future<List<Recommendation>> getByDestinationUser(userId) async {
    QuerySnapshot docRef = await FirebaseFirestore.instance
        .collection('projects')
        .doc(GlobalConfiguration().getString('projectId'))
        .collection('recommendations')
        .where('destination_user_id', isEqualTo: userId)
        .get();
    List<Recommendation> response = [];
    docRef.docs.forEach((doc) {
      final Map<String, dynamic> element = doc.data() as Map<String, dynamic>;
      response.add(Recommendation.fromJson(element));
    });
    return response;
  }

  void removeRecommendedCourse(String userId, String courseId) {
    FirebaseFirestore.instance
        .collection('projects')
        .doc(GlobalConfiguration().getString('projectId'))
        .collection('recommendations')
        .where('destination_user_id', isEqualTo: userId)
        .where('entity_id', isEqualTo: courseId)
        .get()
        .then((recommendations) {
      if (recommendations?.docs != null) {
        for (final recommendation in recommendations.docs) {
          recommendation.reference.update({'is_taken': true});
        }
      }
    });
  }
}
