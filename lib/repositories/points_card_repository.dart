import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:oluko_app/models/points_card.dart';

class PointsCardRepository {
  FirebaseFirestore firestoreInstance;

  PointsCardRepository() {
    this.firestoreInstance = FirebaseFirestore.instance;
  }

  static Future<List<PointsCard>> get(String userId) async {
    QuerySnapshot docRef = await FirebaseFirestore.instance
        .collection('projects')
        .doc(GlobalConfiguration().getString('projectId'))
        .collection('pointsCards')
        .where('is_deleted', isEqualTo: false)
        .get();
    List<PointsCard> cardsList = mapQueryToPointsCard(docRef);
    return cardsList;
  }
  static List<PointsCard> mapQueryToPointsCard(QuerySnapshot qs) {
    return qs.docs.map((DocumentSnapshot ds) {
      Map<String, dynamic> data = ds.data() as Map<String, dynamic>;
      return PointsCard.fromJson(data);
    }).toList();
  }
}
