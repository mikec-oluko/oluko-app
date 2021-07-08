import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mvt_fitness/models/submodels/object_submodel.dart';
import 'base.dart';

class Course extends Base {
  String name;
  String video;
  Timestamp duration;
  String description;
  List<String> equipment;
  List<String> intensity;
  List<String> categories;
  List<String> workoutDuration;
  bool recommendedEngagement;
  bool recommendedEngagementGap;
  dynamic engagementGapTime;
  dynamic engagementTime;
  bool mandatoryGapTime;
  List<ObjectSubmodel> classes;
  List<ObjectSubmodel> tags;
  String imageUrl;
  DocumentReference statisticsReference;

  Course(
      {this.name,
      this.statisticsReference,
      this.duration,
      this.equipment,
      this.intensity,
      this.categories,
      this.workoutDuration,
      this.recommendedEngagement,
      this.recommendedEngagementGap,
      this.engagementGapTime,
      this.engagementTime,
      this.mandatoryGapTime,
      this.classes,
      this.tags,
      this.imageUrl,
      this.video,
      this.description,
      String id,
      Timestamp createdAt,
      String createdBy,
      Timestamp updatedAt,
      String updatedBy,
      bool isHidden,
      bool isDeleted})
      : super(
            id: id,
            createdBy: createdBy,
            createdAt: createdAt,
            updatedAt: updatedAt,
            updatedBy: updatedBy,
            isDeleted: isDeleted,
            isHidden: isHidden);

  factory Course.fromJson(Map<String, dynamic> json) {
    Course course = Course(
        name: json['name'],
        statisticsReference: json['statistics_reference'],
        video: json['video'],
        duration: json['duration'],
        description: json['description'],
        equipment: json['equipment'],
        intensity: json['intensity'],
        categories: json['categories'],
        workoutDuration: json['workout_duration'],
        recommendedEngagement: json['recommended_engagement'],
        recommendedEngagementGap: json['recommended_engagementGap'],
        engagementGapTime: json['engagement_gap_time'],
        engagementTime: json['engagement_time'],
        mandatoryGapTime: json['mandatory_gap_time'],
        classes: json['classes'] != null
            ? List<ObjectSubmodel>.from(
                json['classes'].map((c) => ObjectSubmodel.fromJson(c)))
            : null,
        tags: json['tags'] != null
            ? List<ObjectSubmodel>.from(
                json['tags'].map((c) => ObjectSubmodel.fromJson(c)))
            : null,
        imageUrl: json['image_url']);
    course.setBase(json);
    return course;
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> courseJson = {
      'name': name,
      'statistics_reference': statisticsReference,
      'video': video,
      'duration': duration,
      'description': description,
      'equipment': equipment,
      'intensity': intensity,
      'categories': categories,
      'workout_duration': workoutDuration,
      'recommended_engagement': recommendedEngagement,
      'recommended_engagementGap': recommendedEngagementGap,
      'engagement_gap_time': engagementGapTime,
      'engagement_time': engagementTime,
      'mandatory_gap_time': mandatoryGapTime,
      'classes': classes == null
          ? null
          : List<dynamic>.from(classes.map((c) => c.toJson())),
      'image_url': imageUrl,
    };
    courseJson.addEntries(super.toJson().entries);
    return courseJson;
  }
}
