import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:oluko_app/models/marker.dart';

class MarkerRepository {
  Firestore firestoreInstance;

  MarkerRepository() {
    this.firestoreInstance = Firestore.instance;
  }

  MarkerRepository.test({Firestore firestoreInstance}) {
    this.firestoreInstance = firestoreInstance;
  }

  Future<Marker> createMarker(String parentVideoId, Marker marker) async {
    final DocumentReference docRef =
        firestoreInstance.collection('videos').document(parentVideoId);
    final DocumentReference responseDocRef =
        docRef.collection('markers').document();
    responseDocRef.setData(marker.toJson());
    marker.id = responseDocRef.documentID;
    return marker;
  }

  Future<List<Marker>> getVideoMarkers(String parentVideoId) async {
    QuerySnapshot querySnapshot = await firestoreInstance
        .collection('videos')
        .document(parentVideoId)
        .collection('markers')
        .getDocuments();

    return mapQueryToMarker(querySnapshot);
  }

  static mapQueryToMarker(QuerySnapshot qs) {
    return qs.documents.map((DocumentSnapshot ds) {
      return Marker(
        id: ds.documentID,
        position: ds.data['position'],
      );
    }).toList();
  }
}
