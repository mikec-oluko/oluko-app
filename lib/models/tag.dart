import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mvt_fitness/models/base.dart';

class Tag extends Base {
  Tag(
      {this.name,
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

  String name;

  factory Tag.fromJson(Map<String, dynamic> json) {
    Tag courseCategory = Tag(
      name: json['name'],
    );
    courseCategory.setBase(json);
    return courseCategory;
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> tagJson = {
      'name': name,
    };
    tagJson.addEntries(super.toJson().entries);
    return tagJson;
  }
}
