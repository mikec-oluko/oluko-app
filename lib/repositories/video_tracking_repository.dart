import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:oluko_app/models/draw_point.dart';
import 'package:oluko_app/models/video_tracking.dart';

class VideoTrackingRepository {
  static createVideoTracking(List<DrawPoint> canvasPointsRecording,
      DocumentReference reference) async {
    if (canvasPointsRecording.length == 0) {
      return;
    }
    VideoTracking videoTracking =
        VideoTracking(drawPoints: canvasPointsRecording);

    CollectionReference videoTrackingCollection =
        reference.collection("videoTracking");

    var documents = await videoTrackingCollection.get();
    if (documents.docs.length == 1) {
      VideoTracking videoTrackingToDelete =
          VideoTracking.fromJson(documents.docs.single.data());
      await videoTrackingCollection.doc(videoTrackingToDelete.id).delete();
    }
    final DocumentReference docRef = videoTrackingCollection.doc();
    videoTracking.id = docRef.id;
    docRef.set(videoTracking.toJson());
  }

  static Future<VideoTracking> getVideoTracking(
      DocumentReference reference) async {
    CollectionReference videoTrackingCollection =
        reference.collection("videoTracking");
    var documents = await videoTrackingCollection.get();
    if (documents.docs.length == 1) {
      VideoTracking videoTracking =
          VideoTracking.fromJson(documents.docs.single.data());
      return videoTracking;
    } else {
      return null;
    }
  }
}
