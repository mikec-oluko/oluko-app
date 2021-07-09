import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:oluko_app/models/submodels/enrollment_segment.dart';

class EnrollmentClass{
  String id;
  DocumentReference reference;
  String name;
  Timestamp compleatedAt;
  List<EnrollmentSegment> segments;

  EnrollmentClass(
      {this.id,
      this.reference,
      this.name,
      this.compleatedAt,
      this.segments});

  factory EnrollmentClass.fromJson(Map<String, dynamic> json) {
    return EnrollmentClass(
        id: json['id'],
        reference: json['reference'],
        name: json['name'],
        compleatedAt: json['compleated_at'],
        segments: json['segments'] == null
            ? null
            : List<EnrollmentSegment>.from(json['segments'].map(
                (segment) =>
                    EnrollmentSegment.fromJson(segment))));
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'reference': reference,
        'name': name,
        'compleated_at': compleatedAt,
        'segments': segments == null
            ? null
            : List<dynamic>.from(segments
                .map((segment) => segment.toJson())),
      };
}
