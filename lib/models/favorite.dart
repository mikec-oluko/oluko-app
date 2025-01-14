import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:oluko_app/models/base.dart';
import 'package:oluko_app/models/submodels/object_submodel.dart';

class Favorite extends Base {
  String userId;
  ObjectSubmodel course;

  Favorite(
      {this.userId,
      this.course,
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

  factory Favorite.fromJson(Map<String, dynamic> json) {
    Favorite favorite = Favorite(
        userId: json['user_id']?.toString(),
        course: json['course'] == null ? null : ObjectSubmodel.fromJson(json['course'] as Map<String, dynamic>));
    favorite.setBase(json);
    return favorite;
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> favoriteJson = {
      'user_id': userId,
      'course': course == null ? null : course.toJson(),
    };
    favoriteJson.addEntries(super.toJson().entries);
    return favoriteJson;
  }
}
