import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oluko_app/models/course.dart';
import 'package:oluko_app/models/course_statistics.dart';
import 'package:oluko_app/repositories/course_repository.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

abstract class StatisticsState {}

class StatisticsLoading extends StatisticsState {}

class StatisticsSuccess extends StatisticsState {
  final CourseStatistics courseStatistics;
  StatisticsSuccess({this.courseStatistics});
}

class StatisticsFailure extends StatisticsState {
  final dynamic exception;
  StatisticsFailure({this.exception});
}

class StatisticsBloc extends Cubit<StatisticsState> {
  StatisticsBloc() : super(StatisticsLoading());

  String currentCourseId;
  Map<String, StreamSubscription<QuerySnapshot<Map<String, dynamic>>>> statisticsSubscriptions = {};
  //StreamSubscription<QuerySnapshot<Map<String, dynamic>>> subscription;
  @override
  void dispose() {
    statisticsSubscriptions.forEach((id, subscription) {
      if (subscription != null) {
        subscription.cancel();
        subscription = null;
      }
    });
  }

  void get(DocumentReference reference) async {
    if (!(state is StatisticsSuccess)) {
      emit(StatisticsLoading());
    }
    try {
      CourseStatistics courseStatistics = await CourseRepository.getStatistics(reference);
      emit(StatisticsSuccess(courseStatistics: courseStatistics));
    } catch (e, stackTrace) {
      await Sentry.captureException(
        e,
        stackTrace: stackTrace,
      );
      print(e.toString());
      emit(StatisticsFailure(exception: e));
      rethrow;
    }
  }

  StreamSubscription<QuerySnapshot<Map<String, dynamic>>> getStream(String courseId, DocumentReference statisticsReference) {
    currentCourseId = courseId;
    CourseStatistics statistics;

    statisticsSubscriptions.putIfAbsent(courseId, () => null);

    statisticsSubscriptions[courseId] ??=
        CourseRepository.getStatisticsSubscription(courseId, statisticsReference).listen((snapshot) async {
      if (snapshot.docs.isNotEmpty) {
        final Map<String, dynamic> content = snapshot.docs[0].data();
        statistics = CourseStatistics.fromJson(content);
      }
    });
    if (statistics != null && statistics.courseId == currentCourseId) {
      emit(StatisticsSuccess(courseStatistics: statistics));
    }
    return statisticsSubscriptions[currentCourseId];
  }
}
