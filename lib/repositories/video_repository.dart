import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:oluko_app/models/video.dart';

class VideoRepository {
  static createVideo(Video video) async {
    final DocumentReference docRef =
        Firestore.instance.collection('videos').document();
    docRef.setData(video.toJson());
    return docRef.documentID;
  }

  static listenToVideos(callback) async {
    Firestore.instance.collection('videos').snapshots().listen((qs) {
      final videos = mapQueryToVideo(qs);
      callback(videos);
    });
  }

  static Future<List<Video>> getVideos() async {
    final querySnapshot =
        await Firestore.instance.collection('videos').getDocuments();
    return mapQueryToVideo(querySnapshot);
  }

  static Future<List<Video>> getVideosByUser(FirebaseUser user) async {
    final querySnapshot = await Firestore.instance
        .collection('videos')
        .where("createdBy", isEqualTo: user.uid)
        .getDocuments();
    return mapQueryToVideo(querySnapshot);
  }

  static createVideoResponse(parentVideoId, videoResponse, String idPath) {
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

    return mapQueryToVideo(querySnapshot);
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

  ///Get documents list from nested collections.
  ///
  ///[id] final document id after path.
  ///[childCollection] child collection present on every document in the path.
  ///[idPath] document id path to the [id] document. Ex. `{document_id}/{document_id}/{document_id}`.
  static Future<List<Video>> getVideoResponsesWithPath(String id, String idPath) async{
    List<String> idPathList = idPath.split('/');
    if (idPathList[0] == '') {
      idPathList = [];
    }
    CollectionReference finalCollection = Firestore.instance.collection("videos");
    idPathList.forEach((idPathElement) {
      finalCollection =
          finalCollection.document(idPathElement).collection("videoResponses");
    });
    finalCollection = finalCollection.document(id).collection("videoResponses");

    return mapQueryToVideo(await finalCollection.getDocuments());
  }
}
