import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:oluko_app/models/class.dart';
import 'package:oluko_app/models/segment.dart';
import 'package:oluko_app/models/submodels/segment_submodel.dart';
class SegmentRepository {
  FirebaseFirestore firestoreInstance;

  SegmentRepository() {
    firestoreInstance = FirebaseFirestore.instance;
  }

  SegmentRepository.test({FirebaseFirestore firestoreInstance}) {
    this.firestoreInstance = firestoreInstance;
  }

  static Future<List<Segment>> getAll(Class classObj) async {
    List<Segment> segments = [];
    for (SegmentSubmodel segment in classObj.segments) {
      DocumentSnapshot ds = await segment.reference.get();
      Segment retrievedSegment =
          Segment.fromJson(ds.data() as Map<String, dynamic>);
      segments.add(retrievedSegment);
    }
    return segments;
  }

  static List<Segment> mapQueryToSegment(QuerySnapshot qs) {
    return qs.docs.map((DocumentSnapshot ds) {
      return Segment.fromJson(ds.data() as Map<String, dynamic>);
    }).toList();
  }
}
