import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:mvt_fitness/models/tag.dart';

class TagRepository {
  FirebaseFirestore firestoreInstance;

  TagRepository() {
    firestoreInstance = FirebaseFirestore.instance;
  }

  TagRepository.test({FirebaseFirestore firestoreInstance}) {
    this.firestoreInstance = firestoreInstance;
  }

  Future<List<Tag>> getAll() async {
    QuerySnapshot docRef = await FirebaseFirestore.instance
        .collection('projects')
        .doc(GlobalConfiguration().getValue("projectId"))
        .collection('tags')
        .get();
    List<Tag> response = [];
    docRef.docs.forEach((doc) {
      final Map<String, dynamic> element = doc.data();
      response.add(Tag.fromJson(element));
    });
    return response;
  }
}
