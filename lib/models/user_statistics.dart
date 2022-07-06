class UserStatistics {
  int completedChallenges;
  int completedClasses;
  int completedCourses;
  int completedSegments;
  int appCompleted;

  UserStatistics({this.completedChallenges, this.completedClasses, this.completedCourses, this.completedSegments, this.appCompleted});

  factory UserStatistics.fromJson(Map<String, dynamic> json) {
    return UserStatistics(
        completedChallenges: json['completed_challenges'] == null ? 0 : json['completed_challenges'] as int,
        completedClasses: json['completed_classes'] == null ? 0 : json['completed_classes'] as int,
        completedCourses: json['completed_courses'] == null ? 0 : json['completed_courses'] as int,
        completedSegments: json['completed_segments'] == null ? 0 : json['completed_segments'] as int,
        appCompleted: json['app_completed'] == null ? 0 : json['app_completed'] as int);
  }

  Map<String, dynamic> toJson() => {
        'completed_challenges': completedChallenges == null ? 0 : completedChallenges,
        'completed_classes': completedClasses == null ? 0 : completedClasses,
        'completed_courses': completedCourses == null ? 0 : completedCourses,
        'completed_segments': completedSegments == null ? 0 : completedSegments,
                'app_completed': appCompleted == null ? 0 : appCompleted,
      };
}
