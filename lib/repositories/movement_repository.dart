import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:mvt_fitness/models/class.dart';
import 'package:mvt_fitness/models/movement.dart';
import 'package:mvt_fitness/models/segment.dart';
import 'package:mvt_fitness/models/submodels/object_submodel.dart';
import 'package:mvt_fitness/repositories/class_reopoistory.dart';
import 'package:mvt_fitness/repositories/segment_repository.dart';

class MovementRepository {
  FirebaseFirestore firestoreInstance;

  MovementRepository() {
    firestoreInstance = FirebaseFirestore.instance;
  }

  MovementRepository.test({FirebaseFirestore firestoreInstance}) {
    this.firestoreInstance = firestoreInstance;
  }

  static Future<List<Movement>> getAll(Segment segment) async {
    List<String> segmentMovementsIds = [];
    segment.movements.forEach((ObjectSubmodel movement) {
      segmentMovementsIds.add(movement.objectId);
    });
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('projects')
        .doc(GlobalConfiguration().getValue("projectId"))
        .collection('movements')
        .where("id", whereIn: segmentMovementsIds)
        .get();
    return mapQueryToMovement(querySnapshot);
  }

  static Future<Movement> create(
      Movement movement, DocumentReference segmentReference) async {
    CollectionReference reference = FirebaseFirestore.instance
        .collection('projects')
        .doc(GlobalConfiguration().getValue("projectId"))
        .collection('movements');
    final DocumentReference docRef = reference.doc();
    movement.id = docRef.id;
    docRef.set(movement.toJson());
    ObjectSubmodel movementObj = ObjectSubmodel(
        objectId: movement.id,
        objectReference: reference.doc(movement.id),
        objectName: movement.name);
    await SegmentRepository.updateMovements(movementObj, segmentReference);
    return movement;
  }

  static List<Movement> mapQueryToMovement(QuerySnapshot qs) {
    return qs.docs.map((DocumentSnapshot ds) {
      return Movement.fromJson(ds.data());
    }).toList();
  }
}
