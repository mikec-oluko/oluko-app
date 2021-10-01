import 'package:cloud_firestore/cloud_firestore.dart';

class CourseCategoryItem {
  CourseCategoryItem({this.reference, this.id});

  DocumentReference reference;
  String id;

  CourseCategoryItem.fromJson(Map json)
      : reference = json['reference'] as DocumentReference,
        id = json['id']?.toString();

  Map<String, dynamic> toJson() => {
        'reference': reference,
        'id': id,
      };
}
