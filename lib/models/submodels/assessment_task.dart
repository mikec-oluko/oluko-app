import 'package:cloud_firestore/cloud_firestore.dart';

class AssessmentTask {
  AssessmentTask({this.taskReference, this.index, this.taskId});

  DocumentReference taskReference;
  num index;
  String taskId;
  String taskName;

  AssessmentTask.fromJson(Map json)
      : taskReference = json['reference'],
        index = json['index'],
        taskId = json['id'],
        taskName = json['name'];

  Map<String, dynamic> toJson() => {
        'reference': taskReference,
        'index': index,
        'id': taskId,
        'name': taskName
      };
}
