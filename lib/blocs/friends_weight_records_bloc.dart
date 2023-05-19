import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oluko_app/models/user_response.dart';
import 'package:oluko_app/models/utils/weight_helper.dart';
import 'package:oluko_app/models/weight_record.dart';
import 'package:oluko_app/repositories/course_enrollment_repository.dart';
import 'package:oluko_app/repositories/friend_repository.dart';
import 'package:oluko_app/repositories/movement_repository.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

import '../models/friend.dart';
import '../repositories/user_repository.dart';

abstract class FriendWeightRecordState {}

class Loading extends FriendWeightRecordState {}

class FriendsWeightRecordsSuccess extends FriendWeightRecordState {
  final Map<UserResponse, List<WeightRecord>> records;

  FriendsWeightRecordsSuccess({this.records});
}

class Failure extends FriendWeightRecordState {
  final dynamic exception;

  Failure({this.exception});
}

class FriendsWeightRecordsBloc extends Cubit<FriendWeightRecordState> {
  FriendsWeightRecordsBloc() : super(Loading());
  final MovementRepository _movementRepository = MovementRepository();

  void getFriendsWeight({String userId}) async {
    Friend friendData = await FriendRepository.getUserFriendsByUserId(userId);
    List<UserResponse> friendList;
    if (friendData != null) {
      friendList = await Future.wait(friendData.friends.map((friend) async => UserRepository().getById(friend.id)));
    }
    Map<UserResponse, List<WeightRecord>> friendResults = {};
    await Future.wait(friendList.map((friend) async {
      List<WeightRecord> recordsForFriend = await _movementRepository.getFriendsRecords(friend.id);
      friendResults[friend] = recordsForFriend;
    }));
    emit(FriendsWeightRecordsSuccess(records: friendResults));
  }
}
