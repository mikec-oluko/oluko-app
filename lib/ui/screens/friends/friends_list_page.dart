import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oluko_app/blocs/auth_bloc.dart';
import 'package:oluko_app/blocs/course_enrollment/course_enrollment_list_bloc.dart';
import 'package:oluko_app/blocs/friends/favorite_friend_bloc.dart';
import 'package:oluko_app/blocs/friends/friend_bloc.dart';
import 'package:oluko_app/blocs/friends/friend_request_bloc.dart';
import 'package:oluko_app/blocs/friends/hi_five_received_bloc.dart';
import 'package:oluko_app/blocs/friends/hi_five_send_bloc.dart';
import 'package:oluko_app/blocs/story_list_bloc.dart';
import 'package:oluko_app/blocs/user_list_bloc.dart';
import 'package:oluko_app/blocs/user_progress_bloc.dart';
import 'package:oluko_app/blocs/user_progress_list_bloc.dart';
import 'package:oluko_app/blocs/user_progress_stream_bloc.dart';
import 'package:oluko_app/blocs/user_statistics_bloc.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/helpers/enum_collection.dart';
import 'package:oluko_app/helpers/privacy_options.dart';
import 'package:oluko_app/helpers/user_helper.dart';
import 'package:oluko_app/models/dto/user_progress.dart';
import 'package:oluko_app/models/submodels/friend_model.dart';
import 'package:oluko_app/models/user_response.dart';
import 'package:oluko_app/routes.dart';
import 'package:oluko_app/ui/components/chat_slider.dart';
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

import '../../../models/course_enrollment.dart';

class FriendsListPage extends StatefulWidget {
  final UserResponse currentUser;
  final String userImage;
  const FriendsListPage({this.userImage, @required this.currentUser});
  @override
  _FriendsListPageState createState() => _FriendsListPageState();
}

class _FriendsListPageState extends State<FriendsListPage> {
  List<UserResponse> _friendUsersList = [];
  List<UserResponse> _appUsersList = [];
  List<CourseEnrollment> _courseEnrollmentsList = [];
  Widget _chatSliderWidget = const SizedBox.shrink();
  Widget _friendUsersWidget = const SizedBox.shrink();
  Widget _appUsersWidget = const SizedBox.shrink();
  GetFriendsSuccess _friendState;
  List<FriendModel> _friends = [];
  final _viewScrollController = ScrollController();
  Map<String, UserProgress> _usersProgress = {};

  @override
  void dispose() {
    _viewScrollController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    BlocProvider.of<UserProgressListBloc>(context).get(widget.currentUser.id);
    BlocProvider.of<FriendBloc>(context).getFriendsByUserId(widget.currentUser.id);
    BlocProvider.of<CourseEnrollmentListBloc>(context).getCourseEnrollmentsByUser(widget.currentUser.id);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<UserProgressStreamBloc, UserProgressStreamState>(listener: (context, userProgressStreamState) {
      blocConsumerCondition(userProgressStreamState);
    }, builder: (context, userProgressListState) {
      return BlocConsumer<UserProgressListBloc, UserProgressListState>(listener: (context, userProgressListState) {
        if (userProgressListState is GetUserProgressSuccess) {
          setState(() {
            _usersProgress = userProgressListState.usersProgress;
          });
        }
      }, builder: (context, userProgressListState) {
        return BlocBuilder<UserListBloc, UserListState>(
          builder: (context, userListState) {
            return BlocBuilder<FriendBloc, FriendState>(
              builder: (context, friendState) {
                return BlocBuilder<CourseEnrollmentListBloc, CourseEnrollmentListState>(
                  builder: (context, enrollmentState) {
                    if (enrollmentState is CourseEnrollmentsByUserSuccess) {
                      _courseEnrollmentsList = enrollmentState.courseEnrollments;
                      _chatSliderWidget = ChatSlider(
                        courses: _courseEnrollmentsList,
                      );
                    }
                    if (friendState is GetFriendsSuccess) {
                      _friendState = friendState;
                      _friendUsersList = friendState.friendUsers;
                      _friends = friendState.friendData != null ? friendState.friendData.friends : [];
                      _friendUsersWidget = UserListComponent(
                        usersProgess: _usersProgress,
                        authUser: widget.currentUser,
                        users: _filterFriendUsers(isForFriends: true, friends: _friends, friendUsersList: _friendUsersList),
                        onTapUser: (UserResponse friendUser) => modalOnUserTap(friendUser),
                        onTopScroll: () => _viewScrollController.animateTo(0.0, duration: Duration(milliseconds: 500), curve: Curves.bounceOut),
                      );
                    }
                    if (userListState is UserListSuccess) {
                      _appUsersList = userListState.users;
                      _appUsersList.sort((a, b) => a.username.toString().toLowerCase().compareTo(b.username.toString().toLowerCase()));
                      _appUsersWidget = UserListComponent(
                        usersProgess: _usersProgress,
                        authUser: widget.currentUser,
                        users: _filterFriendUsers(isForFriends: false, users: _appUsersList, friendUsersList: _friendUsersList),
                        onTapUser: (UserResponse friendUser) => modalOnUserTap(friendUser),
                        onTopScroll: () => _viewScrollController.animateTo(0.0, duration: Duration(milliseconds: 500), curve: Curves.bounceOut),
                      );
                    }
                    if (friendState is FriendLoading || userListState is UserListLoading) {
                      _appUsersWidget = userListState is UserListLoading ? getLoaderWidget() : _appUsersWidget;
                      _friendUsersWidget = friendState is FriendLoading ? getLoaderWidget() : _friendUsersWidget;
                    }
                    if (friendState is FriendFailure || userListState is UserListFailure) {
                      _friendUsersWidget =
                          friendState is FriendFailure ? TitleBody('${OlukoLocalizations.get(context, 'noFriends')} your Friends') : _friendUsersWidget;
                      _appUsersWidget =
                          userListState is UserListFailure ? TitleBody('${OlukoLocalizations.get(context, 'noFriends')} the users') : _appUsersWidget;
                    }
                    return _scrollView();
                  },
                );
              },
            );
          },
        );
      });
    });
  }

  Widget _scrollView() {
    return SingleChildScrollView(
      controller: _viewScrollController,
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.zero,
      child: SizedBox(
          height: ScreenUtils.height(context),
          width: ScreenUtils.width(context),
          child: Column(
            children: [
              _listSection(
                  titleForSection: OlukoLocalizations.get(context, 'chats'),
                  content: _courseEnrollmentsList.isNotEmpty ? _chatSliderWidget : _chatSliderWidget,
                  listLength: _courseEnrollmentsList.length),
              _listSection(
                  titleForSection: OlukoLocalizations.get(context, 'myFriends'),
                  content: _friends.isNotEmpty ? Expanded(child: _friendUsersWidget) : _friendUsersWidget,
                  listLength: _friends.length),
              _listSection(
                  titleForSection: OlukoLocalizations.get(context, 'otherUsers'), content: Expanded(child: _appUsersWidget), listLength: _appUsersList.length),
            ],
          )),
    );
  }

  void blocConsumerCondition(UserProgressStreamState userProgressStreamState) {
    if (userProgressStreamState is UserProgressUpdate) {
      setState(() {
        _usersProgress[userProgressStreamState.obj.id] = userProgressStreamState.obj;
      });
    } else if (userProgressStreamState is UserProgressAdd) {
      setState(() {
        _usersProgress[userProgressStreamState.obj.id] = userProgressStreamState.obj;
      });
    } else if (userProgressStreamState is UserProgressRemove) {
      setState(() {
        _usersProgress[userProgressStreamState.obj.id].progress = 0;
      });
    }
  }

  Widget _listSection({@required String titleForSection, @required Widget content, @required int listLength}) {
    if (content != _chatSliderWidget) {
      return Flexible(
          flex: listLength >= 5 ? 5 : 2,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(20),
                child: Text(titleForSection, style: OlukoFonts.olukoBigFont()),
              ),
              content,
            ],
          ));
    } else {
      return SizedBox(
        height: 175,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Text( , style: OlukoFonts.olukoBigFont()),
            ),
            if (listLength > 0) Expanded(child: content) else content,
          ],
        ),
      );
    }
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
              (appUser.id != widget.currentUser.id &&
                  ((friendUsersList == null) || (friendUsersList.indexWhere((friend) => friend != null && friend.id == appUser.id) == -1))))
          .toList();
    }
  }

  modalOnUserTap(UserResponse friendUser) {
    BottomDialogUtils.showBottomDialog(
      content: OlukoNeumorphism.isNeumorphismDesign
          ? FriendModalContent(
              friendUser,
              widget.currentUser.id,
              _usersProgress,
              BlocProvider.of<FriendBloc>(context),
              BlocProvider.of<FriendRequestBloc>(context),
              BlocProvider.of<HiFiveSendBloc>(context),
              BlocProvider.of<HiFiveReceivedBloc>(context),
              BlocProvider.of<UserStatisticsBloc>(context),
              BlocProvider.of<FavoriteFriendBloc>(context),
              BlocProvider.of<UserProgressStreamBloc>(context))
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
              style: OlukoFonts.olukoBigFont(customColor: OlukoColors.primary, customFontWeight: FontWeight.w500),
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
                style: OlukoFonts.olukoMediumFont(customColor: OlukoColors.grayColor, customFontWeight: FontWeight.w300),
              ),
            ),
          ],
        ),
      ],
    );
  }

  handleFriendFavoriteState(FavoriteFriendState favoriteState) {
    if (favoriteState is FavoriteFriendSuccess) {
      BlocProvider.of<FriendBloc>(context).getFriendsByUserId(widget.currentUser.id);
      AppMessages.clearAndShowSnackbar(context, 'Friend updated.');
    } else if (favoriteState is FavoriteFriendFailure) {
      AppMessages.clearAndShowSnackbar(context, 'Error updating Friend.');
    }
  }

  Widget dialogContainer({BuildContext context, UserResponse user, FriendState friendState}) {
    bool connectionRequested = friendState is GetFriendsSuccess && friendState.friendData.friendRequestSent.map((f) => f.id).toList().indexOf(user.id) > -1;
    BlocProvider.of<HiFiveReceivedBloc>(context).get(context, widget.currentUser.id, user.id);
    BlocProvider.of<UserStatisticsBloc>(context).getUserStatistics(user.id);
    return BlocBuilder<FriendBloc, FriendState>(
      bloc: BlocProvider.of<FriendBloc>(context),
      builder: (friendContext, friendState) {
        connectionRequested = friendState is GetFriendsSuccess && friendState.friendData.friendRequestSent.map((f) => f.id).toList().indexOf(user.id) > -1;
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
                            imageUrl: user.getAvatarThumbnail(),
                            name: user.firstName,
                            lastname: user.lastName,
                          )
                        else
                          StoriesItem(
                            from: StoriesItemFrom.friendsModal,
                            bloc: BlocProvider.of<StoryListBloc>(context),
                            maxRadius: 40,
                            imageUrl: user.getAvatarThumbnail(),
                            name: user.firstName,
                            lastname: user.lastName,
                            getStories: true,
                            currentUserId: widget.currentUser.id,
                            itemUserId: user.id,
                          ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  user.getFullName(),
                                  textAlign: TextAlign.start,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: Colors.white),
                                ),
                                if (PrivacyOptions.getPrivacyValue(user.privacy) == SettingsPrivacyOptions.public)
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
                                            BlocProvider.of<HiFiveSendBloc>(context).set(context, widget.currentUser.id, user.id);
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
                                                BlocProvider.of<HiFiveReceivedBloc>(context).get(context, widget.currentUser.id, user.id);
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
                                  final FriendModel friendModel = friendState.friendData.friends.where((element) => element.id == user.id).first;
                                  if (friendState is GetFriendsSuccess && userIsFriend) {
                                    BlocProvider.of<FavoriteFriendBloc>(context).favoriteFriend(context, friendState.friendData, friendModel);
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
                                BlocProvider.of<FriendRequestBloc>(context).removeRequestSent(widget.currentUser.id, friendState.friendData, user.id);
                              }
                            },
                          )
                        else
                          OlukoOutlinedButton(
                            thinPadding: true,
                            title: userIsFriend ? OlukoLocalizations.of(context).find('remove') : OlukoLocalizations.of(context).find('connect'),
                            onPressed: () {
                              if (friendState is GetFriendsSuccess) {
                                userIsFriend
                                    ? BlocProvider.of<FriendBloc>(context).removeFriend(widget.currentUser.id, friendState.friendData, user.id)
                                    : BlocProvider.of<FriendRequestBloc>(context).sendRequestOfConnect(widget.currentUser.id, friendState.friendData, user.id);
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
