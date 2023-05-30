import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/models/submodels/enrollment_movement.dart';
import 'package:oluko_app/models/submodels/enrollment_section.dart';
import 'package:oluko_app/models/submodels/movement_submodel.dart';
import 'package:oluko_app/models/submodels/section_submodel.dart';
import 'oluko_localizations.dart';

class MovementUtils {
  static Text movementTitle(String title) {
    return Text(
      title,
      textAlign: TextAlign.center,
      style: OlukoFonts.olukoSubtitleFont(customFontWeight: FontWeight.bold),
    );
  }

  static description(String description, BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Text(
              OlukoLocalizations.get(context, 'description') + ":",
              style: OlukoFonts.olukoSuperBigFont(customFontWeight: FontWeight.bold),
            )),
        Text(
          description,
          style: OlukoFonts.olukoBigFont(customFontWeight: FontWeight.normal, customColor: OlukoColors.white),
        ),
      ],
    );
  }

  static Widget getTextWidget(String text, bool big) {
    TextStyle style;
    if (big) {
      style = OlukoFonts.olukoBigFont(customFontWeight: FontWeight.w400);
    } else {
      style = OlukoFonts.olukoBigFont();
    }
    return Text(
      text,
      style: style,
    );
  }

  static Column labelWithTitle(String title, String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: OlukoFonts.olukoBigFont(customFontWeight: FontWeight.bold),
        ),
        Text(
          label,
          style: OlukoFonts.olukoBigFont(),
        )
      ],
    );
  }

  static List<EnrollmentMovement> getMovementsFromEnrollmentSegment({List<EnrollmentSection> courseEnrollmentSections}) {
    List<EnrollmentMovement> enrollmentMovements = [];
    courseEnrollmentSections.forEach((enrollmentSection) {
      enrollmentSection.movements.forEach((enrollmentMovement) {
        enrollmentMovements.add(enrollmentMovement);
      });
    });
    return enrollmentMovements;
  }

  static bool checkIfMovementRequireWeigth(MovementSubmodel movement, List<EnrollmentMovement> enrollmentMovements) =>
      enrollmentMovements.where((enrollmentMovement) => enrollmentMovement.id == movement.id).first.weightRequired;

  static List<MovementSubmodel> getMovementsWithWeights({List<SectionSubmodel> sections, List<EnrollmentMovement> enrollmentMovements}) {
    List<MovementSubmodel> movementsWithWeight = [];
    sections.forEach((section) {
      section.movements.forEach((movement) {
        if (MovementUtils.checkIfMovementRequireWeigth(movement, enrollmentMovements)) {
          if (movementsWithWeight.where((movementRecord) => movementRecord.id == movement.id).isEmpty) {
            movementsWithWeight.add(movement);
          }
        }
      });
    });
    return movementsWithWeight;
  }

  static int getMaxWeightByImperialSystemUse({double maxWeight, bool useImperialSystem}) =>
    useImperialSystem ? maxWeight.round() : (maxWeight * _toKilogramsUnit).round();

  static int kilogramToLbs(int maxWeight){
    return (maxWeight * _passToKilogramsUnit).round();
  }

  static int lbsToKilogram(int maxWeight){
    return (maxWeight * _toKilogramsUnit).round();
  }

  static double get _toKilogramsUnit => 0.453;
  static double get _passToKilogramsUnit => 2.20462;



}
