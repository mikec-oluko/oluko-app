import 'package:cloud_firestore/cloud_firestore.dart';

class AssessmentTask {
  AssessmentTask({this.taskReference, this.taskId});

  DocumentReference taskReference;
  String taskId;
  String taskName;

  AssessmentTask.fromJson(Map json)
      : taskReference = json['reference'] as DocumentReference,
        taskId = json['id']?.toString(),
        taskName = json['name']?.toString();

  Map<String, dynamic> toJson() => {'reference': taskReference, 'id': taskId, 'name': taskName};
}
