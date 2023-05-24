import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oluko_app/models/course_chat.dart';
import 'package:oluko_app/models/course_enrollment.dart';
import 'package:oluko_app/models/friend.dart';
import 'package:oluko_app/models/message.dart';
import 'package:oluko_app/models/submodels/user_message_submodel.dart';
import 'package:oluko_app/models/user_response.dart';
import 'package:oluko_app/repositories/course_chat_repository.dart';
import 'package:oluko_app/repositories/friend_repository.dart';
import 'package:oluko_app/repositories/auth_repository.dart';

abstract class CommunityTabFriendNotificationState {}

class CommunityTabFriendNotificationLoading extends CommunityTabFriendNotificationState {}

class CommunityTabFriendsNotification extends CommunityTabFriendNotificationState {
  int friendNotificationQuantity;
  CommunityTabFriendsNotification({this.friendNotificationQuantity});
}

class Failure extends CommunityTabFriendNotificationState {
  final dynamic exception;
  Failure({this.exception});
}

class CommunityTabFriendNotificationBloc extends Cubit<CommunityTabFriendNotificationState> {
  CommunityTabFriendNotificationBloc() : super(CommunityTabFriendNotificationLoading());

  StreamSubscription _friendRequestSubscription;

   void listenFriendRequestByUserId({String userId}){
    try {
      userId ??= AuthRepository.getLoggedUser().uid;
      _friendRequestSubscription = FriendRepository().listenFriendRequestByUserId(userId).listen((snapshot) async {
          final Friend user = Friend.fromJson(snapshot.docs.first.data());
          emit(CommunityTabFriendsNotification(friendNotificationQuantity: user.friendRequestReceived.length));
      });
      
    } catch (e) {
      emit(Failure(exception: e));
    }
  }

}