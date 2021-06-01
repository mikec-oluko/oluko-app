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

  Future<QuerySnapshot> getAll() {
    return this.firestoreInstance.collection(collection).get();
  }

  Future<DocumentSnapshot> get(String id) {
    return firestoreInstance.collection(collection).doc(id).get();
  }

  Future<QuerySnapshot> getChild(String id, String childCollection) {
    return firestoreInstance
        .collection(collection)
        .doc(id)
        .collection(childCollection)
        .get();
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
          finalCollection.doc(idPathElement).collection(childCollection);
    });
    finalCollection = finalCollection.doc(id).collection(childCollection);
    return finalCollection.get();
  }

  Future<DocumentReference> add(dynamic entity) {
    return firestoreInstance.collection(collection).add(entity);
  }

  Future<void> set({String id, dynamic entity}) {
    return firestoreInstance.collection(collection).doc(id).set(entity);
  }

  Stream<QuerySnapshot> listenAll() {
    return firestoreInstance.collection(collection).snapshots();
  }

  void addBatch(List<dynamic> entities) {
    entities.forEach((dynamic entity) {
      add(entity);
    });
  }

  static createVideoChild(String parentVideoId, dynamic entity, String idPath,
      String childCollection) {
    CollectionReference finalCollection = goInsideVideoResponses(idPath);
    finalCollection =
        finalCollection.doc(parentVideoId).collection(childCollection);

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
