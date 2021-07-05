import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:oluko_app/models/class.dart';
import 'package:oluko_app/models/course.dart';
import 'package:oluko_app/models/segment.dart';
import 'package:oluko_app/models/submodels/object_submodel.dart';
import 'package:oluko_app/repositories/class_reopoistory.dart';
import 'package:oluko_app/repositories/course_repository.dart';

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
        .collection('segments').where("id", whereIn: classSegmentsIds)
        .get();
    return mapQueryToSegment(querySnapshot);
  }

  static Future<Segment> create(Segment segment, DocumentReference classReference) async{
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
}
