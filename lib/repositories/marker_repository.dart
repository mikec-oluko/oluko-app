import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:oluko_app/models/marker.dart';

class MarkerRepository {
  Future<Marker> createMarker1(Marker marker) async {
    final DocumentReference docRef =
        Firestore.instance.collection('markers').document();
    docRef.setData({
      'id': docRef.documentID,
      'position': marker.position,
      'videoId': marker.videoId,
    });
    marker.id = docRef.documentID;
    return marker;
  }

  Future<Marker> createMarker(String parentVideoId, Marker marker) async{
    final DocumentReference docRef =
        Firestore.instance.collection('videos').document(parentVideoId);
    final DocumentReference responseDocRef =
        docRef.collection('markers').document();
    responseDocRef.setData(marker.toJson());
        marker.id = responseDocRef.documentID;
    return marker;
  }

  Future<List<Marker>> getVideoMarkers1(String videoId) async {
    List<Marker> markers = [];
    QuerySnapshot docRef = await Firestore.instance
        .collection('markers')
        .where('videoId', isEqualTo: videoId)
        .getDocuments();
    docRef.documents.forEach((marker) {
      Marker newMarker = Marker.fromJson(marker.data);
      markers.add(newMarker);
    });
    return markers;
  }

  Future<List<Marker>> getVideoMarkers(String parentVideoId) async {
    QuerySnapshot querySnapshot = await Firestore.instance
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
        videoId: ds.data['videoId'],
      );
    }).toList();
  }
}
