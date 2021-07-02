import 'package:cloud_firestore/cloud_firestore.dart';

class Base {
  Base(
      {this.id,
      this.createdAt,
      this.createdBy,
      this.updatedAt,
      this.updatedBy,
      this.isDeleted,
      this.isHidden}) {
    if (this.createdAt == null) {
      this.createdAtSentinel = FieldValue.serverTimestamp();
    }
    if (this.updatedAt == null) {
      this.updatedAtSentinel = FieldValue.serverTimestamp();
    }
  }

  String id;
  FieldValue createdAtSentinel;
  Timestamp createdAt;
  String createdBy;
  FieldValue updatedAtSentinel;
  Timestamp updatedAt;
  String updatedBy;
  bool isDeleted = false;
  bool isHidden = false;

  Base.fromJson(Map json)
      : id = json['id'],
        createdAt = json['created_at'],
        createdBy = json['created_by'],
        updatedAt = json['updated_at'],
        updatedBy = json['updated_by'],
        isDeleted = json['is_deleted'],
        isHidden = json['is_hidden'];

  setBase(Map<String, dynamic> json) {
    id = json['id'];
    createdAt = json['created_at'];
    createdBy = json['created_by'];
    updatedAt = json['updated_at'];
    updatedBy = json['updated_by'];
    isDeleted = json['is_deleted'];
    isHidden = json['is_hidden'];
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> baseJson;
    if (this.createdAt != null && this.updatedAt != null) {
      baseJson = {
        'created_at': createdAt,
        'updated_at': updatedAt,
      };
    } else {
      baseJson = {
        'created_at': createdAtSentinel,
        'updated_at': updatedAtSentinel,
      };
    }
    baseJson.addEntries([
      MapEntry("updated_by", updatedBy),
      MapEntry("created_by", createdBy),
      MapEntry("id", id),
      MapEntry("is_deleted", isDeleted),
      MapEntry("is_hidden", isHidden)
    ]);
    return baseJson;
  }
}