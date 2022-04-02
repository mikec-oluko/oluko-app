class NotificationSettings {
  NotificationSettings({this.userId, this.segmentClocksSounds, this.globalNotifications});

  String userId;
  bool segmentClocksSounds;
  bool globalNotifications;

  factory NotificationSettings.fromJson(Map<String, dynamic> json) {
    final NotificationSettings chatJson = NotificationSettings(
      userId: json['user_id'] != null ? json['user_id'] as String : null,
      segmentClocksSounds: json['segment_clocks_sounds'] != null ? json['segment_clocks_sounds'] as bool : false,
      globalNotifications: json['global_notifications'] != null ? json['global_notifications'] as bool : false,
    );
    return chatJson;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> notiSettingsJson = {
      'user_id': userId,
      'segment_clocks_sounds': segmentClocksSounds,
      'global_notifications': globalNotifications
    };
    return notiSettingsJson;
  }
}
