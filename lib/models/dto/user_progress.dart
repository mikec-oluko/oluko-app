import 'package:cloud_firestore/cloud_firestore.dart';

class UserProgress {
  String id;
  double progress;
  Timestamp createdAt;

  UserProgress({this.id, this.progress, this.createdAt});

  factory UserProgress.fromJson(Map<String, dynamic> json) {
    UserProgress userProgress =
        UserProgress(id: json['id']?.toString(), progress: json['progress'] as double, createdAt: json['created_at'] as Timestamp);
    return userProgress;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> userProgressJson = {'id': id, 'progress': progress, 'created_at': createdAt.toString()};
    return userProgressJson;
  }
}
