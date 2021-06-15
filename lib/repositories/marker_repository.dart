import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:oluko_app/models/marker.dart';

class MarkerRepository {
  FirebaseFirestore firestoreInstance;

  MarkerRepository() {
    this.firestoreInstance = FirebaseFirestore.instance;
  }

  MarkerRepository.test({FirebaseFirestore firestoreInstance}) {
    this.firestoreInstance = firestoreInstance;
  }

  static Future<Marker> createMarker(
      Marker marker, DocumentReference reference) async {
    CollectionReference markerCollection = reference.collection("markers");
    final DocumentReference docRef = markerCollection.doc();
    marker.id = docRef.id;
    docRef.set(marker.toJson());
    return marker;
  }

  static Future<List<Marker>> getMarkers(DocumentReference reference) async {
    CollectionReference markerCollection = reference.collection("markers");
    return mapQueryToMarker(await markerCollection.get());
  }

  static mapQueryToMarker(QuerySnapshot qs) {
    return qs.docs.map((DocumentSnapshot ds) {
      return Marker.fromJson(ds.data());
    }).toList();
  }
}
