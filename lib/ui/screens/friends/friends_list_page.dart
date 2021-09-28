import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oluko_app/blocs/auth_bloc.dart';
import 'package:oluko_app/blocs/friends/favorite_friend_bloc.dart';
import 'package:oluko_app/blocs/friends/friend_bloc.dart';
import 'package:oluko_app/blocs/user_list_bloc.dart';
import 'package:oluko_app/blocs/user_statistics_bloc.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/models/submodels/friend_model.dart';
import 'package:oluko_app/models/user_response.dart';
import 'package:oluko_app/ui/components/friends_card.dart';
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
        listener: (context, favoriteState) {
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
                  return BlocBuilder<UserListBloc, UserListState>(builder: (context, userListState) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 10),
                          child: Text('My Friends', style: OlukoFonts.olukoBigFont()),
                        ),
                        Column(children: generateFriendList(friendState).toList()),
                        Padding(
                          padding: const EdgeInsets.only(top: 10),
                          child: Text('Other users', style: OlukoFonts.olukoBigFont()),
                        ),
                        Column(
                          children: generateUsersList(friendState, userListState),
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
            : friendState.friendData.friends.map((friend) {
                UserResponse friendUser = friendState.friendUsers.where((fuser) => fuser.id == friend.id).first;
                return FriendCard(
                  friend: friend,
                  friendUser: friendUser,
                  onFavoriteToggle: (FriendModel friendModel) {
                    BlocProvider.of<FavoriteFriendBloc>(context).favoriteFriend(context, friendState.friendData, friendModel);
                  },
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
            : userListState.users.map((user) {
                return GestureDetector(
                  onTap: () {
                    BottomDialogUtils.showBottomDialog(content: dialogContainer(user: user), context: context);
                  },
                  child: FriendCard(
                    friend: null,
                    friendUser: user,
                    onFavoriteToggle: (FriendModel friendModel) {
                      BlocProvider.of<FavoriteFriendBloc>(context).favoriteFriend(context, friendState.friendData, friendModel);
                    },
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

  Widget dialogContainer({UserResponse user}) {
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
                        Text(
                          user.username,
                          style: TextStyle(color: Colors.grey, fontSize: 15),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text('${user.city}, ${user.country}', style: TextStyle(color: Colors.grey, fontSize: 15)),
                        )
                      ],
                    ),
                  )
                ],
              ),
              SizedBox(height: 20),
              BlocBuilder<UserStatisticsBloc, UserStatisticsState>(
                  bloc: BlocProvider.of(context)..getUserStatistics(user.id),
                  builder: (context, userStats) {
                    return userStats is StatisticsSuccess
                        ? Row(
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(right: 16.0),
                                child: Container(width: 80, height: 80, child: Image.asset('assets/profile/hiFive.png')),
                              ),
                              profileAccomplishments(
                                  achievementTitle: 'Challenges completed', achievementValue: userStats.userStats.completedChallenges.toString()),
                              profileAccomplishments(
                                  achievementTitle: 'Courses completed', achievementValue: userStats.userStats.completedChallenges.toString()),
                              profileAccomplishments(
                                  achievementTitle: 'Courses completed', achievementValue: userStats.userStats.completedCourses.toString()),
                            ],
                          )
                        : SizedBox();
                  }),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Container(
                      height: 25,
                      width: 25,
                      child: Image.asset(
                        'assets/icon/heart.png',
                      ),
                    ),
                  ),
                  OlukoOutlinedButton(
                    thinPadding: true,
                    title: OlukoLocalizations.of(context).find('connect'),
                    onPressed: () {
                      //navigateToSegmentWithoutRecording();
                    },
                  ),
                  SizedBox(width: 10),
                  OlukoPrimaryButton(
                    thinPadding: true,
                    title: 'View full profile',
                    onPressed: () {
                      // navigateToSegmentWithRecording();
                    },
                  )
                ],
              ),
            ]),
          ),
          Align(
              alignment: Alignment.topRight, child: IconButton(icon: Icon(Icons.close, color: Colors.white), onPressed: () => Navigator.pop(context)))
        ]));
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
}
