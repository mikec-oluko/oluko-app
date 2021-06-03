import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:oluko_app/models/video.dart';
import 'package:oluko_app/repositories/firestore_repository.dart';

class VideoRepository {
  static mapQueryToVideo(QuerySnapshot qs) {
    return qs.docs.map((DocumentSnapshot ds) {
      return Video.fromJson(ds.data());
    }).toList();
  }

  //VIDEOS
  static Future<Video> createVideo(Video video) async {
    final DocumentReference docRef =
        FirebaseFirestore.instance.collection('videos').doc();
    video.id = docRef.id;
    docRef.set(video.toJson());
    return video;
  }

  static listenToVideos(callback) async {
    FirebaseFirestore.instance.collection('videos').snapshots().listen((qs) {
      final videos = mapQueryToVideo(qs);
      callback(videos);
    });
  }

  static Future<List<Video>> getVideosByUser(String userId) async {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('videos')
        .orderBy("uploaded_at", descending: true)
        .where("created_by", isEqualTo: userId)
        .get();

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
    finalCollection = finalCollection.doc(videoId).collection("videoResponses");
    QuerySnapshot videoResponses =
        await finalCollection.orderBy("uploaded_at", descending: true).get();
    return mapQueryToVideo(videoResponses);
  }
}
