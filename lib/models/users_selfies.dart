import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:oluko_app/models/base.dart';

class UsersSelfies extends Base {
  int indexToReplace;
  List<String> selfies;

  UsersSelfies(
      {this.indexToReplace,
      this.selfies,
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

  factory UsersSelfies.fromJson(Map<String, dynamic> json) {
    UsersSelfies usersSelfies = UsersSelfies(
      indexToReplace: json['index_to_replace'] as int,
      selfies: json['selfies'] == null || json['selfies'].runtimeType == String
          ? null
          : json['selfies'] is String
              ? [json['selfies'] as String]
              : List<String>.from((json['selfies'] as Iterable).map((selfie) => selfie as String)),
    );
    usersSelfies.setBase(json);
    return usersSelfies;
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> usersSelfies = {
      'index_to_replace': indexToReplace,
      'selfies': selfies == null ? null : selfies,
    };
    usersSelfies.addEntries(super.toJson().entries);
    return usersSelfies;
  }
}
