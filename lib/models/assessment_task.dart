import 'package:cloud_firestore/cloud_firestore.dart';

class AssessmentTask {
  AssessmentTask({this.taskReference, this.index, this.taskId});

  DocumentReference taskReference;
  num index;
  String taskId;

  AssessmentTask.fromJson(Map json)
      : taskReference = json['task_reference'],
        index = json['index'],
        taskId = json['task_id'];

  Map<String, dynamic> toJson() => {
        'task_reference': taskReference,
        'index': index,
        'task_id': taskId,
      };
}
