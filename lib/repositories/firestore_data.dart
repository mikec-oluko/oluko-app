import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreProvider {
  String collection;
  Firestore firestoreInstance;

  FirestoreProvider({collection}) {
    this.collection = collection;
    this.firestoreInstance = Firestore.instance;
  }

  FirestoreProvider.test({String collection, Firestore firestoreInstance}) {
    this.collection = collection;
    this.firestoreInstance = firestoreInstance;
  }

  Future<QuerySnapshot> getAll() {
    return firestoreInstance.collection(collection).getDocuments();
  }

  Future<DocumentSnapshot> get(String id) {
    return firestoreInstance.collection(collection).document(id).get();
  }

  Future<QuerySnapshot> getChild(String id, String childCollection) {
    return firestoreInstance
        .collection(collection)
        .document(id)
        .collection(childCollection)
        .getDocuments();
  }

  ///Get documents list from nested collections.
  ///
  ///[id] final document id after path.
  ///[childCollection] child collection present on every document in the path.
  ///[idPath] document id path to the [id] document. Ex. `{document_id}/{document_id}/{document_id}`.
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
          finalCollection.document(idPathElement).collection(childCollection);
    });
    finalCollection = finalCollection.document(id).collection(childCollection);
    return finalCollection.getDocuments();
  }

  Future<DocumentReference> add(dynamic entity) {
    return firestoreInstance.collection(collection).add(entity);
  }

  Future<void> set({String id, dynamic entity}) {
    return firestoreInstance
        .collection(collection)
        .document(id)
        .setData(entity);
  }

  Stream<QuerySnapshot> listenAll() {
    return firestoreInstance.collection(collection).snapshots();
  }

  void addBatch(List<dynamic> entities) {
    entities.forEach((dynamic entity) {
      add(entity);
    });
  }
}
