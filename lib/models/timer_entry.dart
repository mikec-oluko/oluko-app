import 'package:oluko_app/models/submodels/movement_submodel.dart';
import 'package:oluko_app/models/utils/timer_model.dart';

class TimerEntry {
  MovementSubmodel movement;
  WorkState workState;
  String label;
  num setNumber;
  num roundNumber;
  num time;
  num reps;

  TimerEntry(
      {this.movement,
      this.workState,
      this.label,
      this.setNumber,
      this.roundNumber,
      this.time,
      this.reps});

  factory TimerEntry.fromJson(Map<String, dynamic> json) {
    return TimerEntry(
        movement: json['movement'],
        workState: json['work_state'],
        label: json['label'],
        setNumber: json['set_number'],
        roundNumber: json['round_number'],
        time: json['time'],
        reps: json['reps']);
  }

  Map<String, dynamic> toJson() => {
        'movement': movement,
        'work_state': workState,
        'label': label,
        'set_number': setNumber,
        'round_number': roundNumber,
        'time': time,
        'reps': reps,
      };
}
