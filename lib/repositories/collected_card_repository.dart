import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:oluko_app/models/points_card.dart';

import '../models/collected_card.dart';

class CollectedCardRepository {
  FirebaseFirestore firestoreInstance;

  CollectedCardRepository() {
    this.firestoreInstance = FirebaseFirestore.instance;
  }

  static Future<CollectedCard> addCard(String userId, PointsCard pointsCard) async {
    final CollectionReference collectedCards = FirebaseFirestore.instance
        .collection('projects')
        .doc(GlobalConfiguration().getString('projectId'))
        .collection('users')
        .doc(userId)
        .collection('collectedCards');

    CollectedCard collectedCard = await get(userId, pointsCard.id);
    if (collectedCard != null) {
      collectedCard.multiplicity += 1;
    } else {
      collectedCard = CollectedCard(multiplicity: 1, card: pointsCard, id: pointsCard.id);
    }

    final DocumentReference docRef = collectedCards.doc(pointsCard.id);
    docRef.set(collectedCard.toJson());
    return collectedCard;
  }

  static Future<List<CollectedCard>> getAll(String userId) async {
    QuerySnapshot docRef = await FirebaseFirestore.instance
        .collection('projects')
        .doc(GlobalConfiguration().getString('projectId'))
        .collection('users')
        .doc(userId)
        .collection('collectedCards')
        .get();
    List<CollectedCard> cardsList = mapQueryToCollectedCard(docRef);
    return cardsList;
  }

  static Future<CollectedCard> get(String userId, String cardId) async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('projects')
        .doc(GlobalConfiguration().getString('projectId'))
        .collection('users')
        .doc(userId)
        .collection('collectedCards')
        .where('id', isEqualTo: cardId)
        .get();
    List<CollectedCard> collectedCards = mapQueryToCollectedCard(querySnapshot);
    return collectedCards.isEmpty ? null : collectedCards[0];
  }

  static List<CollectedCard> mapQueryToCollectedCard(QuerySnapshot qs) {
    return qs.docs.map((DocumentSnapshot ds) {
      Map<String, dynamic> collectedCard = ds.data() as Map<String, dynamic>;
      return CollectedCard.fromJson(collectedCard);
    }).toList();
  }
}
