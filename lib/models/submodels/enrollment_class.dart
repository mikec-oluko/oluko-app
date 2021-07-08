import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:oluko_app/models/submodels/enrollment_segment.dart';

class EnrollmentClass{
  String classId;
  DocumentReference classReference;
  String className;
  Timestamp compleatedAt;
  List<EnrollmentSegment> segments;

  EnrollmentClass(
      {this.classId,
      this.classReference,
      this.className,
      this.compleatedAt,
      this.segments});

  factory EnrollmentClass.fromJson(Map<String, dynamic> json) {
    return EnrollmentClass(
        classId: json['class_id'],
        classReference: json['class_reference'],
        className: json['class_name'],
        compleatedAt: json['compleated_at'],
        segments: json['segments'] == null
            ? null
            : List<EnrollmentSegment>.from(json['segments'].map(
                (segment) =>
                    EnrollmentSegment.fromJson(segment))));
  }

  Map<String, dynamic> toJson() => {
        'class_id': classId,
        'class_reference': classReference,
        'class_name': className,
        'compleated_at': compleatedAt,
        'segments': segments == null
            ? null
            : List<dynamic>.from(segments
                .map((segment) => segment.toJson())),
      };
}
