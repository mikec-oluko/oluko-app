import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oluko_app/models/class.dart';
import 'package:oluko_app/models/segment.dart';
import 'package:oluko_app/models/submodels/enrollment_class.dart';
import 'package:oluko_app/models/submodels/enrollment_segment.dart';
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

  void getAll(EnrollmentClass classObj) async {
    emit(LoadingSegment());
    try {
      List<Segment> segments = await SegmentRepository.getByClass(classObj);
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

  void getSegmentsInClass(EnrollmentClass classObj) async {
    emit(LoadingSegment());
    try {
      List<Segment> segments = await SegmentRepository.getAll();
      final List segmentIds = classObj.segments.map((segment) => segment.id).toList();
      List<Segment> retSegments = List<Segment>.filled(segmentIds.length, null);
      for (int i = 0; i < segments.length; i++) {
        int index = segmentIds.indexOf(segments[i].id);
        if (index > -1) {
          retSegments[index] = segments[i];
        }
      }
      emit(GetSegmentsSuccess(segments: retSegments));
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
