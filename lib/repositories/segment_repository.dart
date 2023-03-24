import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:oluko_app/models/class.dart';
import 'package:oluko_app/models/course_enrollment.dart';
import 'package:oluko_app/models/segment.dart';
import 'package:oluko_app/models/submodels/enrollment_class.dart';
import 'package:oluko_app/models/submodels/enrollment_segment.dart';
import 'package:oluko_app/models/submodels/segment_submodel.dart';

class SegmentRepository {
  FirebaseFirestore firestoreInstance;

  SegmentRepository() {
    firestoreInstance = FirebaseFirestore.instance;
  }

  SegmentRepository.test({FirebaseFirestore firestoreInstance}) {
    this.firestoreInstance = firestoreInstance;
  }

  static Future<List<Segment>> getByClass(EnrollmentClass classObj) async {
    List<Segment> segments = [];
    for (EnrollmentSegment segment in classObj.segments) {
      QuerySnapshot qs = await FirebaseFirestore.instance
          .collection('projects')
          .doc(GlobalConfiguration().getString('projectId'))
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
        FirebaseFirestore.instance.collection('projects').doc(GlobalConfiguration().getString('projectId')).collection('segments').doc(id);
    DocumentSnapshot ds = await reference.get();
    return Segment.fromJson(ds.data() as Map<String, dynamic>);
  }

  static Future<List<Segment>> getAll() async {
    QuerySnapshot querySnapshot =
        await FirebaseFirestore.instance.collection('projects').doc(GlobalConfiguration().getString('projectId')).collection('segments').get();
    return mapQueryToSegment(querySnapshot);
  }

  static Future<void> addLike(CourseEnrollment courseEnrollment, int classIndex, int segmentIndex, String segmentId) async {
    await FirebaseFirestore.instance
        .collection('projects')
        .doc(GlobalConfiguration().getString("projectId"))
        .collection('segments')
        .doc(segmentId)
        .update({'likes': FieldValue.increment(1)});
    DocumentReference reference = FirebaseFirestore.instance
        .collection('projects')
        .doc(GlobalConfiguration().getString('projectId'))
        .collection('courseEnrollments')
        .doc(courseEnrollment.id);
    final List<EnrollmentClass> classes = courseEnrollment.classes;
    classes[classIndex].segments[segmentIndex].likes = classes[classIndex].segments[segmentIndex].likes + 1;
    reference.update({
      'classes': List<dynamic>.from(classes.map((c) => c.toJson())),
    });
  }

  static Future<void> addDisLike(CourseEnrollment courseEnrollment, int classIndex, int segmentIndex, String segmentId) async {
    await FirebaseFirestore.instance
        .collection('projects')
        .doc(GlobalConfiguration().getString("projectId"))
        .collection('segments')
        .doc(segmentId)
        .update({'dislikes': FieldValue.increment(1)});
    DocumentReference reference = FirebaseFirestore.instance
        .collection('projects')
        .doc(GlobalConfiguration().getString('projectId'))
        .collection('courseEnrollments')
        .doc(courseEnrollment.id);
    final List<EnrollmentClass> classes = courseEnrollment.classes;
    classes[classIndex].segments[segmentIndex].dislikes = classes[classIndex].segments[segmentIndex].dislikes + 1;
    reference.update({
      'classes': List<dynamic>.from(classes.map((c) => c.toJson())),
    });
  }

  static Future<void> updateLikesDislikes(CourseEnrollment courseEnrollment, int classIndex, int segmentIndex, String segmentId, bool likes) async {
    final DocumentReference segmentReference =
        FirebaseFirestore.instance.collection('projects').doc(GlobalConfiguration().getString('projectId')).collection('segments').doc(segmentId);
    final DocumentReference courseEnrollmentReference = FirebaseFirestore.instance
        .collection('projects')
        .doc(GlobalConfiguration().getString('projectId'))
        .collection('courseEnrollments')
        .doc(courseEnrollment.id);
    if (likes) {
      final List<EnrollmentClass> classes = courseEnrollment.classes;
      if (classes[classIndex].segments[segmentIndex].likes == 0) {
        await segmentReference.update({'likes': FieldValue.increment(1), 'dislikes': FieldValue.increment(-1)});
        classes[classIndex].segments[segmentIndex].likes = classes[classIndex].segments[segmentIndex].likes + 1;
        classes[classIndex].segments[segmentIndex].dislikes = classes[classIndex].segments[segmentIndex].dislikes - 1;
        courseEnrollmentReference.update({
          'classes': List<dynamic>.from(classes.map((c) => c.toJson())),
        });
      }
    } else {
      final List<EnrollmentClass> classes = courseEnrollment.classes;
      if (classes[classIndex].segments[segmentIndex].dislikes == 0) {
        await segmentReference.update({'likes': FieldValue.increment(-1), 'dislikes': FieldValue.increment(1)});
        classes[classIndex].segments[segmentIndex].likes = classes[classIndex].segments[segmentIndex].likes - 1;
        classes[classIndex].segments[segmentIndex].dislikes = classes[classIndex].segments[segmentIndex].dislikes + 1;
        courseEnrollmentReference.update({
          'classes': List<dynamic>.from(classes.map((c) => c.toJson())),
        });
      }
    }
  }
}
