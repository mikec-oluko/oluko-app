import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:mvt_fitness/models/class.dart';
import 'package:mvt_fitness/models/segment.dart';
import 'package:mvt_fitness/models/submodels/object_submodel.dart';
import 'package:mvt_fitness/repositories/class_reopoistory.dart';

class SegmentRepository {
  FirebaseFirestore firestoreInstance;

  SegmentRepository() {
    firestoreInstance = FirebaseFirestore.instance;
  }

  SegmentRepository.test({FirebaseFirestore firestoreInstance}) {
    this.firestoreInstance = firestoreInstance;
  }

  static Future<List<Segment>> getAll(Class classObj) async {
    List<String> classSegmentsIds = [];
    classObj.segments.forEach((ObjectSubmodel segment) {
      classSegmentsIds.add(segment.objectId);
    });
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('projects')
        .doc(GlobalConfiguration().getValue("projectId"))
        .collection('segments')
        .where("id", whereIn: classSegmentsIds)
        .get();
    return mapQueryToSegment(querySnapshot);
  }

  static Future<Segment> create(
      Segment segment, DocumentReference classReference) async {
    CollectionReference reference = FirebaseFirestore.instance
        .collection('projects')
        .doc(GlobalConfiguration().getValue("projectId"))
        .collection('segments');
    final DocumentReference docRef = reference.doc();
    segment.id = docRef.id;
    docRef.set(segment.toJson());
    ObjectSubmodel segmentObj = ObjectSubmodel(
        objectId: segment.id,
        objectReference: reference.doc(segment.id),
        objectName: segment.name);
    await ClassRepository.updateSegments(segmentObj, classReference);
    return segment;
  }

  static List<Segment> mapQueryToSegment(QuerySnapshot qs) {
    return qs.docs.map((DocumentSnapshot ds) {
      return Segment.fromJson(ds.data());
    }).toList();
  }

  static Future<void> updateMovements(
      ObjectSubmodel movement, DocumentReference reference) async {
    DocumentSnapshot ds = await reference.get();
    Segment segment = Segment.fromJson(ds.data());
    List<ObjectSubmodel> movements;
    if (segment.movements == null) {
      movements = [];
    } else {
      movements = segment.movements;
    }
    movements.add(movement);
    reference.update({
      'movements':
          List<dynamic>.from(movements.map((movement) => movement.toJson()))
    });
  }
}
