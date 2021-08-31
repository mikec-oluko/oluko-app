import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:enum_to_string/enum_to_string.dart';
import 'package:oluko_app/models/enums/counter_enum.dart';

class MovementSubmodel {
  DocumentReference reference;
  String id;
  String name;
  String timerType;
  int timerTotalTime;
  int timerWorkTime;
  int timerRestTime;
  int timerSets;
  int timerReps;
  CounterEnum counter;

  MovementSubmodel(
      {this.id,
      this.name,
      this.reference,
      this.timerType,
      this.timerTotalTime,
      this.timerWorkTime,
      this.timerRestTime,
      this.timerSets,
      this.counter,
      this.timerReps});

  factory MovementSubmodel.fromJson(Map<String, dynamic> json) {
    return MovementSubmodel(
      reference: json['reference'],
      id: json['id'],
      name: json['name'],
      timerType: json['timer_type'],
      timerTotalTime: json['timer_total_time'],
      timerWorkTime: json['timer_work_time'],
      timerRestTime: json['timer_rest_time'],
      timerSets: json['timer_sets'],
      timerReps: json['timer_reps'],
      counter: json['timer_type'] == null
          ? null
          : EnumToString.fromString(CounterEnum.values, json['counter']),
    );
  }

  Map<String, dynamic> toJson() => {
        'reference': reference,
        'id': id,
        'name': name,
        'timer_type': timerType,
        'timer_total_time': timerTotalTime,
        'timer_work_time': timerWorkTime,
        'timer_rest_time': timerRestTime,
        'timer_sets': timerSets,
        'timer_reps': timerReps,
        'counter':
            timerType == null ? null : EnumToString.convertToString(counter),
      };
}
