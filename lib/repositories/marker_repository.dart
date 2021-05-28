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

  Future<Marker> createMarker1(Marker marker) async {
    final DocumentReference docRef =
        firestoreInstance.collection('markers').doc();
    docRef.set({
      'id': docRef.id,
      'position': marker.position,
      'videoId': marker.videoId,
    });
    marker.id = docRef.id;
    return marker;
  }

  createMarker(String parentVideoId, Marker marker) {
    final DocumentReference docRef =
        firestoreInstance.collection('videos').doc(parentVideoId);
    final DocumentReference responseDocRef = docRef.collection('markers').doc();
    responseDocRef.set(marker.toJson());
    return responseDocRef.id;
  }

  Future<List<Marker>> getVideoMarkers1(String videoId) async {
    List<Marker> markers = [];
    QuerySnapshot docRef = await FirebaseFirestore.instance
        .collection('markers')
        .where('videoId', isEqualTo: videoId)
        .get();
    docRef.docs.forEach((marker) {
      Marker newMarker = Marker.fromJson(marker.data());
      markers.add(newMarker);
    });
    return markers;
  }

  Future<List<Marker>> getVideoMarkers(String parentVideoId) async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('videos')
        .doc(parentVideoId)
        .collection('markers')
        .get();

    return mapQueryToMarker(querySnapshot);
  }

  static mapQueryToMarker(QuerySnapshot qs) {
    return qs.docs.map((DocumentSnapshot ds) {
      return Marker(
        id: ds.id,
        position: ds.get('position'),
        videoId: ds.get('videoId'),
      );
    }).toList();
  }
}
