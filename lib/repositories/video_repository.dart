import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:oluko_app/models/video.dart';

class VideoRepository {
  static saveVideo(Video video) async {
    final DocumentReference docRef =
        FirebaseFirestore.instance.collection('videos').doc();
    docRef.set(video.toJson());
    return docRef.id;
  }

  static listenToVideos(callback) async {
    FirebaseFirestore.instance.collection('videos').snapshots().listen((qs) {
      final videos = mapQueryToVideoInfo(qs);
      callback(videos);
    });
  }

  static Future<List<Video>> getVideos() async {
    final querySnapshot =
        await FirebaseFirestore.instance.collection('videos').get();
    return mapQueryToVideoInfo(querySnapshot);
  }

  static Future<List<Video>> getVideosByUser(User user) async {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('videos')
        .where("createdBy", isEqualTo: user.uid)
        .get();
    return mapQueryToVideoInfo(querySnapshot);
  }

  static addVideoResponse(parentVideoId, videoResponse) {
    final DocumentReference docRef =
        FirebaseFirestore.instance.collection('videos').doc(parentVideoId);
    final DocumentReference responseDocRef =
        docRef.collection('videoResponses').doc();
    responseDocRef.set(videoResponse.toJson());
    return responseDocRef.id;
  }

  static Future<List<Video>> getVideoResponses(parentVideoId) async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('videos')
        .doc(parentVideoId)
        .collection('videoResponses')
        .get();

    return mapQueryToVideoInfo(querySnapshot);
  }

  static mapQueryToVideoInfo(QuerySnapshot qs) {
    return qs.docs.map((DocumentSnapshot ds) {
      return Video(
        id: ds.id,
        videoUrl: ds.get('videoUrl'),
        thumbUrl: ds.get('thumbUrl'),
        coverUrl: ds.get('coverUrl'),
        aspectRatio: ds.get('aspectRatio'),
        videoName: ds.get('videoName'),
        uploadedAt: ds.get('uploadedAt'),
        createdBy: ds.get('createdBy'),
      );
    }).toList();
  }
}
