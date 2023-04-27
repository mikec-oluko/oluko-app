import 'package:equatable/equatable.dart';

class WorkoutWeight extends Equatable {
  int classIndex, segmentIndex, sectionIndex, movementIndex;
  double weight;
  String movementId;

  WorkoutWeight({this.classIndex, this.segmentIndex, this.sectionIndex, this.movementIndex, this.movementId, this.weight});

  @override
  // TODO: implement props
  List<Object> get props => [classIndex, segmentIndex, sectionIndex, movementIndex, movementId];
}
