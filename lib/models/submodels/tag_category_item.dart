import 'package:cloud_firestore/cloud_firestore.dart';

class TagCategoryItem {
  TagCategoryItem({this.reference, this.index, this.id});

  DocumentReference reference;
  num index;
  String id;

  TagCategoryItem.fromJson(Map json)
      : reference = json['reference'] as DocumentReference,
        index = json['index'] as int,
        id = json['id'].toString();

  Map<String, dynamic> toJson() => {
        'reference': reference,
        'index': index,
        'id': id,
      };
}
