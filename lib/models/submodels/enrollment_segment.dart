import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:oluko_app/models/submodels/enrollment_movement.dart';
import 'package:oluko_app/models/submodels/enrollment_section.dart';

class EnrollmentSegment {
  String id;
  DocumentReference reference;
  String name;
  Timestamp compleatedAt;
  bool is_challenge;
  String challengeImage;
  List<EnrollmentSection> sections;

  EnrollmentSegment({this.id, this.reference, this.name, this.compleatedAt, this.sections, this.challengeImage, this.is_challenge});

  factory EnrollmentSegment.fromJson(Map<String, dynamic> json) {
    return EnrollmentSegment(
        id: json['id']?.toString(),
        reference: json['reference'] as DocumentReference,
        name: json['name']?.toString(),
        is_challenge: json['is_challenge'] == null? false : json['is_challenge'] is bool? json['is_challenge'] as bool : false,
        challengeImage: json['challenge_image'] == null ? null : json['challenge_image']?.toString(),
        compleatedAt: json['compleated_at'] as Timestamp,
        sections: json['sections'] == null ? null : List<EnrollmentSection>.from((json['sections'] as Iterable).map((section) => EnrollmentSection.fromJson(section as Map<String, dynamic>))));
  }

  Map<String, dynamic> toJson() =>
      {'id': id, 'reference': reference, 'name': name, 'compleated_at': compleatedAt, 'is_challenge': is_challenge, 'challengeImage': challengeImage, 'sections': sections == null ? null : List<dynamic>.from(sections.map((section) => section.toJson()))};
}
