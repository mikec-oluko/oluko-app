import 'package:cloud_firestore/cloud_firestore.dart';

class Base {
  Base({this.id, this.createdAt, this.createdBy, this.updatedAt, this.updatedBy, this.isDeleted, this.isHidden}) {
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
      : id = json['id'].toString(),
        createdAt = json['created_at'] as Timestamp,
        createdBy = json['created_by'].toString(),
        updatedAt = json['updated_at'] as Timestamp,
        updatedBy = json['updated_by'].toString(),
        isDeleted = json['is_deleted'] as bool,
        isHidden = json['is_hidden'] as bool;

  setBase(Map<String, dynamic> json) {
    id = json['id'].toString();
    createdAt = json['created_at'] is FieldValue
        ? null
        : json['created_at'] is Timestamp
            ? json['created_at'] as Timestamp
            : json['created_at'] is Map
                ? Timestamp(json['created_at']['_seconds'] as int, json['created_at']['_nanoseconds'] as int)
                : json['created_at'] is int
                    ? Timestamp.fromMillisecondsSinceEpoch(json['created_at'] as int)
                    : null;
    createdBy = json['created_by'].toString();
    updatedAt = json['updated_at'] is FieldValue
        ? null
        : json['updated_at'] is Timestamp
            ? json['updated_at'] as Timestamp
            : json['updated_at'] is Map
                ? Timestamp(json['updated_at']['_seconds'] as int, json['updated_at']['_nanoseconds'] as int)
                : json['updated_at'] is int
                    ? Timestamp.fromMillisecondsSinceEpoch(json['updated_at'] as int)
                    : null;
    updatedBy = json['updated_by'].toString();
    isDeleted = json['is_deleted'] as bool;
    isHidden = json['is_hidden'] as bool;
  }

  cleanBase() {
    this.createdAtSentinel = null;
    this.updatedAtSentinel = null;
    this.createdAt = null;
    this.updatedAt = null;
    return this;
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
      MapEntry('created_by', createdBy),
      MapEntry("id", id),
      MapEntry("is_deleted", isDeleted),
      MapEntry("is_hidden", isHidden)
    ]);
    return baseJson;
  }
}
