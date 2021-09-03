import 'package:oluko_app/models/enums/counter_enum.dart';
import 'package:oluko_app/models/submodels/movement_submodel.dart';

import 'enums/timer_model.dart';

class TimerEntry {
  MovementSubmodel movement;
  WorkState workState;
  String label;
  List<String> labels;
  num setNumber;
  num roundNumber;
  num time;
  num reps;
  CounterEnum counter;

  TimerEntry(
      {this.movement,
      this.workState,
      this.label,
      this.labels,
      this.setNumber,
      this.roundNumber,
      this.time,
      this.reps,
      this.counter});
}
