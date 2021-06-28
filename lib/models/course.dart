import 'package:cloud_firestore/cloud_firestore.dart';

class Course {
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
      this.imageUrl});

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

  Course.fromJson(Map json)
      : name = json['name'] ?? null,
        id = json['id'] ?? null,
        duration = json['duration'] ?? null,
        description = json['description'] ?? null,
        equipment = json['equipment'] ?? null,
        intensity = json['intensity'] ?? null,
        categories = json['categories'] ?? null,
        workoutDuration = json['workout_duration'] ?? null,
        recommendedEngagement = json['recommended_engagement'] ?? null,
        recommendedEngagementGap = json['recommended_engagementGap'] ?? null,
        engagementGapTime = json['engagement_gap_time'] ?? null,
        engagementTime = json['engagement_time'] ?? null,
        mandatoryGapTime = json['mandatory_gap_time'] ?? null,
        classe = json['classe'] ?? null,
        imageUrl = json['image_url' ?? null];

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
      };
}
