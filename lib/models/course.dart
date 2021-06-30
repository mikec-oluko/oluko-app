import 'package:cloud_firestore/cloud_firestore.dart';
import 'base.dart';

class Course extends Base {
  Course(
      {this.name,
      this.id,
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
      this.classe,
      this.imageUrl,
      Timestamp createdAt,
      String createdBy,
      Timestamp updatedAt,
      String updatedBy})
      : super(
            createdBy: createdBy,
            createdAt: createdAt,
            updatedAt: updatedAt,
            updatedBy: updatedBy);

  String name;
  String id;
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
  List<Map<String, dynamic>> classe;
  String imageUrl;
  Timestamp createdAt;
  String createdBy;
  Timestamp updatedAt;
  String updatedBy;

  Course.fromJson(Map json)
      : name = json['name'],
        id = json['id'],
        duration = json['duration'],
        description = json['description'],
        equipment = json['equipment'],
        intensity = json['intensity'],
        categories = json['categories'],
        workoutDuration = json['workout_duration'],
        recommendedEngagement = json['recommended_engagement'],
        recommendedEngagementGap = json['recommended_engagementGap'],
        engagementGapTime = json['engagement_gap_time'],
        engagementTime = json['engagement_time'],
        mandatoryGapTime = json['mandatory_gap_time'],
        classe = json['classe'],
        imageUrl = json['image_url'],
        createdAt = json['created_at'],
        createdBy = json['created_by'],
        updatedAt = json['updated_at'],
        updatedBy = json['updated_by'];

  Map<String, dynamic> toJson() => {
        'name': name,
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
        'classe': classe,
        'image_url': imageUrl,
        'created_at': createdAt == null ? createdAtSentinel : createdAt,
        'created_by': createdBy,
        'updated_at': updatedAt == null ? updatedAtSentinel : updatedAt,
        'updated_by': updatedBy,
      };
}
