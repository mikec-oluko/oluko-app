import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:oluko_app/models/submodels/enrollment_section.dart';

class EnrollmentSegment {
  String id;
  DocumentReference reference;
  String name;
  bool isChallenge;
  String challengeImage;
  Timestamp completedAt;
  List<EnrollmentSection> sections;
  int likes;
  int dislikes;

  EnrollmentSegment(
      {this.id,
      this.reference,
      this.name,
      this.completedAt,
      this.sections,
      this.challengeImage,
      this.isChallenge,
      this.likes,
      this.dislikes});

  factory EnrollmentSegment.fromJson(Map<String, dynamic> json) {
    return EnrollmentSegment(
      id: json['id']?.toString(),
      reference: json['reference'] as DocumentReference,
      name: json['name']?.toString(),
      isChallenge: json['is_challenge'] == null
          ? false
          : json['is_challenge'] is bool
              ? json['is_challenge'] as bool
              : false,
      challengeImage: json['challenge_image'] == null ? null : json['challenge_image']?.toString(),
      completedAt: json['completed_at'] as Timestamp,
      sections: json['sections'] == null
          ? null
          : List<EnrollmentSection>.from(
              (json['sections'] as Iterable).map((section) => EnrollmentSection.fromJson(section as Map<String, dynamic>))),
      likes: json['likes'] != null ? json['likes'] as int : 0,
      dislikes: json['dislikes'] != null ? json['dislikes'] as int : 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'reference': reference,
        'name': name,
        'completed_at': completedAt,
        'is_challenge': isChallenge,
        'challenge_image': challengeImage,
        'sections': sections == null ? null : List<dynamic>.from(sections.map((section) => section.toJson())),
        'likes': likes ?? 0,
        'dislikes': dislikes ?? 0,
      };
}
