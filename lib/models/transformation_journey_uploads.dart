import 'package:cloud_firestore/cloud_firestore.dart';
import 'base.dart';

import 'enums/file_type_enum.dart';

class TransformationJourneyUpload extends Base {
  String name;
  Timestamp from;
  String description;
  int index;
  FileTypeEnum type;
  String file;
  bool isPublic;
  String thumbnail;

  factory TransformationJourneyUpload.fromJson(Map<String, dynamic> json) {
    TransformationJourneyUpload transformationJourneyUpload = TransformationJourneyUpload(
        name: json['name']?.toString(),
        from: json['from'] as Timestamp,
        description: json['description']?.toString(),
        index: json['index'] as int,
        type: getFileTypeEnumFromString(json['type']?.toString()),
        file: json['file']?.toString(),
        isPublic: json['isPublic'] as bool,
        thumbnail: json['thumbnail']?.toString(),
        createdAt: json['createdAt'] as Timestamp,
        createdBy: json['createdBy']?.toString(),
        updatedAt: json['updatedAt'] as Timestamp,
        updatedBy: json['updatedBy']?.toString());

    transformationJourneyUpload.setBase(json);
    return transformationJourneyUpload;
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> transformationJourneyUploadJson = {
      'name': name,
      'from': from,
      'description': description,
      'index': index,
      'type': type?.toString(),
      'file': file,
      'isPublic': isPublic,
      'thumbnail': thumbnail,
      'createdAt': createdAt,
      'createdBy': createdBy,
      'updatedAt': updatedAt,
      'updatedBy': updatedBy,
    };
    transformationJourneyUploadJson.addEntries(super.toJson().entries);
    return transformationJourneyUploadJson;
  }

  TransformationJourneyUpload(
      {this.name,
      this.from,
      this.description,
      this.index,
      this.type,
      this.file,
      this.isPublic,
      this.thumbnail,
      String id,
      Timestamp createdAt,
      String createdBy,
      Timestamp updatedAt,
      String updatedBy,
      bool isHidden,
      bool isDeleted})
      : super(
            id: id,
            createdBy: createdBy,
            createdAt: createdAt,
            updatedAt: updatedAt,
            updatedBy: updatedBy,
            isDeleted: isDeleted,
            isHidden: isHidden);
}
