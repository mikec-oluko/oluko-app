import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:mvt_fitness/models/class.dart';
import 'package:mvt_fitness/models/course.dart';
import 'package:mvt_fitness/models/submodels/object_submodel.dart';
import 'package:mvt_fitness/repositories/course_repository.dart';

class ClassRepository {
  FirebaseFirestore firestoreInstance;

  ClassRepository() {
    firestoreInstance = FirebaseFirestore.instance;
  }

  ClassRepository.test({FirebaseFirestore firestoreInstance}) {
    this.firestoreInstance = firestoreInstance;
  }

  static Future<List<Class>> getAll(Course course) async {
    List<String> courseClassesIds = [];
    course.classes.forEach((ObjectSubmodel classObj) {
      courseClassesIds.add(classObj.objectId);
    });
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('projects')
        .doc(GlobalConfiguration().getValue("projectId"))
        .collection('classes')
        .where("id", whereIn: courseClassesIds)
        .get();
    return mapQueryToClass(querySnapshot);
  }

  static Future<Class> create(
      Class newClass, DocumentReference courseReference) async {
    CollectionReference reference = FirebaseFirestore.instance
        .collection('projects')
        .doc(GlobalConfiguration().getValue("projectId"))
        .collection('classes');
    final DocumentReference docRef = reference.doc();
    newClass.id = docRef.id;
    docRef.set(newClass.toJson());
    ObjectSubmodel classObj = ObjectSubmodel(
        objectId: newClass.id,
        objectReference: reference.doc(newClass.id),
        objectName: newClass.name);
    await CourseRepository.updateClasses(classObj, courseReference);
    return newClass;
  }

  static List<Class> mapQueryToClass(QuerySnapshot qs) {
    return qs.docs.map((DocumentSnapshot ds) {
      return Class.fromJson(ds.data());
    }).toList();
  }

  static Future<void> updateSegments(
      ObjectSubmodel segment, DocumentReference reference) async {
    DocumentSnapshot ds = await reference.get();
    Class classObj = Class.fromJson(ds.data());
    List<ObjectSubmodel> segments;
    if (classObj.segments == null) {
      segments = [];
    } else {
      segments = classObj.segments;
    }
    segments.add(segment);
    reference.update({
      'segments':
          List<dynamic>.from(segments.map((segment) => segment.toJson()))
    });
  }
}
