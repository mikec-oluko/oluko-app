import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:oluko_app/models/base.dart';
import 'package:oluko_app/models/tag.dart';

class TagCategory extends Base {
  TagCategory(
      {this.name,
      this.tags,
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
  List<Tag> tags;

  factory TagCategory.fromJson(Map<String, dynamic> json) {
    TagCategory tagCategory = TagCategory(
      name: json['name'],
      tags: json['tags'] != null
          ? json['tags'].map<Tag>((item) => Tag.fromJson(item)).toList()
          : [],
    );
    tagCategory.setBase(json);
    return tagCategory;
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> tagJson = {
      'name': name,
      'tags': tags,
    };
    tagJson.addEntries(super.toJson().entries);
    return tagJson;
  }
}
