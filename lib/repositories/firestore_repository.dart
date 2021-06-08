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
        //DE ESTA FORMA SERVIA PARA LOS MARKERS CREO

    final DocumentReference docRef = finalCollection.doc();

    entity.id = docRef.id;
    docRef.set(entity.toJson());

    return entity;
  }

  static CollectionReference goInsideVideoResponses(String idPath) {
    //Go inside "videos" collection
    CollectionReference finalCollection =
        FirebaseFirestore.instance.collection("videos");

    //Split path by '/'
    List<String> idPathList = idPath.split('/');
    idPathList = idPathList.length > 0 && idPathList[0] == '' ? [] : idPathList;

    //If path has at least one video, it goes inside its video responses
    idPathList.forEach((idPathElement) {
      finalCollection =
          finalCollection.doc(idPathElement).collection('videoResponses');
    });

    //Returns the reference to the collection in wich the video or 
    //video response is going to be created
    return finalCollection;
  }
}
