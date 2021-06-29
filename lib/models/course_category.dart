import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:oluko_app/models/base.dart';
import 'package:oluko_app/models/course_category_item.dart';

class CourseCategory extends Base {
  CourseCategory(
      {this.name,
      this.id,
      this.courses,
      Timestamp createdAt,
      String createdBy,
      Timestamp updatedAt,
      String updatedBy})
      : super(
            createdBy: createdBy,
            createdAt: createdAt,
            updatedAt: updatedAt,
            updatedBy: updatedBy);

  String name;
  String id;
  List<CourseCategoryItem> courses;
  Timestamp createdAt;
  String createdBy;
  Timestamp updatedAt;
  String updatedBy;

  CourseCategory.fromJson(Map json)
      : name = json['name'],
        id = json['id'],
        courses = json['courses'] != null
            ? json['courses']
                .map<CourseCategoryItem>(
                    (item) => CourseCategoryItem.fromJson(item))
                .toList()
            : [],
        createdAt = json['created_at'],
        createdBy = json['created_by'],
        updatedAt = json['updated_at'],
        updatedBy = json['updated_by'];

  Map<String, dynamic> toJson() => {
        'name': name,
        'id': id,
        'courses': courses,
        'created_at': createdAt == null ? createdAtSentinel : createdAt,
        'created_by': createdBy,
        'updated_at': updatedAt == null ? updatedAtSentinel : updatedAt,
        'updated_by': updatedBy,
      };
}
