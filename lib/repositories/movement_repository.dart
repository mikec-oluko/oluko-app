import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:oluko_app/models/movement.dart';
import 'package:oluko_app/models/segment.dart';
import 'package:oluko_app/models/submodels/movement_submodel.dart';
import 'package:oluko_app/models/submodels/object_submodel.dart';
import 'package:oluko_app/repositories/segment_repository.dart';

class MovementRepository {
  FirebaseFirestore firestoreInstance;

  MovementRepository() {
    firestoreInstance = FirebaseFirestore.instance;
  }

  MovementRepository.test({FirebaseFirestore firestoreInstance}) {
    this.firestoreInstance = firestoreInstance;
  }

  static Future<List<Movement>> getBySegment(Segment segment) async {
    List<String> segmentMovementsIds = [];
    segment.movements.forEach((MovementSubmodel movement) {
      segmentMovementsIds.add(movement.id);
    });
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('projects')
        .doc(GlobalConfiguration().getValue("projectId"))
        .collection('movements')
        .where("id", whereIn: segmentMovementsIds)
        .get();
    return mapQueryToMovement(querySnapshot);
  }

  static Future<List<Movement>> getAll() async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('projects')
        .doc(GlobalConfiguration().getValue("projectId"))
        .collection('movements')
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
    MovementSubmodel movementObj = MovementSubmodel(
        id: movement.id,
        reference: reference.doc(movement.id),
        name: movement.name);
    await SegmentRepository.updateMovements(movementObj, segmentReference);
    return movement;
  }

  static List<Movement> mapQueryToMovement(QuerySnapshot qs) {
    return qs.docs.map((DocumentSnapshot ds) {
      dynamic movementData = ds.data();
      return Movement.fromJson(movementData);
    }).toList();
  }
}
