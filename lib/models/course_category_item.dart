import 'package:cloud_firestore/cloud_firestore.dart';

class CourseCategoryItem {
  CourseCategoryItem({this.reference, this.id});

  DocumentReference reference;
  String id;

  CourseCategoryItem.fromJson(Map json)
      : reference = json['reference'],
        id = json['id'];

  Map<String, dynamic> toJson() => {
        'reference': reference,
        'id': id,
      };
}
