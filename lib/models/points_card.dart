import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:oluko_app/models/base.dart';
import 'package:oluko_app/models/enums/completion_criteria_enum.dart';
import 'package:oluko_app/models/enums/content_type_enum.dart';

class PointsCard extends Base {
  String name; 
  String description;
  ContentTypeEnum contentType;
  CompletionCriteriaEnum completionCriteria;
  int completion;
  DocumentReference contentReference;
  String contentId;
  String image;
  int value;

  PointsCard(
      {this.name,
      this.description,
      this.contentType,
      this.completionCriteria,
      this.completion,
      this.contentReference,
      this.contentId,
      this.image,
      this.value,
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

  factory PointsCard.fromJson(Map<String, dynamic> json) {
    PointsCard pointsCardObject = PointsCard(
      name: json['name']?.toString(),
      description: json['description']?.toString(),
      contentType: json['content_type'] == null ? null : ContentTypeEnum.values[json['content_type'] as int],
      completionCriteria:json['completion_criteria'] == null ? null : CompletionCriteriaEnum.values[json['completion_criteria'] as int],
      completion: json['completion'] as int,
      contentReference: json['content_reference'] as DocumentReference,
      contentId: json['content_id']?.toString(),
      image: json['image']?.toString(),
      value: json['value'] as int
    );

    pointsCardObject.setBase(json);
    return pointsCardObject;
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> pointsCardJson = {
      'name': name,
      'description': description,
      'content_type': contentType == null ? null : contentType.index,
      'completion_criteria': completionCriteria == null ? null : completionCriteria.index,
      'completion': completion,
      'content_reference': contentReference,
      'content_id': contentId,
      'image': image,
      'value': value
    };
    pointsCardJson.addEntries(super.toJson().entries);
    return pointsCardJson;
  }
}
