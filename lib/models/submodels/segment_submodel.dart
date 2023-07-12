import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:oluko_app/models/enums/segment_type_enum.dart';
import 'package:oluko_app/models/submodels/section_submodel.dart';

class SegmentSubmodel {
  String id;
  DocumentReference reference;
  String name;
  bool isChallenge;
  String image;
  List<SectionSubmodel> sections;
  SegmentTypeEnum type;
  int rounds;
  int totalTime;

  SegmentSubmodel({this.id, this.reference, this.image, this.name, this.sections, this.isChallenge, this.rounds, this.totalTime, this.type});
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
      image: json['image'] == null ? null : json['image']?.toString(),
      sections: json['sections'] == null
          ? null
          : List<SectionSubmodel>.from((json['sections'] as Iterable).map((section) => SectionSubmodel.fromJson(section as Map<String, dynamic>))),
      rounds: json['rounds'] as int,
      totalTime: json['total_time'] is int ? json['total_time'] as int : int.tryParse(json['total_time'].toString()),
      type: json['type'] == null ? null : SegmentTypeEnum.values[json['type'] as int],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'reference': reference,
        'name': name,
        'is_challenge': isChallenge,
        'image': image,
        'sections': sections == null ? null : List<dynamic>.from(sections.map((section) => section.toJson())),
      };
}
