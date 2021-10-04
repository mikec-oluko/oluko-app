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
        taskId = json['id']?.toString(),
        taskName = json['name']?.toString();

  Map<String, dynamic> toJson() => {'reference': taskReference, 'id': taskId, 'name': taskName};
}
