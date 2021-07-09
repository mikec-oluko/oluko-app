import 'package:cloud_firestore/cloud_firestore.dart';
class EnrollmentSegment{
  String id;
  DocumentReference reference;
  String name;
  Timestamp compleatedAt;

  EnrollmentSegment(
      {this.id,
      this.reference,
      this.name,
      this.compleatedAt});

  factory EnrollmentSegment.fromJson(Map<String, dynamic> json) {
    return EnrollmentSegment(
        id: json['id'],
        reference: json['reference'],
        name: json['name'],
        compleatedAt: json['compleated_at']);
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'reference': reference,
        'name': name,
        'compleated_at': compleatedAt
      };
}
