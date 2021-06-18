import 'package:cloud_firestore/cloud_firestore.dart';

class Base {
  Base({this.createdAt, this.createdBy, this.updatedAt, this.updatedBy}) {
    if (this.createdAt == null) {
      this.createdAtSentinel = FieldValue.serverTimestamp();
    }
    if (this.updatedAt == null) {
      this.updatedAtSentinel = FieldValue.serverTimestamp();
    }
  }

  FieldValue createdAtSentinel;
  Timestamp createdAt;
  String createdBy;
  FieldValue updatedAtSentinel;
  Timestamp updatedAt;
  String updatedBy;

  Base.fromJson(Map json)
      : createdAt = json['created_at'],
        createdBy = json['created_by'],
        updatedAt = json['updated_at'],
        updatedBy = json['updated_by'];

  Map<String, dynamic> toJson() {
    if (this.createdAt != null && this.updatedAt != null) {
      return {
        'created_at': createdAt,
        'created_by': createdBy,
        'updated_at': updatedAt,
        'updated_by': updatedBy
      };
    } else {
      return {
        'created_at': createdAtSentinel,
        'created_by': createdBy,
        'updated_at': updatedAtSentinel,
        'updated_by': updatedBy
      };
    }
  }
}
