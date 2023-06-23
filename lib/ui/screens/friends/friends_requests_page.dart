import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oluko_app/blocs/auth_bloc.dart';
import 'package:oluko_app/blocs/friends/confirm_friend_bloc.dart';
import 'package:oluko_app/blocs/friends/friend_bloc.dart';
import 'package:oluko_app/blocs/friends/friend_request_bloc.dart';
import 'package:oluko_app/blocs/friends/ignore_friend_request_bloc.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/models/submodels/friend_request_model.dart';
import 'package:oluko_app/models/user_response.dart';
import 'package:oluko_app/ui/components/friends_request_card.dart';
import 'package:oluko_app/ui/components/oluko_circular_progress_indicator.dart';
import 'package:oluko_app/ui/components/oluko_outlined_button.dart';
import 'package:oluko_app/ui/components/title_body.dart';
import 'package:oluko_app/utils/app_messages.dart';
import 'package:oluko_app/utils/oluko_localizations.dart';

class FriendsRequestPage extends StatefulWidget {
  final AuthSuccess authUser;
  const FriendsRequestPage({@required this.authUser});
  @override
  _FriendsRequestPageState createState() => _FriendsRequestPageState();
}

class _FriendsRequestPageState extends State<FriendsRequestPage> {
  //TODO: Use from widget
  num maxRequestsToShow = 5;

  @override
  void initState() {
    BlocProvider.of<FriendRequestBloc>(context).getUserFriendsRequestByUserId(widget.authUser.user.id);
    super.initState();
  }

  List<UserResponse> friends = [];
  bool disabledActions = false;

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
      physics: OlukoNeumorphism.listViewPhysicsEffect,
      child: Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          color: OlukoNeumorphism.isNeumorphismDesign ? OlukoNeumorphismColors.olukoNeumorphicBackgroundDark : OlukoColors.black,
          child: BlocListener<IgnoreFriendRequestBloc, IgnoreFriendRequestState>(
            listener: (context, ignoreFriendState) {
              if (ignoreFriendState is IgnoreFriendRequestSuccess) {
                BlocProvider.of<FriendRequestBloc>(context).getUserFriendsRequestByUserId(widget.authUser.user.id);
                AppMessages.clearAndShowSnackbar(context, OlukoLocalizations.get(context, 'friendRequestIgnored'));
              } else if (ignoreFriendState is IgnoreFriendRequestFailure) {
                AppMessages.clearAndShowSnackbar(context, OlukoLocalizations.get(context, 'ignoreFriendRequestError'));
              }
            },
            child: BlocListener<ConfirmFriendBloc, ConfirmFriendState>(
              listenWhen: (previousState, currentState) => currentState is ConfirmFriendSuccess,
              listener: (context, confirmFriendState) {
                disabledActions = false;
                if (confirmFriendState is ConfirmFriendSuccess) {
                  BlocProvider.of<FriendRequestBloc>(context).getUserFriendsRequestByUserId(widget.authUser.user.id);
                  AppMessages.clearAndShowSnackbar(context, OlukoLocalizations.get(context, 'friendAdded'));
                } else if (confirmFriendState is ConfirmFriendFailure) {
                  AppMessages.clearAndShowSnackbar(context, OlukoLocalizations.get(context, 'addFriendRequestError'));
                }
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
                      BlocBuilder<FriendRequestBloc, FriendRequestState>(builder: (context, friendsRequestState) {
                        return Column(
                          children: generateFriendRequestsList(friendsRequestState),
                        );
                      })
                    ],
                  ),
                  // Padding(
                  //   padding: const EdgeInsets.only(top: 20),
                  //   child: FriendSuggestionSection(
                  //     name: "Richard",
                  //     lastName: "McGregor",
                  //     userName: "Notorius",
                  //     imageUser: userImages[6],
                  //   ),
                  // )
                ],
              ),
            ),
          )),
    );
    // });
  }

  Padding buildAllRequestButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: Container(
          width: MediaQuery.of(context).size.width,
          child: Row(
            children: [
              OlukoOutlinedButton(
                title: OlukoLocalizations.get(context, 'seeAllRequests'),
                onPressed: () {},
              ),
            ],
          )),
    );
  }

  List<Widget> generateFriendRequestsList(FriendRequestState friendsRequestState) {
    if (friendsRequestState is GetFriendRequestsSuccess) {
      return friendsRequestState.friendRequestList.length == 0
          ? [
              Padding(
                padding: const EdgeInsets.all(32.0),
                child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  TitleBody(
                    OlukoLocalizations.of(context).find('noRequests'),
                    customColor: OlukoColors.grayColor,
                  )
                ]),
              )
            ]
          : friendsRequestState.friendRequestList
                  .map<Widget>((UserResponse friend) => FriendRequestCard(
                        friendUser: friend,
                        onFriendRequestIgnore: (UserResponse friend) {
                          FriendRequestModel friendRequestModel =
                              friendsRequestState.friendData.friendRequestReceived.where((friendRequest) => friendRequest.id == friend.id).toList().first;
                          BlocProvider.of<IgnoreFriendRequestBloc>(context).ignoreFriend(context, friendsRequestState.friendData, friendRequestModel);
                        },
                        onFriendConfirmation: (UserResponse friend) {
                          if (disabledActions) {
                            return;
                          }
                          disabledActions = true;
                          AppMessages().showDialogActionMessage(context, OlukoLocalizations.of(context).find(''), 2);
                          FriendRequestModel friendRequestModel =
                              friendsRequestState.friendData.friendRequestReceived.where((friendRequest) => friendRequest.id == friend.id).toList().first;
                          BlocProvider.of<ConfirmFriendBloc>(context).confirmFriend(context, friendsRequestState.friendData, friendRequestModel);
                        },
                      ))
                  .toList() +
              (friendsRequestState.friendRequestList.length > (maxRequestsToShow as int) ? [buildAllRequestButton(context)] : []);
    } else if (friendsRequestState is FriendFailure) {
      return [TitleBody('There was an error retrieving your Friends')];
    } else if (friendsRequestState is FriendLoading) {
      return [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: OlukoCircularProgressIndicator(),
        )
      ];
    } else {
      return [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: OlukoCircularProgressIndicator(),
        )
      ];
    }
  }
}
