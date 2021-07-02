import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:oluko_app/blocs/class_bloc.dart';
import 'package:oluko_app/models/class.dart';
import 'package:oluko_app/models/course.dart';
import 'package:oluko_app/models/submodels/object_submodel.dart';
import 'package:oluko_app/models/task.dart';
import 'package:oluko_app/repositories/course_repository.dart';

class ClassRepository {
  FirebaseFirestore firestoreInstance;

  ClassRepository() {
    firestoreInstance = FirebaseFirestore.instance;
  }

  ClassRepository.test({FirebaseFirestore firestoreInstance}) {
    this.firestoreInstance = firestoreInstance;
  }

  static Future<List<Class>> getAll(Course course) async {
    List<String> courseClassesId = [];
    course.classes.forEach((ObjectSubmodel classObj) {
      courseClassesId.add(classObj.objectId);
     });
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('projects')
        .doc(GlobalConfiguration().getValue("projectId"))
        .collection('classes').where("id", whereIn: courseClassesId)
        .get();
    return mapQueryToClass(querySnapshot);
  }

  static Future<Class> create(Class newClass, DocumentReference courseReference) async{
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
}