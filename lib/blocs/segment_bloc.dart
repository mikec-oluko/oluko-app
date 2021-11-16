import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oluko_app/models/class.dart';
import 'package:oluko_app/models/segment.dart';
import 'package:oluko_app/repositories/segment_repository.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

abstract class SegmentState {}

class LoadingSegment extends SegmentState {}

class GetSegmentsSuccess extends SegmentState {
  List<Segment> segments;
  GetSegmentsSuccess({this.segments});
}

class GetSegmentSuccess extends SegmentState {
  Segment segment;
  GetSegmentSuccess({this.segment});
}

class Failure extends SegmentState {
  final dynamic exception;

  Failure({this.exception});
}

class SegmentBloc extends Cubit<SegmentState> {
  SegmentBloc() : super(LoadingSegment());

  void getAll(Class classObj) async {
    emit(LoadingSegment());
    try {
      List<Segment> segments = await SegmentRepository.getAll(classObj);
      emit(GetSegmentsSuccess(segments: segments));
    } catch (exception, stackTrace) {
      await Sentry.captureException(
        exception,
        stackTrace: stackTrace,
      );
      emit(Failure(exception: exception));
      rethrow;
    }
  }

  void getById(String id) async {
    emit(LoadingSegment());
    try {
      Segment segment = await SegmentRepository.get(id);
      emit(GetSegmentSuccess(segment: segment));
    } catch (exception, stackTrace) {
      await Sentry.captureException(
        exception,
        stackTrace: stackTrace,
      );
      emit(Failure(exception: exception));
      rethrow;
    }
  }
}
