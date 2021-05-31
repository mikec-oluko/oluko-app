import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreRepository {
  String collection;
  Firestore firestoreInstance;

  FirestoreRepository({collection}) {
    this.collection = collection;
    this.firestoreInstance = Firestore.instance;
  }

  FirestoreRepository.test({String collection, Firestore firestoreInstance}) {
    this.collection = collection;
    this.firestoreInstance = firestoreInstance;
  }

  Future<QuerySnapshot> getAll() {
    return firestoreInstance.collection(collection).getDocuments();
  }

  Future<DocumentSnapshot> get(String id) {
    return firestoreInstance.collection(collection).document(id).get();
  }

  Future<QuerySnapshot> getChild(String id, String childCollection) { //NO SE USA
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

  static createVideoChild(String parentVideoId, dynamic entity, String idPath,
      String childCollection) {
    CollectionReference finalCollection = goInsideVideoResponses(idPath);
    finalCollection =
        finalCollection.document(parentVideoId).collection(childCollection);

    final DocumentReference docRef = finalCollection.document();

    entity.id = docRef.documentID;
    docRef.setData(entity.toJson());

    return entity;
  }

  static CollectionReference goInsideVideoResponses(String idPath) {
    List<String> idPathList = idPath.split('/');
    idPathList = idPathList.length > 0 && idPathList[0] == '' ? [] : idPathList;
    CollectionReference finalCollection =
        Firestore.instance.collection("videos");

    idPathList.forEach((idPathElement) {
      finalCollection =
          finalCollection.document(idPathElement).collection('videoResponses');
    });
    return finalCollection;
  }
}
