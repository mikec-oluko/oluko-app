import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:oluko_app/models/draw_point.dart';
import 'package:oluko_app/models/video.dart';
import 'package:oluko_app/models/video_tracking.dart';
import 'package:oluko_app/repositories/firestore_repository.dart';

class VideoRepository {
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

  /*static Future<List<Video>> getVideos() async {
    final querySnapshot =
        await Firestore.instance.collection('videos').getDocuments();
    return mapQueryToVideo(querySnapshot);
  }*/

  static Future<List<Video>> getVideosByUser(String userId) async {
    final querySnapshot = await Firestore.instance
        .collection('videos')
        .where("createdBy", isEqualTo: userId)
        .getDocuments();
    return mapQueryToVideo(querySnapshot);
  }

  static Video createVideoResponse(
      String parentVideoId, Video videoResponse, String idPath) {
    return FirestoreRepository.createVideoChild(
        parentVideoId, videoResponse, idPath, 'videoResponses');
  }

  static createVideoTracking(String parentVideoId,
      List<DrawPoint> canvasPointsRecording, String idPath) async {
    VideoTracking videoTracking = VideoTracking(
        drawPoints: jsonEncode(canvasPointsRecording.map((e) {
      if (e.point == null) {
        return {"x": null, "y": null, "timeStamp": e.timeStamp};
      }
      return {
        "x": e.point.points.dx,
        "y": e.point.points.dy,
        "timeStamp": e.timeStamp
      };
    }).toList()));

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

  static mapQueryToVideo(QuerySnapshot qs) {
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
      //return Video.fromJson(ds.data);
    }).toList();
  }

  static Future<List<Video>> getVideoResponsesWithPath(
      String videoId, String idPath) async {
    CollectionReference finalCollection =
        FirestoreRepository.goInsideVideoResponses(idPath);
    finalCollection =
        finalCollection.document(videoId).collection("videoResponses");

    return mapQueryToVideo(await finalCollection.getDocuments());
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
