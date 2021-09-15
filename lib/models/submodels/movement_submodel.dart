import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:oluko_app/models/enums/counter_enum.dart';
import 'package:oluko_app/models/enums/parameter_enum.dart';

class MovementSubmodel {
  DocumentReference reference;
  String id;
  String name;
  ParameterEnum parameter;
  int quantity;
  CounterEnum counter;

  MovementSubmodel(
      {this.id,
      this.name,
      this.reference,
      this.counter,
      this.parameter,
      this.quantity});

  factory MovementSubmodel.fromJson(Map<String, dynamic> json) {
    return MovementSubmodel(
      reference: json['reference'] as DocumentReference,
      id: json['id'].toString(),
      name: json['name'].toString(),
      quantity: json['quantity'] as int,
      counter: json['counter'] == null
          ? null
          : CounterEnum.values[json['counter'] as int],
      parameter: json['parameter'] == null
          ? null
          : ParameterEnum.values[json['parameter'] as int],
    );
  }

  Map<String, dynamic> toJson() => {
        'reference': reference,
        'id': id,
        'name': name,
        'quantity': quantity,
        'counter': counter == null ? null : counter.index,
        'parameter': parameter == null ? null : parameter.index,
      };
}
