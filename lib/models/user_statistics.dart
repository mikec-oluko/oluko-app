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
        completedChallenges: json['completed_challenges'],
        completedClasses: json['completed_classes'],
        completedCourses: json['completed_courses'],
        completedSegments: json['completed_segments']);
  }

  Map<String, dynamic> toJson() => {
        'completed_challenges': completedChallenges,
        'completed_classes': completedClasses,
        'completed_courses': completedCourses,
        'completed_segments': completedSegments,
      };
}
