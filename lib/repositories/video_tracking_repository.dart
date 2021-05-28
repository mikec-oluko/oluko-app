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
        finalCollection.document(parentVideoId).collection("videoTracking");
    var documents = await finalCollection.getDocuments();
    if (documents.documents.length == 1) {
      VideoTracking videoTrackingToDelete =
          VideoTracking.fromJson(documents.documents[0].data);
      await finalCollection.document(videoTrackingToDelete.id).delete();
    }
    final DocumentReference docRef = finalCollection.document();
    videoTracking.id = docRef.documentID;
    docRef.setData(videoTracking.toJson());
  }

  static Future<VideoTracking> getVideoTrackingWithPath(
      String videoId, String idPath) async {
    CollectionReference finalCollection =
        FirestoreRepository.goInsideVideoResponses(idPath);
    finalCollection =
        finalCollection.document(videoId).collection("videoTracking");
    var documents = await finalCollection.getDocuments();
    if (documents.documents.length == 1) {
      VideoTracking videoTracking =
          VideoTracking.fromJson(documents.documents[0].data);
      return videoTracking;
    } else {
      return null;
    }
  }
}
