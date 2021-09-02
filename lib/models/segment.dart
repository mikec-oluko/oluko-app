import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:enum_to_string/enum_to_string.dart';
import 'package:oluko_app/models/base.dart';
import 'package:oluko_app/models/enums/counter_enum.dart';
import 'package:oluko_app/models/enums/timer_type_enum.dart';
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
  bool isChallenge;
  bool isPublished;
  TimerTypeEnum timerType;

  Segment(
      {this.name,
      this.movements,
      this.image,
      this.rounds,
      this.description,
      this.duration,
      this.initialTimer,
      this.roundBreakDuration,
      this.isChallenge,
      this.isPublished,
      this.timerType,
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
        isChallenge: json['is_challenge'],
        isPublished: json['is_published'],
        timerType: json['timer_type'] == null
            ? null
            : TimerTypeEnum.values[json['timer_type']],
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
      'is_challenge': isChallenge,
      'is_published': isPublished,
      'timer_type': timerType == null ? null : timerType.index,
      'movements': movements == null
          ? null
          : List<dynamic>.from(movements.map((movement) => movement.toJson()))
    };
    movementJson.addEntries(super.toJson().entries);
    return movementJson;
  }
}
