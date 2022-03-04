import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:oluko_app/models/submodels/enrollment_segment.dart';

class EnrollmentClass {
  String id;
  DocumentReference reference;
  String name;
  String image;
  Timestamp completedAt;
  List<EnrollmentSegment> segments;
  String selfieDownloadUrl;
  String selfieThumbnailUrl;
  String miniSelfieThumbnailUrl;

  EnrollmentClass({
    this.id,
    this.reference,
    this.name,
    this.completedAt,
    this.segments,
    this.image,
    this.selfieDownloadUrl,
    this.selfieThumbnailUrl,
    this.miniSelfieThumbnailUrl,
  });

  factory EnrollmentClass.fromJson(Map<String, dynamic> json) {
    return EnrollmentClass(
        id: json['id']?.toString(),
        reference: json['reference'] as DocumentReference,
        name: json['name']?.toString(),
        image: json['image']?.toString(),
        completedAt: json['completed_at'] as Timestamp,
        selfieDownloadUrl: json['selfie_download_url']?.toString(),
        selfieThumbnailUrl: json['selfie_thumbnail_url']?.toString(),
        miniSelfieThumbnailUrl: json['mini_selfie_thumbnail_url']?.toString(),
        segments: json['segments'] == null
            ? null
            : List<EnrollmentSegment>.from(
                (json['segments'] as Iterable).map((segment) => EnrollmentSegment.fromJson(segment as Map<String, dynamic>))));
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'reference': reference,
        'name': name,
        'image': image,
        'selfie_download_url': selfieDownloadUrl,
        'selfie_thumbnail_url': selfieThumbnailUrl,
        'mini_selfie_thumbnail_url': miniSelfieThumbnailUrl,
        'completed_at': completedAt,
        'segments': segments == null ? null : List<dynamic>.from(segments.map((segment) => segment.toJson())),
      };
}
