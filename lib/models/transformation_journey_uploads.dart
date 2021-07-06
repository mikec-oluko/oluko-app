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
  Timestamp createdAt;
  String createdBy;
  Timestamp updatedAt;
  String updatedBy;
  bool isHidden;

  TransformationJourneyUpload.fromJson(Map json)
      : name = json['name'],
        from = json['from'],
        description = json['description'],
        index = json['index'],
        type = json['type'],
        file = json['file'],
        isPublic = json['isPublic'],
        thumbnail = json['thumbnail'],
        createdAt = json['createdAt'],
        createdBy = json['createdBy'],
        updatedAt = json['updatedAt'],
        updatedBy = json['updatedBy'];

  Map<String, dynamic> toJson() => {
        'name': name,
        'from': from,
        'description': description,
        'index': index,
        'type': type,
        'file': file,
        'isPublic': isPublic,
        'thumbnail': thumbnail,
        'createdAt': createdAt,
        'createdBy': createdBy,
        'updatedAt': updatedAt,
        'updatedBy': updatedBy,
      };

  TransformationJourneyUpload(
      {this.name,
      this.from,
      this.description,
      this.index,
      this.type,
      this.file,
      this.isPublic,
      this.thumbnail,
      Timestamp createdAt,
      String createdBy,
      Timestamp updatedAt,
      bool isHidden,
      String updatedBy})
      : super(
            createdBy: createdBy,
            createdAt: createdAt,
            updatedAt: updatedAt,
            updatedBy: updatedBy,
            isHidden: isHidden);
}
