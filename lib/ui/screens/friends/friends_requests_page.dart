import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oluko_app/blocs/friends/confirm_friend_bloc.dart';
import 'package:oluko_app/blocs/friends/friend_bloc.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/models/friend_request_model.dart';
import 'package:oluko_app/models/user_response.dart';
import 'package:oluko_app/ui/components/friends_request_card.dart';
import 'package:oluko_app/ui/components/friends_suggestions_section.dart';
import 'package:oluko_app/ui/components/oluko_outlined_button.dart';
import 'package:oluko_app/utils/app_messages.dart';

class FriendsRequestPage extends StatefulWidget {
  @override
  _FriendsRequestPageState createState() => _FriendsRequestPageState();
}

class _FriendsRequestPageState extends State<FriendsRequestPage> {
  //TODO: Use from widget
  String hardcodedUserId = '4HPomzrecweLoCAuCSVvPATtwwr2';

  @override
  void initState() {
    BlocProvider.of<FriendBloc>(context)
        .getUserFriendsRequestByUserId(hardcodedUserId);
    super.initState();
  }

  List<UserResponse> friends = [];

  final List<String> userImages = [
    'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTrpM3UTTyyqIwGsPYB1gCDhfl3XVv0Cex2Lw&usqp=CAU',
    'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSlCzsqcGBluOOUtgQahXtISLTM3Wb2tkpsoeMqwurI2LEP6pCS0ZgCFLQGiv8BtfJ9p2A&usqp=CAU',
    'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSEMWzdlSputkYso9dJb4VY5VEWQunXGBJMgGys7BLC4MzPQp6yfLURe-9nEdGrcK6Jasc&usqp=CAU',
    'https://mdbcdn.b-cdn.net/img/Photos/Avatars/img%20%2820%29.jpg',
    'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRHNX4Bb1o5JWY91Db6I4jf_wmw24ajOdaOPgRCqFlnEnxcAlQ42pyWJxM9klp3E8JoT0k&usqp=CAU',
    'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTF-rBV5pmJhYA8QbjpPcx6s9SywnXGbvsaxWyFi47oDf9JuL4GruKBY5zl2tM4tdgYdQ0&usqp=CAU',
    'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRF1L_s4YJh7RHSIag8CxT0LTuJQo-XQnTJkVApDXar4b0A57U_TnAMrK_l4Fd_Nzp65Bg&usqp=CAU'
  ];
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        color: OlukoColors.black,
        child: BlocListener<ConfirmFriendBloc, ConfirmFriendState>(
          listenWhen: (previousState, currentState) =>
              currentState is ConfirmFriendSuccess,
          listener: (context, confirmFriendState) {
            BlocProvider.of<FriendBloc>(context)
                .getUserFriendsRequestByUserId(hardcodedUserId);
            AppMessages.showSnackbar(context, 'Friend added.');
          },
          child: Column(
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Column(
                  //     children: friends
                  //         .map((friend) => FriendRequestCard(
                  //               userData: friend,
                  //             ))
                  //         .toList()),
                  BlocBuilder<FriendBloc, FriendState>(
                      builder: (context, friendsRequestState) {
                    return friendsRequestState is GetFriendRequestsSuccess
                        ? Column(
                            children: friendsRequestState.friendRequestList
                                .map((UserResponse friend) => FriendRequestCard(
                                      friendUser: friend,
                                      onFriendConfirmation:
                                          (UserResponse friend) {
                                        FriendRequestModel friendRequestModel =
                                            friendsRequestState.friendData
                                                .friendRequestReceived
                                                .where((friendRequest) =>
                                                    friendRequest.id ==
                                                    friend.id)
                                                .toList()
                                                .first;
                                        BlocProvider.of<ConfirmFriendBloc>(
                                                context)
                                            .confirmFriend(
                                                context,
                                                friendsRequestState.friendData,
                                                friendRequestModel);
                                      },
                                    ))
                                .toList(),
                          )
                        : SizedBox();
                  })
                ],
              ),
              buildAllRequestButton(context),
              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: FriendSuggestionSection(
                  name: "Richard",
                  lastName: "McGregor",
                  userName: "Notorius",
                  imageUser: userImages[6],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Padding buildAllRequestButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: Container(
          width: MediaQuery.of(context).size.width,
          child: Row(
            children: [
              OlukoOutlinedButton(
                title: "See All Requests",
                onPressed: () {},
              ),
            ],
          )),
    );
  }
}
