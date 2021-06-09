import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:oluko_app/models/video.dart';

class VideoRepository {
  static Video createVideo(Video video, CollectionReference reference) {
    final DocumentReference docRef = reference.doc();
    video.id = docRef.id;
    docRef.set(video.toJson());
    return video;
  }

  static Future<List<Video>> getVideosByUser(
      String userId, CollectionReference reference) async {
    final querySnapshot = await reference
        .orderBy("uploaded_at", descending: true)
        .where("created_by", isEqualTo: userId)
        .get();
    return mapQueryToVideo(querySnapshot);
  }

  static mapQueryToVideo(QuerySnapshot qs) {
    return qs.docs.map((DocumentSnapshot ds) {
      return Video.fromJson(ds.data());
    }).toList();
  }
}
