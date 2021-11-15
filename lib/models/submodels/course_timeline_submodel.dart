import 'package:cloud_firestore/cloud_firestore.dart';

class CourseTimelineSubmodel {
  DocumentReference reference;
  String id;
  String name;

  CourseTimelineSubmodel({this.id = '0', this.name = 'all', this.reference});

  factory CourseTimelineSubmodel.fromJson(Map<String, dynamic> json) {
    return CourseTimelineSubmodel(
        reference: json['reference'] as DocumentReference, id: json['id'].toString(), name: json['name'].toString());
  }

  Map<String, dynamic> toJson() => {
        'reference': reference,
        'id': id,
        'name': name,
      };
}
