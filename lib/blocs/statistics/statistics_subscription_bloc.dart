import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oluko_app/models/course_statistics.dart';
import 'package:oluko_app/repositories/course_repository.dart';

abstract class StatisticsSubscriptionState {}

class StatisticsSubscriptionLoading extends StatisticsSubscriptionState {}

class StatisticsSubscriptionSuccess extends StatisticsSubscriptionState {
  final List<CourseStatistics> courseStatistics;
  StatisticsSubscriptionSuccess({this.courseStatistics});
}

class StatisticsFailure extends StatisticsSubscriptionState {
  final dynamic exception;
  StatisticsFailure({this.exception});
}

class StatisticsSubscriptionBloc extends Cubit<StatisticsSubscriptionState> {
  StatisticsSubscriptionBloc() : super(StatisticsSubscriptionLoading());

  StreamSubscription<QuerySnapshot<Map<String, dynamic>>> subscription;
  @override
  void dispose() {
    if (subscription != null) {
      subscription.cancel();
      subscription = null;
    }
  }

  StreamSubscription<QuerySnapshot<Map<String, dynamic>>> getStream() {
    subscription ??= CourseRepository.getStatisticsSubscription().listen((snapshot) async {
      List<CourseStatistics> statistics = [];
      snapshot.docs.forEach((doc) {
        final Map<String, dynamic> content = doc.data();
        statistics.add(CourseStatistics.fromJson(content));
      });
      emit(StatisticsSubscriptionSuccess(courseStatistics: statistics));
    });
    return subscription;
  }
}
