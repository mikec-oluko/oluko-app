import 'package:oluko_app/models/class.dart';
import 'package:oluko_app/models/movement.dart';
import 'package:oluko_app/models/submodels/object_submodel.dart';
import 'package:oluko_app/models/submodels/segment_submodel.dart';

class ClassService {
  static List<Movement> getClassSegmentMovements(
      List<ObjectSubmodel> classMovements, List<Movement> allMovements) {
    List<String> movementIds = [];
    List<Movement> movements = [];
    classMovements.forEach((ObjectSubmodel movement) {
      movementIds.add(movement.id);
    });
    allMovements.forEach((movement) {
      if (movementIds.contains(movement.id)) {
        movements.add(movement);
      }
    });
    return movements;
  }

  static List<ObjectSubmodel> getClassMovements(Class classObj) {
    List<ObjectSubmodel> movements = [];
    classObj.segments.forEach((SegmentSubmodel segment) {
      movements += segment.movements;
    });
    return movements;
  }
}
