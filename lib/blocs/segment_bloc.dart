import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oluko_app/models/class.dart';
import 'package:oluko_app/models/segment.dart';
import 'package:oluko_app/repositories/class_reopoistory.dart';
import 'package:oluko_app/repositories/segment_repository.dart';

abstract class SegmentState {}

class Loading extends SegmentState {}

class GetSegmentsSuccess extends SegmentState {
  List<Segment> segments;
  GetSegmentsSuccess({this.segments});
}

class Failure extends SegmentState {
  final Exception exception;

  Failure({this.exception});
}

class SegmentBloc extends Cubit<SegmentState> {
  SegmentBloc() : super(Loading());

  void getAll(Class classObj) async {
    try {
      List<Segment> segments = await SegmentRepository.getAll(classObj);
      emit(GetSegmentsSuccess(segments: segments));
    } catch (e) {
      print(e.toString());
      emit(Failure(exception: e));
    }
  }
}
