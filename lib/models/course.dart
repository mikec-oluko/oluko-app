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
      : name = json['name'],
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
        imageUrl = json['image_url'];

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
