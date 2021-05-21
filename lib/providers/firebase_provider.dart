import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseProvider {
  static getUserByEmail(email) async {
    QuerySnapshot docRef = await FirebaseFirestore.instance
        .collection('users')
        .where('email', isEqualTo: email)
        .get();
    return docRef.docs[0].data();
  }

  static listenToVideos(callback) async {
    FirebaseFirestore.instance.collection('users').snapshots().listen((qs) {
      callback();
    });
  }

  static addVideoResponse(parentVideoKey, videoResponse) {
    final DocumentReference docRef =
        FirebaseFirestore.instance.collection('videos-app').doc(parentVideoKey);
    final DocumentReference responseDocRef =
        docRef.collection('video-responses').doc();
    responseDocRef.set({
      'videoUrl': videoResponse.videoUrl,
      'thumbUrl': videoResponse.thumbUrl,
      'coverUrl': videoResponse.coverUrl,
      'aspectRatio': videoResponse.aspectRatio,
      'uploadedAt': videoResponse.uploadedAt,
      'videoName': videoResponse.videoName,
      'key': responseDocRef.id
    });
    return responseDocRef.id;
  }
}
