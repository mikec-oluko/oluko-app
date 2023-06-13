import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:oluko_app/models/class.dart';
import 'package:oluko_app/models/movement.dart';
import 'package:oluko_app/models/movement_relation.dart';
import 'package:oluko_app/models/segment.dart';
import 'package:oluko_app/models/submodels/movement_submodel.dart';
import 'package:oluko_app/models/submodels/object_submodel.dart';
import 'package:oluko_app/models/submodels/section_submodel.dart';
import 'package:oluko_app/models/weight_record.dart';
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
    segment.sections.forEach((SectionSubmodel section) {
      section.movements.forEach((MovementSubmodel movement) {
        segmentMovementsIds.add(movement.id);
      });
    });
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('projects')
        .doc(GlobalConfiguration().getString('projectId'))
        .collection('movements')
        .where("id", whereIn: segmentMovementsIds)
        .get();
    return mapQueryToMovement(querySnapshot);
  }

  static Future<List<Movement>> getAll() async {
    QuerySnapshot querySnapshot =
        await FirebaseFirestore.instance.collection('projects').doc(GlobalConfiguration().getString('projectId')).collection('movements').get();
    return mapQueryToMovement(querySnapshot);
  }

  static Future<List<Movement>> get(String id) async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('projects')
        .doc(GlobalConfiguration().getString('projectId'))
        .collection('movements')
        .where('id', isEqualTo: id)
        .get();
    return mapQueryToMovement(querySnapshot);
  }

  static Future<List<Movement>> getVariants(String id) async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('projects')
        .doc(GlobalConfiguration().getString('projectId'))
        .collection('movements')
        .doc(id)
        .collection('movementVariants')
        .where('is_deleted', isNotEqualTo: true)
        .get();

    var items = mapQueryToMovement(querySnapshot);
    return items;
  }

  Future<List<Movement>> getRecommendedWeightMovements() async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('projects')
        .doc(GlobalConfiguration().getString('projectId'))
        .collection('movements')
        .where('recommend_weight', isEqualTo: true)
        .where('is_deleted', isEqualTo: false)
        .get();
    return mapQueryToMovement(querySnapshot);
  }


  static Future<MovementRelation> getRelations(String id) async {
    DocumentSnapshot querySnapshot =
        await FirebaseFirestore.instance.collection('projects').doc(GlobalConfiguration().getString('projectId')).collection('movementRelations').doc(id).get();

    MovementRelation movementRelation = MovementRelation.fromJson(querySnapshot.data() as Map<String, dynamic>);
    return movementRelation;
  }

  static List<Movement> mapQueryToMovement(QuerySnapshot qs) {
    return qs.docs.map((DocumentSnapshot ds) {
      Map<String, dynamic> movementData = ds.data() as Map<String, dynamic>;
      return Movement.fromJson(movementData);
    }).toList();
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> getMovementsSubscription() {
    Stream<QuerySnapshot<Map<String, dynamic>>> movementsStream =
        FirebaseFirestore.instance.collection('projects').doc(GlobalConfiguration().getString('projectId')).collection('movements').snapshots();
    return movementsStream;
  }

  static Movement getByClass(Class classObj) {
    return null;
  }
}
