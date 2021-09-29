import 'package:oluko_app/models/submodels/enrollment_movement.dart';

class EnrollmentSection {
  List<EnrollmentMovement> movements;

  EnrollmentSection({this.movements});

  factory EnrollmentSection.fromJson(Map<String, dynamic> json) {
    return EnrollmentSection(
      movements: json['movements'] == null
          ? null
          : List<EnrollmentMovement>.from((json['movements'] as Iterable).map(
              (movement) => EnrollmentMovement.fromJson(
                  movement as Map<String, dynamic>))),
    );
  }

  Map<String, dynamic> toJson() => {
        'movements': movements == null
            ? null
            : List<dynamic>.from(movements.map((movement) => movement.toJson()))
      };
}
