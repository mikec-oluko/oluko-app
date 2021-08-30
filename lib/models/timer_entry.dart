import 'package:oluko_app/models/submodels/movement_submodel.dart';
import 'package:oluko_app/models/utils/timer_model.dart';

class TimerEntry {
  MovementSubmodel movement;
  WorkState workState;
  String label;
  List<String> labels;
  num setNumber;
  num roundNumber;
  num time;
  num reps;

  TimerEntry(
      {this.movement,
      this.workState,
      this.label,
      this.labels,
      this.setNumber,
      this.roundNumber,
      this.time,
      this.reps});
}
