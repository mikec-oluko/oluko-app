import 'package:cloud_firestore/cloud_firestore.dart';

class ObjectSubmodel {
  DocumentReference reference;
  String id;
  String name;
  String image;

  ObjectSubmodel({this.id, this.name, this.reference, this.image});

  factory ObjectSubmodel.fromJson(Map<String, dynamic> json) {
    return ObjectSubmodel(
        reference: json['reference'] as DocumentReference,
        id: json['id']?.toString(),
        name: json['name']?.toString(),
        image: json['image']?.toString());
  }

  Map<String, dynamic> toJson() => {
        'reference': reference,
        'id': id,
        'name': name,
        'image': image,
      };
}
