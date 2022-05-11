import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:oluko_app/models/submodels/questions_answers.dart';

class FAQRepository {
  FirebaseFirestore firestoreInstance;

  FAQRepository() {
    firestoreInstance = FirebaseFirestore.instance;
  }

  FAQRepository.test({FirebaseFirestore firestoreInstance}) {
    this.firestoreInstance = firestoreInstance;
  }

  static Future<List<QuestionAndAnswer>> getAll() async {
    QuerySnapshot docRef =
        await FirebaseFirestore.instance.collection('projects').doc(GlobalConfiguration().getValue('projectId')).collection('faq').get();
    List<QuestionAndAnswer> response = [];
    docRef.docs.forEach((doc) {
      response.add(QuestionAndAnswer.fromJson(doc.data() as Map<String, dynamic>));
    });
    return response;
  }
}
