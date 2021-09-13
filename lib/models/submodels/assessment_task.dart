import 'package:cloud_firestore/cloud_firestore.dart';

class AssessmentTask {
  AssessmentTask({this.taskReference, this.index, this.taskId});

  DocumentReference taskReference;
  num index;
  String taskId;
  String taskName;

  AssessmentTask.fromJson(Map json)
      : taskReference = json['reference'] as DocumentReference,
        index = json['index'] as num,
        taskId = json['id'] as String,
        taskName = json['name'] as String;

  Map<String, dynamic> toJson() => {'reference': taskReference, 'index': index, 'id': taskId, 'name': taskName};
}
