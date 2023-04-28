import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:oluko_app/models/favorite.dart';

class FavoriteRepository {
  FirebaseFirestore firestoreInstance;

  FavoriteRepository() {
    firestoreInstance = FirebaseFirestore.instance;
  }

  FavoriteRepository.test({FirebaseFirestore firestoreInstance}) {
    this.firestoreInstance = firestoreInstance;
  }

  Future<List<Favorite>> getAll() async {
    QuerySnapshot docRef =
        await FirebaseFirestore.instance.collection('projects').doc(GlobalConfiguration().getString('projectId')).collection('favorites').get();
    List<Favorite> response = [];
    docRef.docs.forEach((doc) {
      final Map<String, dynamic> element = doc.data() as Map<String, dynamic>;
      response.add(Favorite.fromJson(element));
    });
    return response;
  }

  Future<List<Favorite>> getByUserId(userId) async {
    QuerySnapshot docRef = await FirebaseFirestore.instance
        .collection('projects')
        .doc(GlobalConfiguration().getString('projectId'))
        .collection('favorites')
        .where('user_id', isEqualTo: userId)
        .get();
    List<Favorite> response = [];
    docRef.docs.forEach((doc) {
      final Map<String, dynamic> element = doc.data() as Map<String, dynamic>;
      response.add(Favorite.fromJson(element));
    });
    return response;
  }
}
