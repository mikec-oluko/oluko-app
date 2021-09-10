import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:oluko_app/models/base.dart';
import 'package:oluko_app/models/submodels/object_submodel.dart';

class Movement extends Base {
  String name;
  String description;
  String video;
  List<ObjectSubmodel> tags;
  String iconImage;

  Movement(
      {this.name,
      this.video,
      this.description,
      this.tags,
      this.iconImage,
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
        name: json['name'].toString(),
        video: json['video'].toString(),
        description: json['description'].toString(),
        iconImage: json['icon_image'].toString(),
        tags: json['tags'] == null
            ? null
            : (json['tags'] as Iterable)
                .map<ObjectSubmodel>((tag) => ObjectSubmodel.fromJson(tag as Map<String, dynamic>))
                .toList());
    movement.setBase(json);
    return movement;
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> movementJson = {
      'name': name,
      'video': video,
      'description': description,
      'icon_image': iconImage,
      'tags': tags == null ? null : List<dynamic>.from(tags),
    };
    movementJson.addEntries(super.toJson().entries);
    return movementJson;
  }
}
