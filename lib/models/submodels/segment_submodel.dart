import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:oluko_app/models/submodels/object_submodel.dart';
import 'package:oluko_app/models/submodels/section_submodel.dart';

class SegmentSubmodel {
  String id;
  DocumentReference reference;
  String name;
  bool isChallenge;
  String challengeImage;
  List<SectionSubmodel> sections;

  SegmentSubmodel({this.id, this.reference, this.challengeImage, this.name, this.sections, this.isChallenge});

  factory SegmentSubmodel.fromJson(Map<String, dynamic> json) {
    return SegmentSubmodel(
        id: json['id']?.toString(),
        reference: json['reference'] as DocumentReference,
        name: json['name']?.toString(),
        isChallenge: json['is_challenge'] == null
            ? false
            : json['is_challenge'] is bool
                ? json['is_challenge'] as bool
                : false,
        challengeImage: json['challenge_image'] == null ? null : json['challenge_image']?.toString(),
        sections: json['sections'] == null
            ? null
            : List<SectionSubmodel>.from((json['sections'] as Iterable)
                .map((section) => SectionSubmodel.fromJson(section as Map<String, dynamic>))));
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'reference': reference,
        'name': name,
        'is_challenge': isChallenge,
        'challenge_image': challengeImage,
        'sections': sections == null ? null : List<dynamic>.from(sections.map((section) => section.toJson())),
      };
}
