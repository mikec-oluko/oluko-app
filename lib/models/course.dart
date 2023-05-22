import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:oluko_app/models/submodels/object_submodel.dart';
import 'base.dart';

class Course extends Base {
  String name;
  String video;
  String videoHls;
  String duration;
  String description;
  String scheduleRecommendations;
  List<ObjectSubmodel> classes;
  List<ObjectSubmodel> tags;
  List<String> userSelfies;
  String image;
  String posterImage;
  List<dynamic> images;
  DocumentReference statisticsReference;
  bool hasChat;
  List<DateTime> scheduledDates;
  List<String> weekDays;

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
      this.scheduleRecommendations,
      this.hasChat,
      this.userSelfies,
      this.weekDays,
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
      scheduleRecommendations: json['schedule_recommendations']?.toString(),
      classes: json['classes'] != null
          ? List<ObjectSubmodel>.from((json['classes'] as Iterable).map((c) => ObjectSubmodel.fromJson(c as Map<String, dynamic>)))
          : null,
      tags: json['tags'] != null ? List<ObjectSubmodel>.from((json['tags'] as Iterable).map((c) => ObjectSubmodel.fromJson(c as Map<String, dynamic>))) : null,
      image: json['image']?.toString(),
      images: json['images'] as List<dynamic>,
      posterImage: json['poster_image']?.toString(),
      hasChat: json['has_chat'] == null ? false : json['has_chat'] as bool,
      userSelfies: json['user_selfies'] == null || json['user_selfies'].runtimeType == String
          ? null
          : json['user_selfies'] is String
              ? [json['user_selfies'] as String]
              : List<String>.from((json['user_selfies'] as Iterable).map((userSelfie) => userSelfie as String)),
      weekDays: json['week_days'] as List<String>
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
      'schedule_recommendations': scheduleRecommendations,
      'tags': tags == null ? null : tags,
      'classes': classes == null ? null : List<dynamic>.from(classes.map((c) => c.toJson())),
      'image': image,
      'images': images,
      'has_chat': hasChat
    };
    courseJson.addEntries(super.toJson().entries);
    return courseJson;
  }
}
