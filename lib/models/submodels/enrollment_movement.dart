import 'package:cloud_firestore/cloud_firestore.dart';

class EnrollmentMovement {
  String id;
  DocumentReference reference;
  String name;
  List<int> counters;
  bool weightRequired;
  double weight;

  EnrollmentMovement({this.id, this.reference, this.name, this.counters, this.weightRequired, this.weight});

  factory EnrollmentMovement.fromJson(Map<String, dynamic> json) {
    return EnrollmentMovement(
        id: json['id']?.toString(),
        reference: json['reference'] as DocumentReference,
        name: json['name']?.toString(),
        counters: json['counters'] == null || json['counters'].runtimeType == int
            ? null
            : json['counters'] is int
                ? [json['counters'] as int]
                : List<int>.from(
                    (json['counters'] as Iterable).map((counter) => counter as int),
                  ),
        weightRequired: json['weight_required'] == null ? false : json['weight_required'] as bool,
        weight: json['weight'] == null ? 0 : (json['weight']as num).toDouble());
  }

  Map<String, dynamic> toJson() =>
      {'id': id, 'reference': reference, 'name': name, 'counters': counters == null ? null : counters, 'weight_required': weightRequired, 'weight': weight};
}
