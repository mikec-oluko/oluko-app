import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:oluko_app/models/tag.dart';
import 'package:oluko_app/models/tag_category.dart';

class TagCategoryRepository {
  FirebaseFirestore firestoreInstance;

  TagCategoryRepository() {
    firestoreInstance = FirebaseFirestore.instance;
  }

  TagCategoryRepository.test({FirebaseFirestore firestoreInstance}) {
    this.firestoreInstance = firestoreInstance;
  }

  Future<List<TagCategory>> getAll() async {
    QuerySnapshot docRef = await FirebaseFirestore.instance
        .collection('projects')
        .doc(GlobalConfiguration().getString('projectId'))
        .collection('tagsCategories')
        .where('is_deleted', isNotEqualTo: true)
        .get();
    List<TagCategory> response = [];
    docRef.docs.forEach((doc) {
      final Map<String, dynamic> element = doc.data() as Map<String, dynamic>;
      response.add(TagCategory.fromJson(element));
    });
    return response;
  }
}
