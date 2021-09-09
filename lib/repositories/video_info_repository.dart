import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:oluko_app/models/submodels/draw_point.dart';
import 'package:oluko_app/models/submodels/video_info.dart';

class VideoInfoRepository {
  FirebaseFirestore firestoreInstance;

  VideoInfoRepository() {
    this.firestoreInstance = FirebaseFirestore.instance;
  }

  static VideoInfo createVideoInfo(
      VideoInfo videoInfo, CollectionReference reference) {
    final DocumentReference docRef = reference.doc();
    videoInfo.id = docRef.id;
    docRef.set(videoInfo.toJson());
    return videoInfo;
  }

  static Future<List<VideoInfo>> getVideosInfoByUser(
      String userId, CollectionReference reference) async {
    final querySnapshot = await reference
        .orderBy("created_at", descending: true)
        .where("created_by", isEqualTo: userId)
        .get();
    return mapQueryToVideoInfo(querySnapshot);
  }

  static List<VideoInfo> mapQueryToVideoInfo(QuerySnapshot qs) {
    return qs.docs.map((DocumentSnapshot ds) {
      return VideoInfo.fromJson(ds.data() as Map<String, dynamic>);
    }).toList();
  }

  static addDrawingToVideoInfo(
      List<DrawPoint> canvasPointsRecording, DocumentReference reference) {
    if (canvasPointsRecording.length == 0) {
      return;
    }
    reference.update({
      'drawing': List<dynamic>.from(
          canvasPointsRecording.map((drawPoint) => drawPoint.toJson()))
    });
  }

  static Future<double> addMarkerToVideoInfo(
      double marker, DocumentReference reference) async {
    final ds = await reference.get();
    VideoInfo videoInfo = VideoInfo.fromJson(ds.data() as Map<String, dynamic>);
    List<double> markers = videoInfo.markers;
    if (!markers.contains(marker)) {
      markers.add(marker);
    }
    reference.update({'markers': markers});
  }
}
