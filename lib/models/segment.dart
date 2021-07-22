import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:oluko_app/models/base.dart';
import 'package:oluko_app/models/submodels/movement_submodel.dart';

class Segment extends Base {
  String name;
  List<MovementSubmodel> movements;
  String image;
  String description;
  int duration;
  int initialTimer;
  int rounds;
  int roundBreakDuration;
  bool isChallange;
  bool isPublished;

  Segment(
      {this.name,
      this.movements,
      this.image,
      this.rounds,
      this.description,
      this.duration,
      this.initialTimer,
      this.roundBreakDuration,
      this.isChallange,
      this.isPublished,
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

  factory Segment.fromJson(Map<String, dynamic> json) {
    Segment segment = Segment(
        name: json['name'],
        image: json['image'],
        rounds: json['rounds'],
        description: json['description'],
        duration: json['duration'],
        initialTimer: json['initial_timer'],
        roundBreakDuration: json['round_break_duration'],
        isChallange: json['is_challange'],
        isPublished: json['is_published'],
        movements: json['movements'] == null
            ? null
            : List<MovementSubmodel>.from(json['movements']
                .map((movement) => MovementSubmodel.fromJson(movement))));
    segment.setBase(json);
    return segment;
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> movementJson = {
      'name': name,
      'image': image,
      'rounds': rounds,
      'duration': duration,
      'description': description,
      'initial_timer': initialTimer,
      'round_break_duration': roundBreakDuration,
      'is_challange': isChallange,
      'is_published': isPublished,
      'movements': movements == null
          ? null
          : List<dynamic>.from(movements.map((movement) => movement.toJson()))
    };
    movementJson.addEntries(super.toJson().entries);
    return movementJson;
  }
}
