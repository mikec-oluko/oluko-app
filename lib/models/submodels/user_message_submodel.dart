import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:oluko_app/models/message.dart';
import 'package:oluko_app/models/submodels/object_submodel.dart';

class UserMessageSubmodel {
  UserMessageSubmodel(
    { this.user,
      this.reference,
      this.id,
      this.name,});

  ObjectSubmodel user;
  DocumentReference reference;
  String id;
  String name;

    factory UserMessageSubmodel.fromJson(Map<String, dynamic> json) {
    return UserMessageSubmodel(
        user: json['user'] != null ? ObjectSubmodel.fromJson(json['user'] as Map<String, dynamic>) : null,
        reference: json['reference'] as DocumentReference,
        id: json['id']?.toString(),
        name: json['name']?.toString(),
        );
  }

  Map<String, dynamic> toJson() => {
        'reference': reference,
        'id': id,
        'name': name,
        'user': user.toJson()
      };
}
