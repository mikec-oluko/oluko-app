import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:oluko_app/models/base.dart';
import 'package:oluko_app/models/enums/segment_type_enum.dart';
import 'package:oluko_app/models/submodels/section_submodel.dart';

class Segment extends Base {
  String video;
  String name;
  String image;
  String description;
  int initialTimer;
  SegmentTypeEnum type;
  int rounds;
  int totalTime;
  bool isPublished;
  List<SectionSubmodel> sections;
  bool isChallenge;

  Segment(
      {this.name,
      this.sections,
      this.image,
      this.rounds,
      this.description,
      this.initialTimer,
      this.isPublished,
      this.totalTime,
      this.isChallenge,
      this.video,
      this.type,
      String id,
      Timestamp createdAt,
      String createdBy,
      Timestamp updatedAt,
      String updatedBy,
      bool isHidden,
      bool isDeleted})
      : super(
            id: id,
            createdBy: createdBy,
            createdAt: createdAt,
            updatedAt: updatedAt,
            updatedBy: updatedBy,
            isDeleted: isDeleted,
            isHidden: isHidden);

  factory Segment.fromJson(Map<String, dynamic> json) {
    Segment segment = Segment(
        video: json['video']?.toString(),
        name: json['name']?.toString(),
        image: json['image']?.toString(),
        rounds: json['rounds'] as int,
        description: json['description']?.toString(),
        isChallenge: json['is_challenge'] as bool,
        totalTime: json['total_time'] as int,
        initialTimer: json['initial_timer'] as int,
        isPublished: json['is_published'] as bool,
        type: json['type'] == null
            ? null
            : SegmentTypeEnum.values[json['type'] as int],
        sections: json['sections'] == null
            ? null
            : List<SectionSubmodel>.from((json['sections'] as Iterable).map(
                (section) => SectionSubmodel.fromJson(
                    section as Map<String, dynamic>))));
    segment.setBase(json);
    return segment;
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> segmentJson = {
      'video': video,
      'name': name,
      'image': image,
      'rounds': rounds,
      'total_time': totalTime,
      'description': description,
      'initial_timer': initialTimer,
      'is_published': isPublished,
      'is_challenge': isChallenge,
      'type': type == null ? null : type.index,
      'movements': sections == null
          ? null
          : List<dynamic>.from(sections.map((section) => section.toJson()))
    };
    segmentJson.addEntries(super.toJson().entries);
    return segmentJson;
  }
}
