import 'package:cloud_firestore/cloud_firestore.dart';

class TagCategoryItem {
  TagCategoryItem({this.reference, this.index, this.id});

  DocumentReference reference;
  num index;
  String id;

  TagCategoryItem.fromJson(Map json)
      : reference = json['reference'],
        index = json['index'],
        id = json['id'];

  Map<String, dynamic> toJson() => {
        'reference': reference,
        'index': index,
        'id': id,
      };
}
