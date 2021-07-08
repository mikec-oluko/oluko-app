import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mvt_fitness/models/base.dart';

class Movement extends Base {
  String name;
  String description;
  String video;
  List<String> tags;

  Movement(
      {this.name,
      this.video,
      this.description,
      this.tags,
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

  factory Movement.fromJson(Map<String, dynamic> json) {
    Movement movement = Movement(
        name: json['name'],
        video: json['video'],
        description: json['description'],
        tags: json['tags'] == null ? null : List<String>.from(json['tags']));
    movement.setBase(json);
    return movement;
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> movementJson = {
      'name': name,
      'video': video,
      'description': description,
      'tags': tags == null ? null : List<dynamic>.from(tags),
    };
    movementJson.addEntries(super.toJson().entries);
    return movementJson;
  }
}
