import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:oluko_app/models/draw_point.dart';
import 'package:oluko_app/models/video_tracking.dart';
import 'package:oluko_app/repositories/firestore_repository.dart';

class VideoTrackingRepository {
  static createVideoTracking(String parentVideoId,
      List<DrawPoint> canvasPointsRecording, String idPath) async {
    if (canvasPointsRecording.length == 0) {
      return;
    }
    VideoTracking videoTracking =
        VideoTracking(drawPoints: canvasPointsRecording);

    CollectionReference finalCollection =
        FirestoreRepository.goInsideVideoResponses(idPath);
    finalCollection =
        finalCollection.doc(parentVideoId).collection("videoTracking");
    var documents = await finalCollection.get();
    if (documents.docs.length == 1) {
      VideoTracking videoTrackingToDelete =
          VideoTracking.fromJson(documents.docs.single.data());
      await finalCollection.doc(videoTrackingToDelete.id).delete();
    }
    final DocumentReference docRef = finalCollection.doc();
    videoTracking.id = docRef.id;
    docRef.set(videoTracking.toJson());
  }

  static Future<VideoTracking> getVideoTracking(
      String videoId, String idPath) async {
    CollectionReference finalCollection =
        FirestoreRepository.goInsideVideoResponses(idPath);
    finalCollection = finalCollection.doc(videoId).collection("videoTracking");
    var documents = await finalCollection.get();
    if (documents.docs.length == 1) {
      VideoTracking videoTracking =
          VideoTracking.fromJson(documents.docs.single.data());
      return videoTracking;
    } else {
      return null;
    }
  }
}
