import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class CourseTimelineSubmodel extends Equatable {
  DocumentReference reference;
  String id;
  String name;

  CourseTimelineSubmodel({this.id = '0', this.name = 'All', this.reference});

  factory CourseTimelineSubmodel.fromJson(Map<String, dynamic> json) {
    return CourseTimelineSubmodel(
        reference: json['reference'] as DocumentReference, id: json['id'].toString(), name: json['name'].toString());
  }

  Map<String, dynamic> toJson() => {
        'reference': reference,
        'id': id,
        'name': name,
      };

  @override
  List<Object> get props => [reference, id, name];
}
