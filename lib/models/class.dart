import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:oluko_app/models/base.dart';
import 'package:oluko_app/models/submodels/segment_submodel.dart';

class Class extends Base {
  String video;
  String image;
  String name;
  String description;
  List<SegmentSubmodel> segments;
  List<String> userSelfies;

  Class(
      {this.video,
      this.name,
      this.segments,
      this.description,
      this.image,
      this.userSelfies,
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
      userSelfies: json['user_selfies'] == null || json['user_selfies'].runtimeType == String
          ? null
          : json['user_selfies'] is String
              ? [json['user_selfies'] as String]
              : List<String>.from((json['user_selfies'] as Iterable).map((userSelfie) => userSelfie as String)),
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
      'user_selfies': userSelfies == null ? null : userSelfies,
      'segments': segments == null ? null : List<SegmentSubmodel>.from(segments.map((segment) => segment.toJson()))
    };
    classJson.addEntries(super.toJson().entries);
    return classJson;
  }
}
