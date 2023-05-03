import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oluko_app/models/user_response.dart';
import 'package:oluko_app/models/utils/weight_helper.dart';
import 'package:oluko_app/models/weight_record.dart';
import 'package:oluko_app/repositories/course_enrollment_repository.dart';
import 'package:oluko_app/repositories/movement_repository.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

abstract class FriendWeightRecordState {}

class Loading extends FriendWeightRecordState {}

class FriendsWeightRecordsSuccess extends FriendWeightRecordState {
  // final Map<UserResponse, List<WeightRecord>> records;
  Map<String, List<WeightRecord>> records = {};

  FriendsWeightRecordsSuccess({this.records});
}

class Failure extends FriendWeightRecordState {
  final dynamic exception;

  Failure({this.exception});
}

class FriendsWeightRecordsBloc extends Cubit<FriendWeightRecordState> {
  FriendsWeightRecordsBloc() : super(Loading());

  StreamSubscription<QuerySnapshot<Map<String, dynamic>>> subscription;

  @override
  void dispose() {
    if (subscription != null) {
      subscription.cancel();
      subscription = null;
    }
  }

  getFriendsWeightRecords({
    List<UserResponse> friendsList,
  }) async {
    // Map<UserResponse, List<WeightRecord>> movementsWeights = {};
    Map<String, List<WeightRecord>> movementsWeights = {};
      // if (friendsList.isNotEmpty) {
        movementsWeights = await MovementRepository.getUsersRecords(friendsList.map((e) => e.id).toList());
        if (movementsWeights.isNotEmpty) {
          emit(FriendsWeightRecordsSuccess(records: movementsWeights));
        }
      // }
  }
}
