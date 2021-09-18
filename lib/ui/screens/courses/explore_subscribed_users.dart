import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oluko_app/blocs/auth_bloc.dart';
import 'package:oluko_app/blocs/subscribed_course_users_bloc.dart';
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
                            TitleBody(OlukoLocalizations.of(context).find("favourites")),
                          ],
                        ),
                      ),
                      subscribedCourseUsersState is SubscribedCourseUsersSuccess
                          ? usersGrid(subscribedCourseUsersState.favoriteUsers)
                          : SizedBox(),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: Row(
                          children: [
                            TitleBody(OlukoLocalizations.of(context).find("everyoneElse")),
                          ],
                        ),
                      ),
                      subscribedCourseUsersState is SubscribedCourseUsersSuccess ? usersGrid(subscribedCourseUsersState.users) : SizedBox()
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

  Widget usersGrid(List<UserResponse> users) {
    return users.length > 0
        ? GridView.count(
            childAspectRatio: 0.7,
            crossAxisCount: 4,
            physics: new NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            children: users
                .map((user) => Column(
                      children: [
                        StoriesItem(
                          maxRadius: 30,
                          imageUrl: user.avatar != null ? user.avatar : UserUtils().defaultAvatarImageUrl,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0, bottom: 0.0),
                          child: Text(
                            '${user.firstName} ${user.lastName}',
                            style: TextStyle(color: Colors.white, fontSize: 13),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        Text(
                          '${user.username}',
                          style: TextStyle(color: Colors.grey, fontSize: 10),
                          textAlign: TextAlign.center,
                        )
                      ],
                    ))
                .toList())
        : Padding(
            padding: EdgeInsets.only(bottom: 20, top: 10),
            child: TitleBody(OlukoLocalizations.of(context).find("noUsers")),
          );
  }
}
