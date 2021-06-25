import 'package:oluko_app/models/course_category_item.dart';

class CourseCategory {
  CourseCategory({this.name, this.id, this.courses});

  String name;
  String id;
  List<CourseCategoryItem> courses;

  CourseCategory.fromJson(Map json)
      : name = json['name'],
        id = json['id'],
        courses = json['courses'] != null && json['courses'].length > 0
            ? json['courses'].map<CourseCategoryItem>((item) {
                CourseCategoryItem courseCategoryItem =
                    CourseCategoryItem.fromJson(item);
                return courseCategoryItem;
              }).toList()
            : [];

  Map<String, dynamic> toJson() => {
        'name': name,
        'id': id,
        'courses': courses,
      };
}
