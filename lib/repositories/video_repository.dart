import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:oluko_app/models/video.dart';
import 'package:oluko_app/repositories/firestore_repository.dart';

class VideoRepository {
  static mapQueryToVideo(QuerySnapshot qs) {
    return qs.documents.map((DocumentSnapshot ds) {
      return Video.fromJson(ds.data);
    }).toList();
  }

  //VIDEOS
  static Future<Video> createVideo(Video video) async {
    final DocumentReference docRef =
        Firestore.instance.collection('videos').document();
    video.id = docRef.documentID;
    docRef.setData(video.toJson());
    return video;
  }

  static listenToVideos(callback) async {
    Firestore.instance.collection('videos').snapshots().listen((qs) {
      final videos = mapQueryToVideo(qs);
      callback(videos);
    });
  }

  static Future<List<Video>> getVideosByUser(String userId) async {
    final querySnapshot = await Firestore.instance
        .collection('videos')
        /*.orderBy("uploaded_at")*/
        .where("created_by", isEqualTo: userId)
        .getDocuments();

    return mapQueryToVideo(querySnapshot);
  }

  //VIDEO RESPONSES
  static Video createVideoResponse(
      String parentVideoId, Video videoResponse, String idPath) {
    return FirestoreRepository.createVideoChild(
        parentVideoId, videoResponse, idPath, 'videoResponses');
  }

  static Future<List<Video>> getVideoResponses(
      String videoId, String idPath) async {
    CollectionReference finalCollection =
        FirestoreRepository.goInsideVideoResponses(idPath);
    finalCollection = finalCollection
        .document(videoId)
        .collection("videoResponses")
        /*.orderBy("uploaded_at")*/;

    return mapQueryToVideo(await finalCollection.getDocuments());
  }
}
