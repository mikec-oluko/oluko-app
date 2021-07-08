import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mvt_fitness/models/base.dart';
import 'package:mvt_fitness/models/course_category_item.dart';

class CourseCategory extends Base {
  CourseCategory(
      {this.name,
      this.courses,
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
  List<CourseCategoryItem> courses;

  factory CourseCategory.fromJson(Map<String, dynamic> json) {
    CourseCategory courseCategory = CourseCategory(
      name: json['name'],
      courses: json['courses'] != null
          ? json['courses']
              .map<CourseCategoryItem>(
                  (item) => CourseCategoryItem.fromJson(item))
              .toList()
          : [],
    );
    courseCategory.setBase(json);
    return courseCategory;
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> assessmentJson = {
      'name': name,
      'courses': courses,
    };
    assessmentJson.addEntries(super.toJson().entries);
    return assessmentJson;
  }
}
