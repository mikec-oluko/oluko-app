import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:oluko_app/models/base.dart';
import 'package:oluko_app/models/submodels/object_submodel.dart';
import 'package:oluko_app/models/submodels/segment_submodel.dart';

class Class extends Base {
  String video;
  String image;
  String name;
  String description;
  List<SegmentSubmodel> segments;

  Class(
      {this.video,
      this.name,
      this.segments,
      this.description,
      this.image,
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

  factory Class.fromJson(Map<String, dynamic> json) {
    Class classObject = Class(
        video: json['video'],
        name: json['name'],
        image: json['image'],
        description: json['description'],
        segments: json['segments'] == null
            ? null
            : List<SegmentSubmodel>.from(json['segments']
                .map((segment) => SegmentSubmodel.fromJson(segment))));
    classObject.setBase(json);
    return classObject;
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> classJson = {
      'video': video,
      'name': name,
      'description': description,
      'image': image,
      'segments': segments == null
          ? null
          : List<dynamic>.from(segments.map((segment) => segment.toJson())),
    };
    classJson.addEntries(super.toJson().entries);
    return classJson;
  }
}
