import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:oluko_app/models/base.dart';
import 'package:oluko_app/models/enrollment_segment.dart';

class EnrollmentClass extends Base {
  String classId;
  DocumentReference classReference;
  String className;
  Timestamp compleatedAt;
  List<EnrollmentSegment> enrollmentSegments;

  EnrollmentClass(
      {this.classId,
      this.classReference,
      this.className,
      this.compleatedAt,
      this.enrollmentSegments});

  factory EnrollmentClass.fromJson(Map<String, dynamic> json) {
    return EnrollmentClass(
        classId: json['class_id'],
        classReference: json['class_reference'],
        className: json['class_name'],
        compleatedAt: json['compleated_at'],
        enrollmentSegments: json['enrollment_segments'] == null
            ? null
            : List<EnrollmentSegment>.from(json['enrollment_segments'].map(
                (enrollmentSegment) =>
                    EnrollmentSegment.fromJson(enrollmentSegment))));
  }

  Map<String, dynamic> toJson() => {
        'class_id': classId,
        'class_reference': classReference,
        'class_name': className,
        'compleated_at': compleatedAt,
        'enrollment_segments': enrollmentSegments == null
            ? null
            : List<dynamic>.from(enrollmentSegments
                .map((enrollmentSegment) => enrollmentSegment.toJson())),
      };
}
