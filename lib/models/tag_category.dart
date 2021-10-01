import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:oluko_app/models/base.dart';
import 'package:oluko_app/models/tag.dart';
import 'package:oluko_app/models/submodels/tag_category_item.dart';

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
  List<TagCategoryItem> tags;

  factory TagCategory.fromJson(Map<String, dynamic> json) {
    TagCategory tagCategory = TagCategory(
      name: json['name']?.toString(),
      tags: json['tags'] != null
          ? (json['tags'] as Iterable).map<TagCategoryItem>((item) => TagCategoryItem.fromJson(item as Map<String, dynamic>)).toList()
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
