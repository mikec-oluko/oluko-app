import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:oluko_app/models/enums/counter_enum.dart';
import 'package:oluko_app/models/enums/parameter_enum.dart';

class MovementSubmodel {
  DocumentReference reference;
  String id;
  String name;
  ParameterEnum parameter;
  int value;
  CounterEnum counter;
  bool isRestTime;
  bool isBothSide;

  MovementSubmodel({this.isBothSide, this.id, this.name, this.reference, this.counter, this.parameter, this.value, this.isRestTime});

  factory MovementSubmodel.fromJson(Map<String, dynamic> json) {
    return MovementSubmodel(
      reference: json['reference'] as DocumentReference,
      id: json['id']?.toString(),
      name: json['name']?.toString(),
      value: json['value'] as int,
      isRestTime: json['is_rest_time'] == null ? false : json['is_rest_time'] as bool,
      isBothSide: json['is_both_side'] == null ? false : json['is_both_side'] as bool,
      counter: json['counter'] == null ? null : CounterEnum.values[json['counter'] as int],
      parameter: json['parameter'] == null ? null : ParameterEnum.values[json['parameter'] as int],
    );
  }

  Map<String, dynamic> toJson() => {
        'reference': reference,
        'id': id,
        'name': name,
        'value': value,
        'counter': counter == null ? null : counter.index,
        'parameter': parameter == null ? null : parameter.index,
        'is_rest_time': isRestTime,
        'is_both_side': isBothSide,
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
