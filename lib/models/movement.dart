import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:oluko_app/models/base.dart';
import 'package:oluko_app/models/submodels/object_submodel.dart';

class Movement extends Base {
  String name;
  String description;
  String video;
  String videoHls;
  List<ObjectSubmodel> tags;
  int index;
  String image;
  List<dynamic> images;
  bool weightRequired;

  Movement(
      {this.name,
      this.video,
      this.videoHls,
      this.description,
      this.tags,
      this.index,
      this.image,
      this.images,
      this.weightRequired,
      String id,
      Timestamp createdAt,
      String createdBy,
      Timestamp updatedAt,
      String updatedBy,
      bool isHidden,
      bool isDeleted})
      : super(id: id, createdBy: createdBy, createdAt: createdAt, updatedAt: updatedAt, updatedBy: updatedBy, isDeleted: isDeleted, isHidden: isHidden);

  factory Movement.fromJson(Map<String, dynamic> json) {
    Movement movement = Movement(
        name: json['name']?.toString(),
        video: json['video']?.toString(),
        videoHls: json['video_hls']?.toString(),
        description: json['description']?.toString(),
        index: json['index'] as int,
        image: json['image'] == null ? null : json['image']?.toString(),
        images: json['images'] as List<dynamic>,
        weightRequired: json['weight_required'] == null ? false : json['weight_required'] as bool,
        tags: json['tags'] == null
            ? null
            : (json['tags'] as Iterable).map<ObjectSubmodel>((tag) => ObjectSubmodel.fromJson(tag as Map<String, dynamic>)).toList());
    movement.setBase(json);
    return movement;
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> movementJson = {
      'name': name,
      'video': video,
      'video_hls': videoHls,
      'description': description,
      'index': index,
      'image': image,
      'images': images,
      'weight_required': weightRequired,
      'tags': tags == null ? null : List<dynamic>.from(tags),
    };
    movementJson.addEntries(super.toJson().entries);
    return movementJson;
  }
}
