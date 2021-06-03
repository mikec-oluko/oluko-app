import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:oluko_app/models/marker.dart';
import 'firestore_repository.dart';

class MarkerRepository {
  FirebaseFirestore firestoreInstance;

  MarkerRepository() {
    this.firestoreInstance = FirebaseFirestore.instance;
  }

  MarkerRepository.test({FirebaseFirestore firestoreInstance}) {
    this.firestoreInstance = firestoreInstance;
  }

  static Future<Marker> createMarker(
      String parentVideoId, Marker marker, String idPath) async {
    Marker newMarker = await FirestoreRepository.createVideoChild(
        parentVideoId, marker, idPath, 'markers');
    return newMarker;
  }

  static Future<List<Marker>> getMarkersWithPath(
      String videoId, String idPath) async {
    CollectionReference finalCollection =
        FirestoreRepository.goInsideVideoResponses(idPath);
    finalCollection = finalCollection.doc(videoId).collection("markers");
    return mapQueryToMarker(await finalCollection.get());
  }

  static mapQueryToMarker(QuerySnapshot qs) {
    return qs.docs.map((DocumentSnapshot ds) {
      return Marker.fromJson(ds.data());
    }).toList();
  }
}
