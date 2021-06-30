import 'package:cloud_firestore/cloud_firestore.dart';

class CourseCategoryItem {
  CourseCategoryItem({this.courseReference, this.index, this.courseId});

  DocumentReference courseReference;
  num index;
  String courseId;

  CourseCategoryItem.fromJson(Map json)
      : courseReference = json['course_reference'],
        index = json['index'],
        courseId = json['course_id'];

  Map<String, dynamic> toJson() => {
        'course_reference': courseReference,
        'index': index,
        'course_id': courseId,
      };
}
