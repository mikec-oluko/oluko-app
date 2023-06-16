import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oluko_app/models/user_response.dart';
import 'package:oluko_app/models/weight_record.dart';
import 'package:oluko_app/repositories/weight_record_repository.dart';
import 'package:oluko_app/services/weight_record_service.dart';

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

  void getFriendsWeight({List<UserResponse> friends}) async {
    final Map<UserResponse, List<WeightRecord>> friendsRecords = await WeightRecordService.getFriendsWeight(friends);
    emit(FriendsWeightRecordsSuccess(records: friendsRecords));
  }
}
