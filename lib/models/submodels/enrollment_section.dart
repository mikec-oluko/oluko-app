import 'package:oluko_app/models/submodels/enrollment_movement.dart';

class EnrollmentSection {
  List<EnrollmentMovement> movements;
  List<int> stopwatchs;

  EnrollmentSection({this.movements, this.stopwatchs});

  factory EnrollmentSection.fromJson(Map<String, dynamic> json) {
    return EnrollmentSection(
        movements: json['movements'] == null
            ? null
            : List<EnrollmentMovement>.from(
                (json['movements'] as Iterable).map((movement) => EnrollmentMovement.fromJson(movement as Map<String, dynamic>))),
        stopwatchs: json['stopwatchs'] == null || json['stopwatchs'].runtimeType == int
            ? null
            : json['stopwatchs'] is int
                ? [json['stopwatchs'] as int]
                : List<int>.from(
                    (json['stopwatchs'] as Iterable).map((stopwatch) => stopwatch as int),
                  ));
  }

  Map<String, dynamic> toJson() => {
        'movements': movements == null ? null : List<dynamic>.from(movements.map((movement) => movement.toJson())),
        'stopwatchs': stopwatchs == null ? null : stopwatchs
      };
}
