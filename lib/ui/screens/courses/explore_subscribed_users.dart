import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oluko_app/blocs/auth_bloc.dart';
import 'package:oluko_app/blocs/story_list_bloc.dart';
import 'package:oluko_app/blocs/subscribed_course_users_bloc.dart';
import 'package:oluko_app/helpers/enum_collection.dart';
import 'package:oluko_app/models/user_response.dart';
import 'package:oluko_app/ui/components/black_app_bar.dart';
import 'package:oluko_app/ui/components/stories_item.dart';
import 'package:oluko_app/ui/components/title_body.dart';
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

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(builder: (context, authState) {
      if (authState is AuthSuccess && loggedUser == null && allEnrolledUsers == null) {
        loggedUser = authState;
        BlocProvider.of<SubscribedCourseUsersBloc>(context).get(widget.courseId, loggedUser.user.id);
      }
      return Scaffold(
        backgroundColor: Colors.black,
        appBar: _appBar(),
        body: Container(
          height: ScreenUtils.height(context),
          width: ScreenUtils.width(context),
          child: ListView(children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                child: BlocBuilder<SubscribedCourseUsersBloc, SubscribedCourseUsersState>(builder: (context, subscribedCourseUsersState) {
                  return Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: Row(
                          children: [
                            TitleBody(OlukoLocalizations.get(context, "favourites")),
                          ],
                        ),
                      ),
                      if (subscribedCourseUsersState is SubscribedCourseUsersSuccess)
                        usersGrid(subscribedCourseUsersState.favoriteUsers, true)
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
                      subscribedCourseUsersState is SubscribedCourseUsersSuccess
                          ? usersGrid(subscribedCourseUsersState.users, false)
                          : SizedBox()
                    ],
                  );
                }),
              ),
            ),
          ]),
        ),
      );
    });
  }

  PreferredSizeWidget _appBar() {
    return OlukoAppBar(
      showBackButton: true,
      title: ' ',
      showSearchBar: false,
    );
  }

  Widget usersGrid(List<UserResponse> users, bool areFriends) {
    if (users.isNotEmpty) {
      return GridView.count(
          childAspectRatio: 0.7,
          crossAxisCount: 4,
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          children: users
              .map((user) => Column(
                    children: [
                      if (areFriends)
                        StoriesItem(
                          maxRadius: 30,
                          imageUrl: user.avatarThumbnail ?? UserUtils().defaultAvatarImageUrl,
                          bloc: StoryListBloc(),
                          getStories: true,
                          itemUserId: user.id,
                          currentUserId: loggedUser.user.id,
                          name: user.firstName,
                          from: StoriesItemFrom.friends,
                        )
                      else
                        StoriesItem(
                          maxRadius: 30,
                          imageUrl: user.avatarThumbnail ?? UserUtils().defaultAvatarImageUrl,
                        ),
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0, bottom: 0.0),
                        child: Text(
                          user.firstName != null && user.lastName != null && user.firstName.isNotEmpty && user.lastName.isNotEmpty
                              ? '${user.firstName} ${user.lastName}'
                              : '',
                          style: const TextStyle(color: Colors.white, fontSize: 13),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      Text(
                        user.username != null && user.username.isNotEmpty ? user.username : '',
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
