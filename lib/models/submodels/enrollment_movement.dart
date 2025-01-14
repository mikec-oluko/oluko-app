import 'package:cloud_firestore/cloud_firestore.dart';

class EnrollmentMovement {
  String id;
  DocumentReference reference;
  String name;
  List<int> counters;
  bool storeWeight;
  int percentOfMaxWeight;
  double weight;
  bool setMaxWeight;
  bool personalRecord;

  EnrollmentMovement(
      {this.id, this.reference, this.name, this.counters, this.storeWeight, this.percentOfMaxWeight, this.weight, this.personalRecord, this.setMaxWeight});

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
        storeWeight: json['store_weight'] == null ? false : json['store_weight'] as bool,
        setMaxWeight: json['set_max_weight'] == null ? false : json['set_max_weight'] as bool,
        personalRecord: json['personal_record'] == null ? false : json['personal_record'] as bool,
        weight: json['weight'] == null ? 0 : (json['weight'] as num).toDouble());
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'reference': reference,
        'name': name,
        'counters': counters == null ? null : counters,
        'store_weight': storeWeight,
        'percentage_value': percentOfMaxWeight,
        'weight': weight,
        'set_max_weight': setMaxWeight,
        'personal_record': personalRecord
      };
}
