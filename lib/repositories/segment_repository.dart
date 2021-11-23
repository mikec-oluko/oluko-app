import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:global_configuration/global_configuration.dart';
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
      QuerySnapshot qs = await FirebaseFirestore.instance
          .collection('projects')
          .doc(GlobalConfiguration().getValue('projectId'))
          .collection('segments')
          .where('id', isEqualTo: segment.id)
          .limit(1)
          .get();
      //TODO: IDEAL BUT ERROR BECAUSE OF DELETED SEGEMTNS await segment.reference.get();
      if (qs.size > 0) {
        DocumentSnapshot ds = qs.docs[0];
        Segment retrievedSegment = Segment.fromJson(ds.data() as Map<String, dynamic>);
        segments.add(retrievedSegment);
      }
    }
    return segments;
  }

  static List<Segment> mapQueryToSegment(QuerySnapshot qs) {
    return qs.docs.map((DocumentSnapshot ds) {
      return Segment.fromJson(ds.data() as Map<String, dynamic>);
    }).toList();
  }

  static Future<Segment> get(String id) async {
    DocumentReference reference =
        FirebaseFirestore.instance.collection('projects').doc(GlobalConfiguration().getValue('projectId')).collection('segments').doc(id);
    DocumentSnapshot ds = await reference.get();
    return Segment.fromJson(ds.data() as Map<String, dynamic>);
  }
}
