import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oluko_app/blocs/auth_bloc.dart';
import 'package:oluko_app/blocs/friends/favorite_friend_bloc.dart';
import 'package:oluko_app/blocs/friends/friend_bloc.dart';
import 'package:oluko_app/blocs/friends/hi_five_received_bloc.dart';
import 'package:oluko_app/blocs/friends/hi_five_send_bloc.dart';
import 'package:oluko_app/blocs/user_list_bloc.dart';
import 'package:oluko_app/blocs/user_statistics_bloc.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/models/submodels/friend_model.dart';
import 'package:oluko_app/models/user_response.dart';
import 'package:oluko_app/routes.dart';
import 'package:oluko_app/ui/components/friends_card.dart';
import 'package:oluko_app/ui/components/oluko_circular_progress_indicator.dart';
import 'package:oluko_app/ui/components/oluko_outlined_button.dart';
import 'package:oluko_app/ui/components/oluko_primary_button.dart';
import 'package:oluko_app/ui/components/stories_item.dart';
import 'package:oluko_app/ui/components/title_body.dart';
import 'package:oluko_app/utils/app_messages.dart';
import 'package:oluko_app/utils/bottom_dialog_utils.dart';
import 'package:oluko_app/utils/oluko_localizations.dart';
import 'package:oluko_app/utils/user_utils.dart';

class FriendsListPage extends StatefulWidget {
  // final List<User> friends;
  // FriendsListPage({this.friends});
  final String userImage;
  FriendsListPage({this.userImage});
  @override
  _FriendsListPageState createState() => _FriendsListPageState();
}

class _FriendsListPageState extends State<FriendsListPage> {
  AuthSuccess _authStateData;
  UserListSuccess _userListSuccessData;

  @override
  void initState() {
    super.initState();
  }

  //TODO: Use from widget
  List<User> friends;
  final _title = "Starred";
  List<String> userImages = [
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
    return BlocBuilder<AuthBloc, AuthState>(builder: (context, authState) {
      if (authState is AuthSuccess && _authStateData == null) {
        _authStateData = authState;
        BlocProvider.of<FriendBloc>(context).getFriendsByUserId(authState.user.id);
      }
      return BlocListener<FavoriteFriendBloc, FavoriteFriendState>(
        listener: (favoriteFriendContext, favoriteState) {
          handleFriendFavoriteState(favoriteState);
        },
        child: Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // BlocListener<FriendBloc, FriendState>(
                //   listener: (context, state) {
                //     if (state is GetFriendsSuccess) {
                //       friends = state.friendUsers;
                //     }
                //   },
                //   child: Column(
                //       children: friends
                //           .map((friend) => FriendCard(
                //                 userData: friend,
                //               ))
                //           .toList()),
                // ),

                BlocBuilder<FriendBloc, FriendState>(builder: (context, friendState) {
                  return BlocBuilder<UserListBloc, UserListState>(builder: (userListContext, userListState) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 10),
                          child: Text('My Friends', style: OlukoFonts.olukoBigFont()),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16.0),
                          child: Column(
                            children: generateFriendList(friendState),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 10),
                          child: Text('Other users', style: OlukoFonts.olukoBigFont()),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16.0),
                          child: GridView.count(
                            childAspectRatio: 0.7,
                            crossAxisCount: 4,
                            physics: const NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            children: generateUsersList(friendState, userListState),
                          ),
                        )
                      ],
                    );
                  });
                }),
              ],
            ),
          ),
        ),
      );
    });
  }

  ///Manage friends retrieval state
  List<Widget> generateFriendList(FriendState friendState) {
    if (friendState is FriendLoading) {
      return [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: OlukoCircularProgressIndicator(),
        )
      ];
    } else if (friendState is FriendFailure) {
      return [TitleBody('There was an error retrieving your Friends')];
    } else if (friendState is GetFriendsSuccess) {
      if (friendState.friendData != null) {
        return friendState.friendData.friends.length == 0
            ? [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [TitleBody('No Friends.')]),
                )
              ]
            : [
                GridView.count(
                    childAspectRatio: 0.7,
                    crossAxisCount: 4,
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    children: friendState.friendData.friends.map((friend) {
                      UserResponse friendUser = friendState.friendUsers.where((fuser) => fuser.id == friend.id).first;
                      return GestureDetector(
                        onTap: () {
                          BottomDialogUtils.showBottomDialog(
                              content: dialogContainer(context: context, user: friendUser, friendState: friendState), context: context);
                        },
                        child: Column(
                          children: [
                            StoriesItem(
                              maxRadius: 30,
                              imageUrl: friendUser.avatar ?? UserUtils().defaultAvatarImageUrl,
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 8.0, bottom: 0.0),
                              child: Text(
                                '${friendUser.firstName} ${friendUser.lastName}',
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(color: Colors.white, fontSize: 13),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            Text(
                              friendUser.username ?? '',
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(color: Colors.grey, fontSize: 10),
                              textAlign: TextAlign.center,
                            )
                          ],
                        ),
                      );
                    }).toList())
              ];
      } else {
        return [];
      }
    } else {
      return [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: OlukoCircularProgressIndicator(),
        )
      ];
    }
  }

  List<Widget> generateUsersList(FriendState friendState, UserListState userListState) {
    if (!(userListState is UserListSuccess) && _userListSuccessData == null) {
      BlocProvider.of<UserListBloc>(context).get();
    }
    if (userListState is UserListSuccess) {
      _userListSuccessData = userListState;
    }
    if (friendState is FriendLoading) {
      return [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: OlukoCircularProgressIndicator(),
        )
      ];
    } else if (friendState is FriendFailure) {
      return [TitleBody('There was an error retrieving your Friends')];
    } else if (friendState is GetFriendsSuccess && userListState is UserListSuccess) {
      if (userListState.users != null) {
        return userListState.users.length == 0
            ? [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [TitleBody('No Friends.')]),
                )
              ]
            : userListState.users.where((e) => !friendState.friendUsers.map((fu) => fu.id).toList().contains(e.id)).map((user) {
                return GestureDetector(
                  onTap: () {
                    BottomDialogUtils.showBottomDialog(
                        content: dialogContainer(context: context, user: user, friendState: friendState), context: context);
                  },
                  child: Column(
                    children: [
                      StoriesItem(
                        maxRadius: 30,
                        imageUrl: user.avatar ?? UserUtils().defaultAvatarImageUrl,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0, bottom: 0.0),
                        child: Text(
                          '${user.firstName} ${user.lastName}',
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(color: Colors.white, fontSize: 13),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      Text(
                        user.username ?? '',
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: Colors.grey, fontSize: 10),
                        textAlign: TextAlign.center,
                      )
                    ],
                  ),
                );
              }).toList();
      } else {
        return [];
      }
    } else {
      return [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: OlukoCircularProgressIndicator(),
        )
      ];
    }
  }

  handleFriendFavoriteState(FavoriteFriendState favoriteState) {
    if (favoriteState is FavoriteFriendSuccess) {
      BlocProvider.of<FriendBloc>(context).getFriendsByUserId(_authStateData.user.id);
      AppMessages.showSnackbar(context, 'Friend updated.');
    } else if (favoriteState is FavoriteFriendFailure) {
      AppMessages.showSnackbar(context, 'Error updating Friend.');
    }
  }

  Widget dialogContainer({BuildContext context, UserResponse user, FriendState friendState}) {
    bool connectionRequested =
        friendState is GetFriendsSuccess && friendState.friendData.friendRequestSent.map((f) => f.id).toList().indexOf(user.id) > -1;

    return BlocBuilder<FriendBloc, FriendState>(
        bloc: BlocProvider.of<FriendBloc>(context),
        builder: (friendContext, friendState) {
          connectionRequested =
              friendState is GetFriendsSuccess && friendState.friendData.friendRequestSent.map((f) => f.id).toList().indexOf(user.id) > -1;
          bool userIsFriend = friendState is GetFriendsSuccess && friendState.friendUsers.map((e) => e.id).toList().contains(user.id);
          return Container(
              height: 350,
              decoration: BoxDecoration(
                  image: DecorationImage(
                image: AssetImage("assets/courses/dialog_background.png"),
                fit: BoxFit.cover,
              )),
              child: Stack(children: [
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(children: [
                    SizedBox(height: 30),
                    Row(
                      children: [
                        StoriesItem(maxRadius: 40, imageUrl: user.avatar),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              TitleBody(
                                '${user.firstName} ${user.lastName}',
                                bold: true,
                              ),
                              user.privacy == 0
                                  ? Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          user.username,
                                          style: TextStyle(color: Colors.grey, fontSize: 15),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(top: 8.0),
                                          child: Text('${user.city}, ${user.country}', style: TextStyle(color: Colors.grey, fontSize: 15)),
                                        )
                                      ],
                                    )
                                  : Padding(
                                      padding: const EdgeInsets.only(top: 8.0),
                                      child: Row(
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.only(right: 8.0),
                                            child: Container(height: 20, width: 20, child: Image.asset('assets/profile/lockedProfile.png')),
                                          ),
                                          Text(
                                            'Private profile',
                                            style: TextStyle(color: Colors.grey),
                                          ),
                                        ],
                                      ),
                                    ),
                            ],
                          ),
                        )
                      ],
                    ),
                    SizedBox(height: 20),
                    BlocBuilder<HiFiveReceivedBloc, HiFiveReceivedState>(
                        bloc: BlocProvider.of<HiFiveReceivedBloc>(context)..get(context, _authStateData.user.id, user.id),
                        builder: (hiFiveReceivedContext, hiFiveReceivedState) {
                          return BlocBuilder<UserStatisticsBloc, UserStatisticsState>(
                              bloc: BlocProvider.of(context)..getUserStatistics(user.id),
                              builder: (userStatisticsContext, userStats) {
                                return userStats is StatisticsSuccess && user.privacy == 0
                                    ? Row(
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.only(right: 16.0),
                                            child: GestureDetector(
                                                onTap: () {
                                                  BlocProvider.of<HiFiveSendBloc>(context).set(context, _authStateData.user.id, user.id);
                                                  AppMessages().showHiFiveSentDialog(context);
                                                },
                                                child: BlocListener<HiFiveSendBloc, HiFiveSendState>(
                                                  bloc: BlocProvider.of(context),
                                                  listener: (hiFiveSendContext, hiFiveSendState) {
                                                    if (hiFiveSendState is HiFiveSendSuccess) {
                                                      AppMessages.showSnackbar(
                                                          userStatisticsContext,
                                                          hiFiveSendState.hiFive
                                                              ? OlukoLocalizations.get(context, 'hiFiveSent')
                                                              : OlukoLocalizations.get(context, 'hiFiveRemoved'));
                                                    }
                                                    if (hiFiveSendState is HiFiveSendSuccess) {
                                                      BlocProvider.of<HiFiveReceivedBloc>(context).get(context, _authStateData.user.id, user.id);
                                                    }
                                                  },
                                                  child: Container(width: 80, height: 80, child: Image.asset('assets/profile/hiFive.png')),
                                                )),
                                          ),
                                          Row(
                                            children: [
                                              profileAccomplishments(
                                                  achievementTitle: 'Challenges completed',
                                                  achievementValue: userStats.userStats.completedChallenges.toString()),
                                              profileAccomplishments(
                                                  achievementTitle: 'Courses completed',
                                                  achievementValue: userStats.userStats.completedChallenges.toString()),
                                              profileAccomplishments(
                                                  achievementTitle: 'Courses completed',
                                                  achievementValue: userStats.userStats.completedCourses.toString()),
                                            ],
                                          )
                                        ],
                                      )
                                    : SizedBox();
                              });
                        }),
                    SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Visibility(
                          visible: friendState is GetFriendsSuccess && friendState.friendUsers.map((e) => e.id).toList().contains(user.id),
                          child: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: GestureDetector(
                              onTap: () {
                                if (friendState is GetFriendsSuccess) {
                                  bool userIsFriend = friendState.friendUsers.map((e) => e.id).toList().contains(user.id);
                                  FriendModel friendModel = friendState.friendData.friends.where((element) => element.id == user.id).first;
                                  if (friendState is GetFriendsSuccess && userIsFriend) {
                                    BlocProvider.of<FavoriteFriendBloc>(context).favoriteFriend(context, friendState.friendData, friendModel);
                                  }
                                }
                              },
                              child: Container(
                                height: 25,
                                width: 25,
                                child: Image.asset(
                                  friendState is GetFriendsSuccess &&
                                          friendState.friendData.friends.where((e) => e.id == user.id).toList().isNotEmpty &&
                                          friendState.friendData.friends.where((e) => e.id == user.id).toList()[0].isFavorite
                                      ? 'assets/icon/heart_filled.png'
                                      : 'assets/icon/heart.png',
                                ),
                              ),
                            ),
                          ),
                        ),
                        connectionRequested
                            ? OlukoPrimaryButton(
                                thinPadding: true,
                                title: 'Cancel',
                                onPressed: () {
                                  if (friendState is GetFriendsSuccess)
                                    BlocProvider.of<FriendBloc>(context).removeRequestSent(_authStateData.user.id, friendState.friendData, user.id);
                                },
                              )
                            : OlukoOutlinedButton(
                                thinPadding: true,
                                title: userIsFriend ? OlukoLocalizations.of(context).find('remove') : OlukoLocalizations.of(context).find('connect'),
                                onPressed: () {
                                  if (friendState is GetFriendsSuccess)
                                    userIsFriend
                                        ? BlocProvider.of<FriendBloc>(context).removeFriend(_authStateData.user.id, friendState.friendData, user.id)
                                        : BlocProvider.of<FriendBloc>(context)
                                            .sendRequestOfConnect(_authStateData.user.id, friendState.friendData, user.id);
                                }),
                        user.privacy == 0
                            ? Padding(
                                padding: const EdgeInsets.only(left: 10.0),
                                child: OlukoOutlinedButton(
                                  thinPadding: true,
                                  title: 'View full profile',
                                  onPressed: () {
                                    Navigator.pushNamed(context, routeLabels[RouteEnum.profileViewOwnProfile], arguments: {'userRequested': user});
                                  },
                                ),
                              )
                            : SizedBox()
                      ],
                    ),
                  ]),
                ),
                Align(
                    alignment: Alignment.topRight,
                    child: IconButton(icon: Icon(Icons.close, color: Colors.white), onPressed: () => Navigator.pop(context)))
              ]));
        });
  }

  Widget profileAccomplishments({String achievementTitle, String achievementValue}) {
    final double _textContainerWidth = 80;
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        //VALUE
        Column(
          children: [
            Text(
              achievementValue,
              style: OlukoFonts.olukoBigFont(customColor: OlukoColors.primary, custoFontWeight: FontWeight.w500),
            ),
          ],
        ),
        SizedBox(
          height: 5,
        ),
        //SUBTITLE
        Column(
          children: [
            Container(
              width: _textContainerWidth,
              child: Text(
                achievementTitle,
                style: OlukoFonts.olukoMediumFont(customColor: OlukoColors.grayColor, custoFontWeight: FontWeight.w300),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget usersGrid(List<UserResponse> users) {
    if (users.isNotEmpty) {
      return GridView.count(
          childAspectRatio: 0.7,
          crossAxisCount: 4,
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          children: users
              .map((user) => Column(
                    children: [
                      StoriesItem(
                        maxRadius: 30,
                        imageUrl: user.avatar ?? UserUtils().defaultAvatarImageUrl,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0, bottom: 0.0),
                        child: Text(
                          '${user.firstName} ${user.lastName}',
                          style: const TextStyle(color: Colors.white, fontSize: 13),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      Text(
                        user.username,
                        style: const TextStyle(color: Colors.grey, fontSize: 10),
                        textAlign: TextAlign.center,
                      )
                    ],
                  ))
              .toList());
    } else {
      return Padding(
        padding: const EdgeInsets.only(bottom: 20, top: 10),
        child: TitleBody(OlukoLocalizations.get(context, 'noUsers')),
      );
    }
  }
}
