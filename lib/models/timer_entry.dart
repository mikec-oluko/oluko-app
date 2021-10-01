import 'package:oluko_app/models/enums/counter_enum.dart';
import 'package:oluko_app/models/enums/parameter_enum.dart';
import 'package:oluko_app/models/submodels/movement_submodel.dart';

class TimerEntry {
  TimerEntry(
      {this.movement,
      this.labels,
      this.parameter,
      this.value,
      this.round,
      this.sectionIndex,
      this.counter});

  MovementSubmodel movement;
  List<String> labels;
  int round;
  ParameterEnum parameter;
  int value;
  CounterEnum counter;
  int sectionIndex;
}
