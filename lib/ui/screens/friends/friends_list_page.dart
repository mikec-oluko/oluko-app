import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oluko_app/blocs/auth_bloc.dart';
import 'package:oluko_app/blocs/friends/favorite_friend_bloc.dart';
import 'package:oluko_app/blocs/friends/friend_bloc.dart';
import 'package:oluko_app/blocs/friends/friend_request_bloc.dart';
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
import 'package:oluko_app/ui/components/users_list_component.dart';
import 'package:oluko_app/ui/components/friend_modal_content.dart';
import 'package:oluko_app/ui/components/oluko_circular_progress_indicator.dart';
import 'package:oluko_app/ui/components/oluko_outlined_button.dart';
import 'package:oluko_app/ui/components/oluko_primary_button.dart';
import 'package:oluko_app/ui/components/stories_item.dart';
import 'package:oluko_app/ui/components/title_body.dart';
import 'package:oluko_app/utils/app_messages.dart';
import 'package:oluko_app/utils/bottom_dialog_utils.dart';
import 'package:oluko_app/utils/oluko_localizations.dart';
import 'package:oluko_app/utils/screen_utils.dart';

class FriendsListPage extends StatefulWidget {
  final AuthSuccess authUser;
  final String userImage;
  const FriendsListPage({this.userImage, @required this.authUser});
  @override
  _FriendsListPageState createState() => _FriendsListPageState();
}

class _FriendsListPageState extends State<FriendsListPage> {
  List<UserResponse> _friendUsersList = [];
  List<UserResponse> _appUsersList = [];
  Widget _friendUsersWidget = const SizedBox.shrink();
  Widget _appUsersWidget = const SizedBox.shrink();
  GetFriendsSuccess _friendState;
  List<FriendModel> _friends = [];
  final _title = 'Starred';
  final _viewScrollController = ScrollController();

  @override
  void dispose() {
    _viewScrollController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UserListBloc, UserListState>(
      builder: (context, userListState) {
        return BlocBuilder<FriendBloc, FriendState>(
          builder: (context, friendState) {
            if (friendState is GetFriendsSuccess) {
              _friendState = friendState;
              _friendUsersList = friendState.friendUsers;
              _friends = friendState.friendData != null ? friendState.friendData.friends : [];
              _friendUsersWidget = UserListComponent(
                authUser: widget.authUser,
                users: _filterFriendUsers(isForFriends: true, friends: _friends, friendUsersList: _friendUsersList),
                onTapUser: (UserResponse friendUser) => modalOnUserTap(friendUser),
                onTopScroll: () => _viewScrollController.animateTo(0.0, duration: Duration(seconds: 1), curve: Curves.ease),
              );
            }
            if (userListState is UserListSuccess) {
              _appUsersList = userListState.users;
              _appUsersWidget = UserListComponent(
                authUser: widget.authUser,
                users: _filterFriendUsers(isForFriends: false, users: _appUsersList, friendUsersList: _friendUsersList),
                onTapUser: (UserResponse friendUser) => modalOnUserTap(friendUser),
                onTopScroll: () => _viewScrollController.animateTo(0.0, duration: Duration(seconds: 1), curve: Curves.ease),
              );
            }
            if (friendState is FriendLoading || userListState is UserListLoading) {
              _appUsersWidget = userListState is UserListLoading ? getLoaderWidget() : _appUsersWidget;
              _friendUsersWidget = friendState is FriendLoading ? getLoaderWidget() : _friendUsersWidget;
            }
            if (friendState is FriendFailure || userListState is UserListFailure) {
              _friendUsersWidget = friendState is FriendFailure
                  ? TitleBody('${OlukoLocalizations.get(context, 'noFriends')} your Friends')
                  : _friendUsersWidget;
              _appUsersWidget = userListState is UserListFailure
                  ? TitleBody('${OlukoLocalizations.get(context, 'noFriends')} the users')
                  : _appUsersWidget;
            }
            return SingleChildScrollView(
              controller: _viewScrollController,
              padding: EdgeInsets.zero,
              child: SizedBox(
                  height: ScreenUtils.height(context),
                  width: ScreenUtils.width(context),
                  child: Column(
                    children: [
                      _listSection(
                          titleForSection: OlukoLocalizations.get(context, 'myFriends'),
                          content: _friendUsersWidget,
                          listLength: _friends.length),
                      _listSection(
                          titleForSection: OlukoLocalizations.get(context, 'otherUsers'),
                          content: _appUsersWidget,
                          listLength: _appUsersList.length),
                    ],
                  )),
            );
          },
        );
      },
    );
  }

  Widget _listSection({@required String titleForSection, @required Widget content, @required int listLength}) {
    return Flexible(
        flex: listLength >= 5 ? 5 : 2,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
              child: Text(titleForSection, style: OlukoFonts.olukoBigFont()),
            ),
            Expanded(child: content),
          ],
        ));
  }

  Padding getLoaderWidget() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: OlukoCircularProgressIndicator(),
    );
  }

  List<UserResponse> _filterFriendUsers(
      {@required bool isForFriends, List<FriendModel> friends, List<UserResponse> friendUsersList, List<UserResponse> users}) {
    List<UserResponse> _friendsUsers = [];
    List<UserResponse> _appUsers = [];
    if (isForFriends) {
      friends.forEach((friend) {
        UserResponse friendUser = friendUsersList
            .where(
              (friendUser) => friendUser != null && friendUser?.id == friend.id,
            )
            .first;
        friendUser != null ? _friendsUsers.add(friendUser) : null;
      });
      return _friendsUsers;
    } else {
      return _appUsers = users
          .where((appUser) =>
              appUser.privacy != 2 &&
              (appUser.id != widget.authUser.user.id &&
                  ((friendUsersList == null) || (friendUsersList.indexWhere((friend) => friend != null && friend.id == appUser.id) == -1))))
          .toList();
    }
  }

  modalOnUserTap(UserResponse friendUser) {
    BottomDialogUtils.showBottomDialog(
      content: OlukoNeumorphism.isNeumorphismDesign
          ? FriendModalContent(
              friendUser,
              widget.authUser.user.id,
              FriendBloc(),
              FriendRequestBloc(),
              HiFiveSendBloc(),
              HiFiveReceivedBloc(),
              UserStatisticsBloc(),
              FavoriteFriendBloc(),
            )
          : dialogContainer(context: context, user: friendUser, friendState: _friendState),
      context: context,
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

  handleFriendFavoriteState(FavoriteFriendState favoriteState) {
    if (favoriteState is FavoriteFriendSuccess) {
      BlocProvider.of<FriendBloc>(context).getFriendsByUserId(widget.authUser.user.id);
      AppMessages.clearAndShowSnackbar(context, 'Friend updated.');
    } else if (favoriteState is FavoriteFriendFailure) {
      AppMessages.clearAndShowSnackbar(context, 'Error updating Friend.');
    }
  }

  Widget dialogContainer({BuildContext context, UserResponse user, FriendState friendState}) {
    bool connectionRequested =
        friendState is GetFriendsSuccess && friendState.friendData.friendRequestSent.map((f) => f.id).toList().indexOf(user.id) > -1;
    BlocProvider.of<HiFiveReceivedBloc>(context).get(context, widget.authUser.user.id, user.id);
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
            ),
          ),
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  children: [
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
                            currentUserId: widget.authUser.user.id,
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
                                        child: Text(
                                          '${user.city ?? ''}, ${user.country ?? ''}',
                                          style: const TextStyle(color: Colors.grey, fontSize: 15),
                                        ),
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
                                            BlocProvider.of<HiFiveSendBloc>(context).set(context, widget.authUser.user.id, user.id);
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
                                                      : OlukoLocalizations.get(context, 'hiFiveRemoved'),
                                                );
                                              }
                                              if (hiFiveSendState is HiFiveSendSuccess) {
                                                BlocProvider.of<HiFiveReceivedBloc>(context).get(context, widget.authUser.user.id, user.id);
                                              }
                                            },
                                            child: SizedBox(width: 80, height: 80, child: Image.asset('assets/profile/hiFive.png')),
                                          ),
                                        ),
                                      ),
                                      Row(
                                        children: [
                                          profileAccomplishments(
                                            achievementTitle: OlukoLocalizations.get(context, 'challengesCompleted'),
                                            achievementValue: userStats.userStats.completedChallenges.toString(),
                                          ),
                                          profileAccomplishments(
                                            achievementTitle: OlukoLocalizations.get(context, 'coursesCompleted'),
                                            achievementValue: userStats.userStats.completedCourses.toString(),
                                          ),
                                          profileAccomplishments(
                                            achievementTitle: OlukoLocalizations.get(context, 'classesCompleted'),
                                            achievementValue: userStats.userStats.completedClasses.toString(),
                                          ),
                                        ],
                                      )
                                    ],
                                  )
                                : const SizedBox();
                          },
                        );
                      },
                    ),
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
                                  final FriendModel friendModel =
                                      friendState.friendData.friends.where((element) => element.id == user.id).first;
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
                        if (connectionRequested)
                          OlukoPrimaryButton(
                            thinPadding: true,
                            title: OlukoLocalizations.of(context).find('cancel'),
                            onPressed: () {
                              if (friendState is GetFriendsSuccess) {
                                BlocProvider.of<FriendRequestBloc>(context)
                                    .removeRequestSent(widget.authUser.user.id, friendState.friendData, user.id);
                              }
                            },
                          )
                        else
                          OlukoOutlinedButton(
                            thinPadding: true,
                            title: userIsFriend
                                ? OlukoLocalizations.of(context).find('remove')
                                : OlukoLocalizations.of(context).find('connect'),
                            onPressed: () {
                              if (friendState is GetFriendsSuccess) {
                                userIsFriend
                                    ? BlocProvider.of<FriendBloc>(context)
                                        .removeFriend(widget.authUser.user.id, friendState.friendData, user.id)
                                    : BlocProvider.of<FriendRequestBloc>(context)
                                        .sendRequestOfConnect(widget.authUser.user.id, friendState.friendData, user.id);
                              }
                            },
                          ),
                        if (user.privacy == 0)
                          const SizedBox(
                            width: 10,
                          )
                        else
                          const SizedBox(),
                        if (user.privacy == 0)
                          OlukoOutlinedButton(
                            thinPadding: true,
                            title: 'View full profile',
                            onPressed: () {
                              Navigator.pushNamed(
                                context,
                                routeLabels[RouteEnum.profileViewOwnProfile],
                                arguments: {'userRequested': user, 'isFriend': userIsFriend},
                              );
                            },
                          )
                        else
                          const SizedBox()
                      ],
                    ),
                  ],
                ),
              ),
              Align(
                alignment: Alignment.topRight,
                child: IconButton(icon: const Icon(Icons.close, color: Colors.white), onPressed: () => Navigator.pop(context)),
              )
            ],
          ),
        );
      },
    );
  }
}
