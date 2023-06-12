import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/models/max_weight.dart';
import 'package:oluko_app/models/submodels/enrollment_movement.dart';
import 'package:oluko_app/models/submodels/enrollment_section.dart';
import 'package:oluko_app/models/submodels/movement_submodel.dart';
import 'package:oluko_app/models/submodels/section_submodel.dart';
import 'package:oluko_app/models/weight_record.dart';
import 'oluko_localizations.dart';

class MovementUtils {
  static Text movementTitle({String title, bool isSmallScreen = false}) {
    return Text(
      title,
      textAlign: TextAlign.center,
      style: isSmallScreen ? OlukoFonts.olukoBigFont(customFontWeight: FontWeight.bold) : OlukoFonts.olukoSubtitleFont(customFontWeight: FontWeight.bold),
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

  static bool checkIfMovementRequireWeight(
    MovementSubmodel movement,
    List<EnrollmentMovement> enrollmentMovements,
  ) =>
      enrollmentMovements.firstWhere((enrollmentMovement) => enrollmentMovement.id == movement.id, orElse: () => null)?.storeWeight ?? false;

  static List<MovementSubmodel> getMovementsWithWeights({List<SectionSubmodel> sections, List<EnrollmentMovement> enrollmentMovements}) {
    List<MovementSubmodel> movementsWithWeight = [];
    sections.forEach((section) {
      section.movements.forEach((movement) {
        if (MovementUtils.checkIfMovementRequireWeight(movement, enrollmentMovements)) {
          if (movementsWithWeight.where((movementRecord) => movementRecord.id == movement.id).isEmpty) {
            movementsWithWeight.add(movement);
          }
        }
      });
    });
    return movementsWithWeight;
  }

  static String getWeight({MovementSubmodel currentMovement, String segmentId, List<WeightRecord> weightRecordsList, bool useImperialSystem = false}) {
    String result;
    if (weightRecordsList.isNotEmpty) {
      if (getWeightOnRecords(weightRecordsList, currentMovement, segmentId).isNotEmpty) {
        result = getWeightOnRecords(weightRecordsList, currentMovement, segmentId).first.weight.toString();
      }
    }
    return result;
  }

  static int getMaxWeightByImperialSystemUse({double maxWeight, bool useImperialSystem}) =>
      useImperialSystem ? maxWeight.round() : (maxWeight * _toKilogramsUnit).round();

  static double get _toKilogramsUnit => 0.453;

  static int kilogramToLbs(int maxWeightInKg) {
    return (maxWeightInKg * _passToKilogramsUnit).round();
  }

  static int lbsToKilogram(int maxWeightInLbs) {
    return (maxWeightInLbs * _toKilogramsUnit).round();
  }

  static double get _passToKilogramsUnit => 2.20462;

  static int getMaxWeightForMovement(MovementSubmodel movement, List<MaxWeight> maxWeightRecords) {
    int maxWeightRecord = 0;
    if (maxWeightRecords != null && maxWeightRecords.isNotEmpty) {
      if (maxWeightRecords.where((maxWeightRecord) => maxWeightRecord.movementId == movement.id).isNotEmpty) {
        maxWeightRecord = maxWeightRecords.firstWhere((maxWeightRecord) => maxWeightRecord.movementId == movement.id).weight;
      }
    }
    return maxWeightRecord;
  }

  static Iterable<WeightRecord> getWeightOnRecords(List<WeightRecord> weightRecordsList, MovementSubmodel currentMovement, String segmentId) {
    return weightRecordsList.where((weightRecord) => weightRecord.movementId == currentMovement.id && weightRecord.segmentId == segmentId);
  }
}
