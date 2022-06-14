import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:oluko_app/models/annotation.dart';
import 'package:oluko_app/models/coach_media_message.dart';
import 'package:oluko_app/models/submodels/video.dart';

class CoachPersonalizedVideo {
  Timestamp createdAt;
  Video videoContent;
  String videoHls;
  Annotation annotationContent;
  CoachMediaMessage videoMessageContent;
  CoachPersonalizedVideo({this.createdAt, this.videoContent, this.videoHls, this.annotationContent, this.videoMessageContent});
}
