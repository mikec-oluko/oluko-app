import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:oluko_app/models/submodels/audio.dart';

class ClassAudio {
  String classId;
  DocumentReference classReference;
  List<Audio> audios;

  ClassAudio({this.classId, this.classReference, this.audios});

  factory ClassAudio.fromJson(Map<String, dynamic> json) {
    return ClassAudio(
      classId: json['class_id']?.toString(),
      classReference: json['class_reference'] as DocumentReference,
      audios: json['audios'] == null
          ? null
          : List<Audio>.from((json['audios'] as Iterable).map((audio) => Audio.fromJson(audio as Map<String, dynamic>))),
    );
  }

  Map<String, dynamic> toJson() => {
        'class_id': classId,
        'class_reference': classReference,
        'audios': audios == null ? null : List<Audio>.from(audios.map((audio) => audio.toJson()))
      };
}
