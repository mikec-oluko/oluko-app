import 'movement_submodel.dart';

class SectionSubmodel {
  List<MovementSubmodel> movements;
  int estimatedTime;
  bool stopwatch;

  SectionSubmodel({this.movements, this.estimatedTime, this.stopwatch});

  factory SectionSubmodel.fromJson(Map<String, dynamic> json) {
    return SectionSubmodel(
      movements: json['movements'] == null
          ? null
          : List<MovementSubmodel>.from((json['movements'] as Iterable).map(
              (movement) =>
                  MovementSubmodel.fromJson(movement as Map<String, dynamic>))),
      estimatedTime:
          json['estimated_time'] == null ? null : json['estimated_time'] as int,
      stopwatch: json['stopwatch'] == null ? false : json['stopwatch'] as bool,
    );
  }

  Map<String, dynamic> toJson() => {
        'estimated_time': estimatedTime,
        'stopwatch': stopwatch,
        'movements': movements == null
            ? null
            : List<dynamic>.from(movements.map((movement) => movement.toJson()))
      };
}
