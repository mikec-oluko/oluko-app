import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:oluko_app/models/submodels/audio.dart';
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
  List<Audio> audios;

  EnrollmentClass(
      {this.id,
      this.reference,
      this.name,
      this.completedAt,
      this.segments,
      this.image,
      this.selfieDownloadUrl,
      this.selfieThumbnailUrl,
      this.audios});

  factory EnrollmentClass.fromJson(Map<String, dynamic> json) {
    return EnrollmentClass(
        id: json['id']?.toString(),
        reference: json['reference'] as DocumentReference,
        name: json['name']?.toString(),
        image: json['image']?.toString(),
        completedAt: json['compleated_at'] as Timestamp,
        selfieDownloadUrl: json['selfie_download_url']?.toString(),
        selfieThumbnailUrl: json['selfie_thumbnail_url']?.toString(),
        audios: json['audios'] == null
            ? null
            : List<Audio>.from((json['audios'] as Iterable).map((audio) => Audio.fromJson(audio as Map<String, dynamic>))),
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
        'compleated_at': completedAt,
        'audios': audios == null ? null : List<dynamic>.from(audios.map((audio) => audio.toJson())),
        'segments': segments == null ? null : List<dynamic>.from(segments.map((segment) => segment.toJson())),
      };
}
