import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:oluko_app/models/faq_item.dart';

class FAQRepository {
  FirebaseFirestore firestoreInstance;

  FAQRepository() {
    firestoreInstance = FirebaseFirestore.instance;
  }

  FAQRepository.test({FirebaseFirestore firestoreInstance}) {
    this.firestoreInstance = firestoreInstance;
  }

  static Future<List<FAQItem>> getAll() async {
    QuerySnapshot docRef =
        await FirebaseFirestore.instance.collection('projects').doc(GlobalConfiguration().getString('projectId')).collection('faq').orderBy('index').get();
    List<FAQItem> response = [];
    docRef.docs.forEach((doc) {
      response.add(FAQItem.fromJson(doc.data() as Map<String, dynamic>));
    });
    return response;
  }
}
