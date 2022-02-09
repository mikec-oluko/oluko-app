import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oluko_app/blocs/auth_bloc.dart';
import 'package:oluko_app/blocs/friends/favorite_friend_bloc.dart';
import 'package:oluko_app/blocs/friends/friend_bloc.dart';
import 'package:oluko_app/blocs/friends/hi_five_received_bloc.dart';
import 'package:oluko_app/blocs/friends/hi_five_send_bloc.dart';
import 'package:oluko_app/blocs/story_list_bloc.dart';
import 'package:oluko_app/blocs/user_list_bloc.dart';
import 'package:oluko_app/blocs/user_statistics_bloc.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/helpers/enum_collection.dart';
import 'package:oluko_app/helpers/user_helper.dart';
import 'package:oluko_app/models/submodels/friend_model.dart';
import 'package:oluko_app/models/user_response.dart';
import 'package:oluko_app/routes.dart';
import 'package:oluko_app/ui/components/friend_modal_content.dart';
import 'package:oluko_app/ui/components/oluko_circular_progress_indicator.dart';
import 'package:oluko_app/ui/components/oluko_outlined_button.dart';
import 'package:oluko_app/ui/components/oluko_primary_button.dart';
import 'package:oluko_app/ui/components/stories_item.dart';
import 'package:oluko_app/ui/components/title_body.dart';
import 'package:oluko_app/utils/app_messages.dart';
import 'package:oluko_app/utils/bottom_dialog_utils.dart';
import 'package:oluko_app/utils/oluko_localizations.dart';

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
  final _title = 'Starred';
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
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        if (authState is AuthSuccess && _authStateData == null) {
          _authStateData = authState;
          BlocProvider.of<FriendBloc>(context).getFriendsByUserId(authState.user.id);
        }
        if (OlukoNeumorphism.isNeumorphismDesign) {
          return _getContent();
        } else {
          return BlocListener<FavoriteFriendBloc, FavoriteFriendState>(
            listener: (favoriteFriendContext, favoriteState) {
              handleFriendFavoriteState(favoriteState);
            },
            child: _getContent(),
          );
        }
      },
    );
  }

  Widget _getContent() {
    return SizedBox(
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            BlocBuilder<FriendBloc, FriendState>(builder: (context, friendState) {
              return BlocBuilder<UserListBloc, UserListState>(builder: (userListContext, userListState) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Text(OlukoLocalizations.get(context, 'myFriends'), style: OlukoFonts.olukoBigFont()),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      child: Column(
                        children: generateFriendList(friendState),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Text(OlukoLocalizations.get(context, 'otherUsers'), style: OlukoFonts.olukoBigFont()),
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
              },);
            },),
          ],
        ),
      ),
    );
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
      return [TitleBody('${OlukoLocalizations.get(context, 'noFriends')} your Friends')];
    } else if (friendState is GetFriendsSuccess) {
      if (friendState.friendData != null) {
        return friendState.friendData.friends.isEmpty
            ? [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [TitleBody(OlukoLocalizations.get(context, 'noFriends'))]),
                )
              ]
            : [
                GridView.count(
                    padding: EdgeInsets.zero,
                    childAspectRatio: 0.7,
                    crossAxisCount: 4,
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    children: friendState.friendData.friends.map((friend) {
                      final UserResponse friendUser = friendState.friendUsers.where((fuser) => fuser.id == friend.id).first;
                      return GestureDetector(
                        onTap: () {
                          modalOnUserTap(friendUser, friendState);
                        },
                        child: Column(
                          children: [
                            StoriesItem(
                              maxRadius: 30,
                              imageUrl: friendUser.avatarThumbnail,
                              name: friendUser.firstName,
                              lastname: friendUser.lastName,
                              currentUserId: _authStateData.user.id,
                              itemUserId: friendUser.id,
                              addUnseenStoriesRing: true,
                              bloc: StoryListBloc(),
                              from: StoriesItemFrom.friends,
                            ),
                            printName(friendUser),
                            printUsername(friendUser)
                          ],
                        ),
                      );
                    }).toList(),)
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

  modalOnUserTap(UserResponse friendUser, GetFriendsSuccess friendState) {
    BottomDialogUtils.showBottomDialog(
                            content: OlukoNeumorphism.isNeumorphismDesign
                                ? FriendModalContent(friendUser, _authStateData.user.id, FriendBloc(), HiFiveSendBloc(),
                                    HiFiveReceivedBloc(), UserStatisticsBloc(), FavoriteFriendBloc(),)
                                : dialogContainer(context: context, user: friendUser, friendState: friendState),
                            context: context,);
  }

  Text printUsername(UserResponse friendUser) {
    return Text(
      UserHelper.printUsername(friendUser.username, friendUser.id) ?? '',
      overflow: TextOverflow.ellipsis,
      style: const TextStyle(color: Colors.grey, fontSize: 10),
      textAlign: TextAlign.center,
    );
  }

  List<Widget> generateUsersList(FriendState friendState, UserListState userListState) {
    if (userListState is! UserListSuccess && _userListSuccessData == null) {
      BlocProvider.of<UserListBloc>(context).get();
    }
    if (userListState is UserListSuccess) {
      _userListSuccessData = userListState;
    }
    if (friendState is FriendLoading || userListState is UserListLoading) {
      return [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: OlukoCircularProgressIndicator(),
        )
      ];
    } else if (userListState is UserListFailure) {
      return [TitleBody('${OlukoLocalizations.get(context, 'noFriends')} the users')];
    } else if (friendState is GetFriendsSuccess && userListState is UserListSuccess) {
      if (userListState.users != null) {
        return userListState.users.isEmpty
            ? [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [TitleBody(OlukoLocalizations.get(context, 'noUsers'))]),
                )
              ]
            : userListState.users
                .where(
                (e) =>
                    e.privacy != 2 && (e.id != _authStateData.user.id && ((friendState.friendUsers == null) ||
                    (friendState.friendUsers.indexWhere((friend) => friend.id == e.id) == -1))),
              )
                .map((user) {
                return GestureDetector(
                  onTap: () {
                    modalOnUserTap(user, friendState);
                  },
                  child: Column(
                    children: [
                      StoriesItem(maxRadius: 30, imageUrl: user.avatarThumbnail, name: user.firstName, lastname: user.lastName),
                      printName(user),
                      printUsername(user)
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

  Padding printName(UserResponse user) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Text(
        '${user.firstName} ${user.lastName}',
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(color: Colors.white, fontSize: 13),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget profileAccomplishments({String achievementTitle, String achievementValue}) {
    const double _textContainerWidth = 80;
    return Column(
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
        const SizedBox(
          height: 5,
        ),
        //SUBTITLE
        Column(
          children: [
            SizedBox(
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
                        imageUrl: user.avatar,
                        name: user.firstName,
                        lastname: user.lastName,
                      ),
                      printName(user),
                      printUsername(user),
                    ],
                  ),)
              .toList(),);
    } else {
      return Padding(
        padding: const EdgeInsets.only(bottom: 20, top: 10),
        child: TitleBody(OlukoLocalizations.get(context, 'noUsers')),
      );
    }
  }

  handleFriendFavoriteState(FavoriteFriendState favoriteState) {
    if (favoriteState is FavoriteFriendSuccess) {
      BlocProvider.of<FriendBloc>(context).getFriendsByUserId(_authStateData.user.id);
      AppMessages.clearAndShowSnackbar(context, 'Friend updated.');
    } else if (favoriteState is FavoriteFriendFailure) {
      AppMessages.clearAndShowSnackbar(context, 'Error updating Friend.');
    }
  }

  Widget dialogContainer({BuildContext context, UserResponse user, FriendState friendState}) {
    bool connectionRequested =
        friendState is GetFriendsSuccess && friendState.friendData.friendRequestSent.map((f) => f.id).toList().indexOf(user.id) > -1;
    BlocProvider.of<HiFiveReceivedBloc>(context).get(context, _authStateData.user.id, user.id);
    BlocProvider.of<UserStatisticsBloc>(context).getUserStatistics(user.id);
    return BlocBuilder<FriendBloc, FriendState>(
        bloc: BlocProvider.of<FriendBloc>(context),
        builder: (friendContext, friendState) {
          connectionRequested =
              friendState is GetFriendsSuccess && friendState.friendData.friendRequestSent.map((f) => f.id).toList().indexOf(user.id) > -1;
          final bool userIsFriend = friendState is GetFriendsSuccess && friendState.friendUsers.map((e) => e.id).toList().contains(user.id);
          return Container(
              height: 350,
              decoration: const BoxDecoration(
                  image: DecorationImage(
                image: AssetImage('assets/courses/dialog_background.png'),
                fit: BoxFit.cover,
              ),),
              child: Stack(children: [
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(children: [
                    const SizedBox(height: 30),
                    Row(
                      children: [
                        if (!userIsFriend)
                          StoriesItem(
                            maxRadius: 40,
                            imageUrl: user.avatarThumbnail,
                            name: user.firstName,
                            lastname: user.lastName,
                          )
                        else
                          StoriesItem(
                            from: StoriesItemFrom.friendsModal,
                            bloc: StoryListBloc(),
                            maxRadius: 40,
                            imageUrl: user.avatarThumbnail,
                            name: user.firstName,
                            lastname: user.lastName,
                            getStories: true,
                            currentUserId: _authStateData.user.id,
                            itemUserId: user.id,
                          ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${user.firstName} ${user.lastName}',
                                  textAlign: TextAlign.start,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: Colors.white),
                                ),
                                if (user.privacy == 0)
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        UserHelper.printUsername(user.username, user.id),
                                        style: const TextStyle(color: Colors.grey, fontSize: 15),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(top: 8.0),
                                        child: Text('${user.city ?? ''}, ${user.country ?? ''}',
                                            style: const TextStyle(color: Colors.grey, fontSize: 15),),
                                      )
                                    ],
                                  )
                                else
                                  Padding(
                                    padding: const EdgeInsets.only(top: 8.0),
                                    child: Row(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.only(right: 8.0),
                                          child: SizedBox(height: 20, width: 20, child: Image.asset('assets/profile/lockedProfile.png')),
                                        ),
                                        Text(
                                         OlukoLocalizations.get(context, 'privateProfile'),
                                          style: const TextStyle(color: Colors.grey),
                                        ),
                                      ],
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        )
                      ],
                    ),
                    const SizedBox(height: 20),
                    BlocBuilder<HiFiveReceivedBloc, HiFiveReceivedState>(
                        bloc: BlocProvider.of<HiFiveReceivedBloc>(context),
                        builder: (hiFiveReceivedContext, hiFiveReceivedState) {
                          return BlocBuilder<UserStatisticsBloc, UserStatisticsState>(
                              bloc: BlocProvider.of(context),
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
                                                      AppMessages.clearAndShowSnackbar(
                                                          userStatisticsContext,
                                                          hiFiveSendState.hiFive
                                                              ? OlukoLocalizations.get(context, 'hiFiveSent')
                                                              : OlukoLocalizations.get(context, 'hiFiveRemoved'),);
                                                    }
                                                    if (hiFiveSendState is HiFiveSendSuccess) {
                                                      BlocProvider.of<HiFiveReceivedBloc>(context)
                                                          .get(context, _authStateData.user.id, user.id);
                                                    }
                                                  },
                                                  child: SizedBox(width: 80, height: 80, child: Image.asset('assets/profile/hiFive.png')),
                                                ),),
                                          ),
                                          Row(
                                            children: [
                                              profileAccomplishments(
                                                  achievementTitle: OlukoLocalizations.get(context, 'challengesCompleted'),
                                                  achievementValue: userStats.userStats.completedChallenges.toString(),),
                                              profileAccomplishments(
                                                  achievementTitle: OlukoLocalizations.get(context, 'coursesCompleted'),
                                                  achievementValue: userStats.userStats.completedCourses.toString(),),
                                              profileAccomplishments(
                                                  achievementTitle: OlukoLocalizations.get(context, 'classesCompleted'),
                                                  achievementValue: userStats.userStats.completedClasses.toString(),),
                                            ],
                                          )
                                        ],
                                      )
                                    : const SizedBox();
                              },);
                        },),
                    const SizedBox(height: 20),
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
                                  final bool userIsFriend = friendState.friendUsers.map((e) => e.id).toList().contains(user.id);
                                  final FriendModel friendModel = friendState.friendData.friends.where((element) => element.id == user.id).first;
                                  if (friendState is GetFriendsSuccess && userIsFriend) {
                                    BlocProvider.of<FavoriteFriendBloc>(context)
                                        .favoriteFriend(context, friendState.friendData, friendModel);
                                  }
                                }
                              },
                              child: SizedBox(
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
                        if (connectionRequested) OlukoPrimaryButton(
                                thinPadding: true,
                                title: OlukoLocalizations.of(context).find('cancel'),
                                onPressed: () {
                                  if (friendState is GetFriendsSuccess) {
                                    BlocProvider.of<FriendBloc>(context)
                                        .removeRequestSent(_authStateData.user.id, friendState.friendData, user.id);
                                  }
                                },
                              ) else OlukoOutlinedButton(
                                thinPadding: true,
                                title: userIsFriend
                                    ? OlukoLocalizations.of(context).find('remove')
                                    : OlukoLocalizations.of(context).find('connect'),
                                onPressed: () {
                                  if (friendState is GetFriendsSuccess) {
                                    userIsFriend
                                        ? BlocProvider.of<FriendBloc>(context)
                                            .removeFriend(_authStateData.user.id, friendState.friendData, user.id)
                                        : BlocProvider.of<FriendBloc>(context)
                                            .sendRequestOfConnect(_authStateData.user.id, friendState.friendData, user.id);
                                  }
                                },),
                        if (user.privacy == 0) const SizedBox(
                                width: 10,
                              ) else const SizedBox(),
                        if (user.privacy == 0) OlukoOutlinedButton(
                                thinPadding: true,
                                title: 'View full profile',
                                onPressed: () {
                                  Navigator.pushNamed(context, routeLabels[RouteEnum.profileViewOwnProfile],
                                      arguments: {'userRequested': user, 'isFriend': userIsFriend},);
                                },
                              ) else const SizedBox()
                      ],
                    ),
                  ],),
                ),
                Align(
                    alignment: Alignment.topRight,
                    child: IconButton(icon: const Icon(Icons.close, color: Colors.white), onPressed: () => Navigator.pop(context)),)
              ],),);
        },);
  }
}
