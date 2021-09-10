import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:oluko_app/models/submodels/counter.dart';

class EnrollmentMovement {
  String id;
  DocumentReference reference;
  String name;
  Counter counter;

  EnrollmentMovement({this.id, this.reference, this.name, this.counter});

  factory EnrollmentMovement.fromJson(Map<String, dynamic> json) {
    return EnrollmentMovement(
        id: json['id'].toString(),
        reference: json['reference'] as DocumentReference,
        name: json['name'].toString(),
        counter: Counter.fromJson(json['counter'] as Map<String, dynamic>));
  }

  Map<String, dynamic> toJson() => {'id': id, 'reference': reference, 'name': name, 'counter': counter.toJson()};
}
