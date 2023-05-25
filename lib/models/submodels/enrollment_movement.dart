import 'package:cloud_firestore/cloud_firestore.dart';

class EnrollmentMovement {
  String id;
  DocumentReference reference;
  String name;
  List<int> counters;
  bool storeWeights;
  int percentOfMaxWeight;
  double weight;

  EnrollmentMovement({this.id, this.reference, this.name, this.counters, this.storeWeights, this.percentOfMaxWeight, this.weight});

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
        percentOfMaxWeight: json['percentage_value'] as int,
        storeWeights: json['store_weights'] == null ? false : json['store_weights'] as bool,
        weight: json['weight'] == null ? 0 : (json['weight'] as num).toDouble());
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'reference': reference,
        'name': name,
        'counters': counters == null ? null : counters,
        'store_weights': storeWeights,
        'percentage_value': percentOfMaxWeight,
        'weight': weight
      };
}
