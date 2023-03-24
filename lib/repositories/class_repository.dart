import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:oluko_app/models/class.dart';
import 'package:oluko_app/models/course.dart';
import 'package:oluko_app/models/submodels/object_submodel.dart';
import 'package:oluko_app/models/submodels/segment_submodel.dart';
import 'package:oluko_app/repositories/course_repository.dart';

class ClassRepository {
  FirebaseFirestore firestoreInstance;

  ClassRepository() {
    firestoreInstance = FirebaseFirestore.instance;
  }

  ClassRepository.test({this.firestoreInstance});

  static Future<List<Class>> getAll(Course course) async {
    final List<Class> classes = [];
    if (course.classes == null) {
      return classes;
    }
    for (final ObjectSubmodel classObj in course.classes) {
      final DocumentSnapshot ds = await classObj.reference.get();
      final Class retrievedClass = Class.fromJson(ds.data() as Map<String, dynamic>);
      classes.add(retrievedClass);
    }
    return classes;
  }

  static Future<Class> create(Class newClass, DocumentReference courseReference) async {
    final CollectionReference reference =
        FirebaseFirestore.instance.collection('projects').doc(GlobalConfiguration().getString('projectId')).collection('classes');
    final DocumentReference docRef = reference.doc();
    newClass.id = docRef.id;
    docRef.set(newClass.toJson());
    final ObjectSubmodel classObj = ObjectSubmodel(id: newClass.id, reference: reference.doc(newClass.id), name: newClass.name);
    await CourseRepository.updateClasses(classObj, courseReference);
    return newClass;
  }

  static Future<void> updateSegments(SegmentSubmodel segment, DocumentReference reference) async {
    final DocumentSnapshot ds = await reference.get();
    final Class classObj = Class.fromJson(ds.data() as Map<String, dynamic>);
    List<SegmentSubmodel> segments;
    if (classObj.segments == null) {
      segments = [];
    } else {
      segments = classObj.segments;
    }
    segments.add(segment);
    reference.update({'segments': List<dynamic>.from(segments.map((segment) => segment.toJson()))});
  }

  static Future<Class> get(String id) async {
    final DocumentReference reference =
        FirebaseFirestore.instance.collection('projects').doc(GlobalConfiguration().getString('projectId')).collection('classes').doc(id);
    final DocumentSnapshot ds = await reference.get();
    return Class.fromJson(ds.data() as Map<String, dynamic>);
  }

  static Future<void> addSelfie(String classId, String image) async {
    final DocumentReference reference =
        FirebaseFirestore.instance.collection('projects').doc(GlobalConfiguration().getString('projectId')).collection('classes').doc(classId);
    final DocumentSnapshot ds = await reference.get();
    final Class classObj = Class.fromJson(ds.data() as Map<String, dynamic>);
    final List<String> images = classObj.userSelfies ?? [];
    images.add(image);
    await reference.update({'user_selfies': images});
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> getClassesSubscription() {
    final Stream<QuerySnapshot<Map<String, dynamic>>> movementsStream =
        FirebaseFirestore.instance.collection('projects').doc(GlobalConfiguration().getString('projectId')).collection('classes').snapshots();
    return movementsStream;
  }
}
