import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:oluko_app/models/submodels/object_submodel.dart';

class SegmentSubmodel {
  String id;
  DocumentReference reference;
  String name;
  String challengeImage;
  List<ObjectSubmodel> movements;

  SegmentSubmodel({this.id, this.reference, this.challengeImage, this.name, this.movements});

  factory SegmentSubmodel.fromJson(Map<String, dynamic> json) {
    return SegmentSubmodel(
        id: json['id'].toString(),
        reference: json['reference'] as DocumentReference,
        name: json['name'].toString(),
        challengeImage: json['challenge_image'] == null
            ? null
            : json['challenge_image'].toString(),
        movements: json['movements'] == null
            ? null
            : List<ObjectSubmodel>.from((json['movements'] as Iterable)
                .map((movement) => ObjectSubmodel.fromJson(movement as Map<String, dynamic>))));
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'reference': reference,
        'name': name,
        'challenge_image': challengeImage,
        'movements': movements == null ? null : List<dynamic>.from(movements.map((movement) => movement.toJson())),
      };
}
