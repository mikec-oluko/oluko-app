import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:oluko_app/models/base.dart';
import 'package:oluko_app/models/submodels/course_category_item.dart';

class CourseCategory extends Base {
  CourseCategory(
      {this.name,
      this.courses,
      this.index,
      String id,
      Timestamp createdAt,
      String createdBy,
      Timestamp updatedAt,
      String updatedBy,
      bool isHidden,
      bool isDeleted})
      : super(id: id, createdBy: createdBy, createdAt: createdAt, updatedAt: updatedAt, updatedBy: updatedBy, isDeleted: isDeleted, isHidden: isHidden);

  String name;
  List<CourseCategoryItem> courses;
  int index;

  factory CourseCategory.fromJson(Map<String, dynamic> json) {
    CourseCategory courseCategory = CourseCategory(
      name: json['name']?.toString(),
      index: json['index'] as int,
      courses: json['courses'] != null
          ? (json['courses'] as Iterable).map<CourseCategoryItem>((item) => CourseCategoryItem.fromJson(item as Map<String, dynamic>)).toList()
          : [],
    );
    courseCategory.setBase(json);
    return courseCategory;
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> assessmentJson = {
      'name': name,
      'index': index,
      'courses': courses,
    };
    assessmentJson.addEntries(super.toJson().entries);
    return assessmentJson;
  }
}
