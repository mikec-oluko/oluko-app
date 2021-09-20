import 'movement_submodel.dart';

class SectionSubmodel {
  List<MovementSubmodel> movements;
  int totalTime;

  SectionSubmodel({this.movements, this.totalTime});

  factory SectionSubmodel.fromJson(Map<String, dynamic> json) {
    return SectionSubmodel(
      movements: json['movements'] == null
          ? null
          : List<MovementSubmodel>.from((json['movements'] as Iterable).map(
              (movement) =>
                  MovementSubmodel.fromJson(movement as Map<String, dynamic>))),
      totalTime: json['total_time'] == null ? null : json['total_time'] as int,
    );
  }

  Map<String, dynamic> toJson() => {
        'total_time': totalTime,
        'movements': movements == null
            ? null
            : List<dynamic>.from(movements.map((movement) => movement.toJson()))
      };
}
