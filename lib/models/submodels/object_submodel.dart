import 'package:cloud_firestore/cloud_firestore.dart';

class ObjectSubmodel{
  DocumentReference objectReference;
  String objectId;
  String objectName;

  ObjectSubmodel({this.objectId, this.objectName, this.objectReference});

  factory ObjectSubmodel.fromJson(Map<String, dynamic> json) {
    return ObjectSubmodel(
        objectReference: json['object_reference'],
        objectId: json['object_id'],
        objectName: json['object_name']);
  }

  Map<String, dynamic> toJson() => {
        'object_reference': objectReference,
        'object_id': objectId,
        'object_name': objectName,
      };
}
