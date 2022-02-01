import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:oluko_app/models/base.dart';
import 'package:oluko_app/models/submodels/segment_submodel.dart';

class Class extends Base {
  String video;
  String image;
  String name;
  String description;
  List<SegmentSubmodel> segments;
  List<String> randomImages;

  Class(
      {this.video,
      this.name,
      this.segments,
      this.description,
      this.image,
      this.randomImages,
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
      video: json['video']?.toString(),
      name: json['name']?.toString(),
      image: json['image']?.toString(),
      randomImages: json['random_images'] == null || json['random_images'].runtimeType == String
          ? null
          : json['random_images'] is String
              ? [json['random_images'] as String]
              : List<String>.from((json['random_images'] as Iterable).map((randomImage) => randomImage as String)),
      description: json['description']?.toString(),
      segments: json['segments'] == null
          ? null
          : List<SegmentSubmodel>.from(
              (json['segments'] as Iterable).map((segment) => SegmentSubmodel.fromJson(segment as Map<String, dynamic>))),
    );
    classObject.setBase(json);
    return classObject;
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> classJson = {
      'video': video,
      'name': name,
      'description': description,
      'image': image,
      'random_images': randomImages == null ? null : randomImages,
      'segments': segments == null ? null : List<SegmentSubmodel>.from(segments.map((segment) => segment.toJson()))
    };
    classJson.addEntries(super.toJson().entries);
    return classJson;
  }
}
