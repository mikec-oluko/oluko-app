import 'package:equatable/equatable.dart';

class WorkoutWeight extends Equatable {
  int classIndex, segmentIndex, sectionIndex, movementIndex;
  int weight;
  String movementId;

  WorkoutWeight({this.classIndex, this.segmentIndex, this.sectionIndex, this.movementIndex, this.movementId, this.weight});

  @override
  List<Object> get props => [classIndex, segmentIndex, sectionIndex, movementIndex, movementId];
}
