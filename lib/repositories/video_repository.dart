import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:oluko_app/models/video.dart';

class VideoRepository {
  static saveVideo(Video video) async {
    final DocumentReference docRef =
        Firestore.instance.collection('videos').document();
    docRef.setData(video.toJson());
    return docRef.documentID;
  }

  static listenToVideos(callback) async {
    Firestore.instance.collection('videos').snapshots().listen((qs) {
      final videos = mapQueryToVideoInfo(qs);
      callback(videos);
    });
  }

  static Future<List<Video>> getVideos() async {
    final querySnapshot =
        await Firestore.instance.collection('videos').getDocuments();
    return mapQueryToVideoInfo(querySnapshot);
  }

  static Future<List<Video>> getVideosByUser(FirebaseUser user) async {
    final querySnapshot = await Firestore.instance
        .collection('videos')
        .where("createdBy", isEqualTo: user.uid)
        .getDocuments();
    return mapQueryToVideoInfo(querySnapshot);
  }

  static addVideoResponse(parentVideoId, videoResponse) {
    final DocumentReference docRef =
        Firestore.instance.collection('videos').document(parentVideoId);
    final DocumentReference responseDocRef =
        docRef.collection('videoResponses').document();
    responseDocRef.setData(videoResponse.toJson());
    return responseDocRef.documentID;
  }

  static Future<List<Video>> getVideoResponses(parentVideoId) async {
    QuerySnapshot querySnapshot = await Firestore.instance
        .collection('videos')
        .document(parentVideoId)
        .collection('videoResponses')
        .getDocuments();

    return mapQueryToVideoInfo(querySnapshot);
  }

  static mapQueryToVideoInfo(QuerySnapshot qs) {
    return qs.documents.map((DocumentSnapshot ds) {
      return Video(
        id: ds.documentID,
        videoUrl: ds.data['videoUrl'],
        thumbUrl: ds.data['thumbUrl'],
        coverUrl: ds.data['coverUrl'],
        aspectRatio: ds.data['aspectRatio'],
        videoName: ds.data['videoName'],
        uploadedAt: ds.data['uploadedAt'],
        createdBy: ds.data['createdBy'],
      );
    }).toList();
  }
}
