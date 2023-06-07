import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oluko_app/blocs/auth_bloc.dart';
import 'package:oluko_app/blocs/friends/favorite_friend_bloc.dart';
import 'package:oluko_app/blocs/friends/friend_bloc.dart';
import 'package:oluko_app/blocs/friends/friend_request_bloc.dart';
import 'package:oluko_app/blocs/friends/hi_five_received_bloc.dart';
import 'package:oluko_app/blocs/friends/hi_five_send_bloc.dart';
import 'package:oluko_app/blocs/story_list_bloc.dart';
import 'package:oluko_app/blocs/subscribed_course_users_bloc.dart';
import 'package:oluko_app/blocs/user_progress_list_bloc.dart';
import 'package:oluko_app/blocs/user_progress_stream_bloc.dart';
import 'package:oluko_app/blocs/user_statistics_bloc.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/helpers/enum_collection.dart';
import 'package:oluko_app/helpers/user_helper.dart';
import 'package:oluko_app/models/dto/user_progress.dart';
import 'package:oluko_app/models/user_response.dart';
import 'package:oluko_app/ui/components/black_app_bar.dart';
import 'package:oluko_app/ui/components/friend_modal_content.dart';
import 'package:oluko_app/ui/components/stories_item.dart';
import 'package:oluko_app/ui/components/title_body.dart';
import 'package:oluko_app/utils/bottom_dialog_utils.dart';
import 'package:oluko_app/utils/oluko_localizations.dart';
import 'package:oluko_app/utils/screen_utils.dart';
import 'package:oluko_app/utils/user_utils.dart';

class ExploreSubscribedUsers extends StatefulWidget {
  String courseId;
  ExploreSubscribedUsers({this.courseId});

  @override
  _ExploreSubscribedUsersState createState() => _ExploreSubscribedUsersState();
}

class _ExploreSubscribedUsersState extends State<ExploreSubscribedUsers> {
  List<UserResponse> allEnrolledUsers;
  AuthSuccess loggedUser;
  Map<String, UserProgress> _usersProgress = {};

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(builder: (context, authState) {
      if (authState is AuthSuccess && loggedUser == null && allEnrolledUsers == null) {
        loggedUser = authState;
        BlocProvider.of<UserProgressListBloc>(context).get(authState.user.id);
        BlocProvider.of<SubscribedCourseUsersBloc>(context).get(widget.courseId, loggedUser.user.id);
      }
      return Scaffold(
        backgroundColor: OlukoNeumorphism.isNeumorphismDesign ? OlukoNeumorphismColors.olukoNeumorphicBackgroundDark : OlukoColors.black,
        appBar: OlukoAppBar(),
        body: SizedBox(
          height: ScreenUtils.height(context),
          width: ScreenUtils.width(context),
          child: ListView(addAutomaticKeepAlives: false, addRepaintBoundaries: false, children: [
            Padding(
                padding: const EdgeInsets.all(16.0),
                child: BlocConsumer<UserProgressListBloc, UserProgressListState>(listener: (context, userProgressListState) {
                  if (userProgressListState is GetUserProgressSuccess) {
                    setState(() {
                      _usersProgress = userProgressListState.usersProgress;
                    });
                  }
                }, builder: (context, userProgressListState) {
                  return body();
                })),
          ]),
        ),
      );
    });
  }

  Widget body() {
    return Container(
      child: BlocBuilder<SubscribedCourseUsersBloc, SubscribedCourseUsersState>(builder: (context, subscribedCourseUsersState) {
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: Row(
                children: [
                  TitleBody(OlukoLocalizations.get(context, "favorites")),
                ],
              ),
            ),
            if (subscribedCourseUsersState is SubscribedCourseUsersSuccess)
              BlocListener<UserProgressStreamBloc, UserProgressStreamState>(
                  listener: (context, userProgressStreamState) {
                    blocConsumerCondition(userProgressStreamState);
                  },
                  child: usersGrid(subscribedCourseUsersState.favoriteUsers, true))
            else
              const SizedBox(),
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: Row(
                children: [
                  TitleBody(OlukoLocalizations.get(context, "everyoneElse")),
                ],
              ),
            ),
            subscribedCourseUsersState is SubscribedCourseUsersSuccess ? usersGrid(subscribedCourseUsersState.users, false) : SizedBox()
          ],
        );
      }),
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

  Widget usersGrid(List<UserResponse> users, bool areFriends) {
    if (users.isNotEmpty) {
      return GridView.count(
          childAspectRatio: 0.6,
          crossAxisCount: 4,
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          children: users
              .map((user) => GestureDetector(
                    onTap: () => showFriendModal(user),
                    child: Column(
                      children: [
                        if (areFriends)
                          StoriesItem(
                            showUserProgress: true,
                            userProgress: _usersProgress[user.id],
                            maxRadius: 30,
                            imageUrl: user.getAvatarThumbnail(),
                            bloc: BlocProvider.of<StoryListBloc>(context),
                            getStories: true,
                            itemUserId: user.id,
                            currentUserId: loggedUser.user.id,
                            name: user.firstName,
                            from: StoriesItemFrom.friends,
                            userProgressStreamBloc: BlocProvider.of<UserProgressStreamBloc>(context),
                          )
                        else
                          StoriesItem(
                            showUserProgress: true,
                            userProgress: _usersProgress[user.id],
                            itemUserId: user.id,
                            userProgressStreamBloc: BlocProvider.of<UserProgressStreamBloc>(context),
                            maxRadius: 30,
                            imageUrl: user.getAvatarThumbnail(),
                            name: user.firstName,
                          ),
                        Padding(
                          padding: const EdgeInsets.only(top: 5.0, bottom: 0.0),
                          child: Text(
                            user.firstName != null && user.lastName != null && user.firstName.isNotEmpty && user.lastName.isNotEmpty ? user.getFullName() : '',
                            style: OlukoFonts.olukoMediumFont(),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        Text(
                          user.username != null && user.username.isNotEmpty ? UserHelper.printUsername(user.username, user.id) : '',
                          style: OlukoFonts.olukoSmallFont(
                            customColor: Colors.grey,
                          ),
                          textAlign: TextAlign.center,
                        )
                      ],
                    ),
                  ))
              .toList());
    } else {
      return Padding(
        padding: const EdgeInsets.only(bottom: 20, top: 10),
        child: TitleBody(OlukoLocalizations.get(context, 'noUsers')),
      );
    }
  }

  showFriendModal(UserResponse friendUser) {
    BottomDialogUtils.friendsModal(friendUser, loggedUser.user.id, _usersProgress, context);
  }
}
