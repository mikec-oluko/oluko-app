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

  static addVideoResponse1(parentVideoId, videoResponse) {
    final DocumentReference docRef =
        Firestore.instance.collection('videos').document(parentVideoId);
    final DocumentReference responseDocRef =
        docRef.collection('videoResponses').document();
    videoResponse.id = responseDocRef.documentID;
    responseDocRef.setData(videoResponse.toJson());
    return responseDocRef.documentID;
  }

  static addVideoResponse(parentVideoId, videoResponse, String idPath) {
    List<String> idPathList = idPath.split('/');
    idPathList = idPathList.length > 0 && idPathList[0] == '' ? [] : idPathList;
    CollectionReference finalCollection =
        Firestore.instance.collection("videos");

    idPathList.forEach((idPathElement) {
      finalCollection =
          finalCollection.document(idPathElement).collection('videoResponses');
    });
    finalCollection =
        finalCollection.document(parentVideoId).collection('videoResponses');

    final DocumentReference docRef = finalCollection.document();

    videoResponse.id = docRef.documentID;
    docRef.setData(videoResponse.toJson());

    return docRef.documentID;
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
      //return Video.fromJson(ds.data);
    }).toList();
  }
}
