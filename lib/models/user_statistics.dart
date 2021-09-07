class UserStatistics {
  num completedChallenges;
  num completedClasses;
  num completedCourses;
  num completedSegments;

  UserStatistics({
    this.completedChallenges,
    this.completedClasses,
    this.completedCourses,
    this.completedSegments,
  });

  factory UserStatistics.fromJson(Map<String, dynamic> json) {
    return UserStatistics(
        completedChallenges: json['completed_challenges'] == null
            ? 0
            : json['completed_challenges'],
        completedClasses:
            json['completed_classes'] == null ? 0 : json['completed_classes'],
        completedCourses:
            json['completed_courses'] == null ? 0 : json['completed_courses'],
        completedSegments: json['completed_segments'] == null
            ? 0
            : json['completed_segments']);
  }

  Map<String, dynamic> toJson() => {
        'completed_challenges':
            completedChallenges == null ? 0 : completedChallenges,
        'completed_classes': completedClasses == null ? 0 : completedClasses,
        'completed_courses': completedCourses == null ? 0 : completedCourses,
        'completed_segments': completedSegments == null ? 0 : completedSegments,
      };
}
