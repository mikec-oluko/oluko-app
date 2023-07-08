import 'package:equatable/equatable.dart';

class WorkoutWeight extends Equatable {
  int classIndex, segmentIndex, sectionIndex, movementIndex;
  int weight;
  String movementId;
  bool setMaxWeight;
  bool isPersonalRecord;

  WorkoutWeight(
      {this.classIndex,
      this.segmentIndex,
      this.sectionIndex,
      this.movementIndex,
      this.movementId,
      this.weight,
      this.setMaxWeight = false,
      this.isPersonalRecord = false});

  @override
  List<Object> get props => [classIndex, segmentIndex, sectionIndex, movementIndex, movementId, setMaxWeight, isPersonalRecord];
}
