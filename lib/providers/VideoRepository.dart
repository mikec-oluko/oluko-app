import 'package:cloud_firestore/cloud_firestore.dart';

class VideoRepository {
  static listenToVideos(callback) async {
    Firestore.instance.collection('users').snapshots().listen((qs) {
      callback();
    });
  }

  static addVideoResponse(parentVideoKey, videoResponse) {
    final DocumentReference docRef =
        Firestore.instance.collection('videos-app').document(parentVideoKey);
    final DocumentReference responseDocRef =
        docRef.collection('video-responses').document();
    responseDocRef.setData({
      'videoUrl': videoResponse.videoUrl,
      'thumbUrl': videoResponse.thumbUrl,
      'coverUrl': videoResponse.coverUrl,
      'aspectRatio': videoResponse.aspectRatio,
      'uploadedAt': videoResponse.uploadedAt,
      'videoName': videoResponse.videoName,
      'key': responseDocRef.documentID
    });
    return responseDocRef.documentID;
  }
}
