import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:oluko_app/models/enums/counter_enum.dart';
import 'package:oluko_app/models/enums/parameter_enum.dart';

class MovementSubmodel {
  DocumentReference reference;
  String id;
  String name;
  String image;
  ParameterEnum parameter;
  int value;
  int percentOfMaxWeight;
  CounterEnum counter;
  bool storeWeights;
  bool isRestTime;
  bool isBothSide;

  MovementSubmodel(
      {this.isBothSide,
      this.image,
      this.id,
      this.name,
      this.reference,
      this.counter,
      this.parameter,
      this.value,
      this.percentOfMaxWeight,
      this.isRestTime,
      this.storeWeights});

  factory MovementSubmodel.fromJson(Map<String, dynamic> json) {
    return MovementSubmodel(
      reference: json['reference'] as DocumentReference,
      id: json['id']?.toString(),
      name: json['name']?.toString(),
      value: json['value'] != null
          ? json['value'] is double
              ? (json['value'] as double).floor()
              : json['value'] is int
                  ? json['value'] as int
                  : 0
          : 0,
      image: json['image'] == null ? null : json['image']?.toString(),
      percentOfMaxWeight: json['percentage_value'] == null ? 0 : json['percentage_value'] as int,
      isRestTime: json['is_rest_time'] == null ? false : json['is_rest_time'] as bool,
      isBothSide: json['is_both_side'] == null ? false : json['is_both_side'] as bool,
      counter: json['counter'] == null ? null : CounterEnum.values[json['counter'] as int],
      parameter: json['parameter'] == null ? null : ParameterEnum.values[json['parameter'] as int],
      storeWeights: json['store_weights'] == null ? false : json['store_weights'] as bool,
    );
  }

  Map<String, dynamic> toJson() => {
        'reference': reference,
        'id': id,
        'name': name,
        'image': image,
        'value': value,
        'percentage_value': percentOfMaxWeight,
        'counter': counter == null ? null : counter.index,
        'parameter': parameter == null ? null : parameter.index,
        'is_rest_time': isRestTime,
        'is_both_side': isBothSide,
        'store_weights': storeWeights
      };

  String getLabel() {
    switch (counter) {
      case CounterEnum.distance:
        return 'm';
      case CounterEnum.weight:
        return 'lbs';
      default:
        return name;
    }
  }
}
