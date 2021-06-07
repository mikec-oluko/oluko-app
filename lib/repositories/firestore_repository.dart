import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreRepository {
  String collection;
  FirebaseFirestore firestoreInstance;

  FirestoreRepository({collection}) {
    this.collection = collection;
    this.firestoreInstance = FirebaseFirestore.instance;
  }

  FirestoreRepository.test(
      {String collection, FirebaseFirestore firestoreInstance}) {
    this.collection = collection;
    this.firestoreInstance = firestoreInstance;
  }

  Future<QuerySnapshot> getChildWithPath(
      String id, String childCollection, String idPath) {
    List<String> idPathList = idPath.split('/');
    if (idPathList[0] == '') {
      idPathList = [];
    }
    CollectionReference finalCollection =
        firestoreInstance.collection(collection);
    idPathList.forEach((idPathElement) {
      finalCollection =
          finalCollection.doc(idPathElement).collection(childCollection);
    });
    finalCollection = finalCollection.doc(id).collection(childCollection);
    return finalCollection.get();
  }

  static createVideoChild(String parentVideoId, dynamic entity, String idPath,
      String childCollection) {
    CollectionReference finalCollection = goInsideVideoResponses(idPath);
    //finalCollection =
        //finalCollection.doc(parentVideoId).collection(childCollection);

    final DocumentReference docRef = finalCollection.doc();

    entity.id = docRef.id;
    docRef.set(entity.toJson());

    return entity;
  }

  static CollectionReference goInsideVideoResponses(String idPath) {
    List<String> idPathList = idPath.split('/');
    idPathList = idPathList.length > 0 && idPathList[0] == '' ? [] : idPathList;
    CollectionReference finalCollection =
        FirebaseFirestore.instance.collection("videos");

    idPathList.forEach((idPathElement) {
      finalCollection =
          finalCollection.doc(idPathElement).collection('videoResponses');
    });
    return finalCollection;
  }
}
