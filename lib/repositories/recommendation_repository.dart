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
    QuerySnapshot docRef = await FirebaseFirestore.instance
        .collection('projects')
        .doc(GlobalConfiguration().getValue("projectId"))
        .collection('recommendations')
        .get();
    List<Recommendation> response = [];
    docRef.docs.forEach((doc) {
      final Map<String, dynamic> element = doc.data() as Map<String, dynamic>;
      response.add(Recommendation.fromJson(element));
    });
    return response;
  }

  Future<List<Recommendation>> getByDestinationUser(userId) async {
    QuerySnapshot docRef = await FirebaseFirestore.instance
        .collection('projects')
        .doc(GlobalConfiguration().getValue("projectId"))
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
}
