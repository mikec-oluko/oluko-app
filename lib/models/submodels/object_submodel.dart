import 'package:cloud_firestore/cloud_firestore.dart';

class ObjectSubmodel {
  DocumentReference reference;
  String id;
  String name;
  String image;

  ObjectSubmodel({this.id, this.name, this.reference, this.image});

  factory ObjectSubmodel.fromJson(Map<String, dynamic> json) {
    return ObjectSubmodel(
        reference: json['reference'],
        id: json['id'],
        name: json['name'],
        image: json['image']);
  }

  Map<String, dynamic> toJson() => {
        'reference': reference,
        'id': id,
        'name': name,
        'image': image,
      };
}
