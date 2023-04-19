import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:oluko_app/models/submodels/object_submodel.dart';
import 'base.dart';

class Course extends Base {
  String name;
  String video;
  String videoHls;
  String duration;
  String description;
  List<ObjectSubmodel> classes;
  List<ObjectSubmodel> tags;
  String image;
  String posterImage;
  List<dynamic> images;
  DocumentReference statisticsReference;
  bool hasChat;

  Course(
      {this.name,
      this.statisticsReference,
      this.duration,
      this.classes,
      this.tags,
      this.image,
      this.posterImage,
      this.images,
      this.video,
      this.videoHls,
      this.description,
      this.hasChat,
      String id,
      Timestamp createdAt,
      String createdBy,
      Timestamp updatedAt,
      String updatedBy,
      bool isHidden,
      bool isDeleted})
      : super(id: id, createdBy: createdBy, createdAt: createdAt, updatedAt: updatedAt, updatedBy: updatedBy, isDeleted: isDeleted, isHidden: isHidden);

  factory Course.fromJson(Map<String, dynamic> json) {
    if (json == null) {
      return null;
    }
    Course course = Course(
      name: json['name']?.toString(),
      statisticsReference: json['statistics_reference'] != null ? json['statistics_reference'] as DocumentReference : null,
      video: json['video']?.toString(),
      videoHls: json['video_hls']?.toString(),
      duration: json['duration'] == null ? '0' : json['duration'].toString(),
      description: json['description']?.toString(),
      classes: json['classes'] != null
          ? List<ObjectSubmodel>.from((json['classes'] as Iterable).map((c) => ObjectSubmodel.fromJson(c as Map<String, dynamic>)))
          : null,
      tags: json['tags'] != null ? List<ObjectSubmodel>.from((json['tags'] as Iterable).map((c) => ObjectSubmodel.fromJson(c as Map<String, dynamic>))) : null,
      image: json['image']?.toString(),
      images: json['images'] as List<dynamic>,
      posterImage: json['poster_image']?.toString(),
      hasChat: json['hasChat'] == null ? false : json['hasChat'] as bool,
    );
    course.setBase(json);
    return course;
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> courseJson = {
      'name': name,
      'statistics_reference': statisticsReference,
      'video': video,
      'video_hls': videoHls,
      'duration': duration,
      'description': description,
      'tags': tags == null ? null : tags,
      'classes': classes == null ? null : List<dynamic>.from(classes.map((c) => c.toJson())),
      'image': image,
      'images': images,
      'hasChat': hasChat
    };
    courseJson.addEntries(super.toJson().entries);
    return courseJson;
  }
}
