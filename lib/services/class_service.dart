import 'package:oluko_app/models/class.dart';
import 'package:oluko_app/models/movement.dart';
import 'package:oluko_app/models/submodels/movement_submodel.dart';
import 'package:oluko_app/models/submodels/section_submodel.dart';
import 'package:oluko_app/models/submodels/segment_submodel.dart';

class ClassService {
  static List<Movement> getClassSegmentMovements(
      List<SectionSubmodel> sections, List<Movement> allMovements) {
    List<String> movementIds = [];
    List<Movement> movements = [];
    for (SectionSubmodel section in sections) {
      for (MovementSubmodel movement in section.movements) {
        if (!movement.isRestTime) {
          movementIds.add(movement.id);
        }
      }
    }
    allMovements.forEach((movement) {
      if (movementIds.contains(movement.id)) {
        movements.add(movement);
      }
    });
    return movements;
  }

  static List<Movement> getClassMovements(
      Class classObj, List<Movement> allMovements) {
    List<Movement> movements = [];
    List<String> movementIds = [];
    for (SegmentSubmodel segment in classObj.segments) {
      for (SectionSubmodel section in segment.sections) {
        for (MovementSubmodel movement in section.movements) {
          if (!movement.isRestTime) {
            movementIds.add(movement.id);
          }
        }
      }
    }
    allMovements.forEach((movement) {
      if (movementIds.contains(movement.id)) {
        movements.add(movement);
      }
    });
    return movements;
  }
}
