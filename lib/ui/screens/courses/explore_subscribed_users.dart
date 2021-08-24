import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oluko_app/blocs/subscribed_course_users_bloc.dart';
import 'package:oluko_app/models/user_response.dart';
import 'package:oluko_app/ui/components/black_app_bar.dart';
import 'package:oluko_app/ui/components/stories_item.dart';
import 'package:oluko_app/ui/components/title_body.dart';
import 'package:oluko_app/utils/screen_utils.dart';

class ExploreSubscribedUsers extends StatefulWidget {
  String courseId;
  ExploreSubscribedUsers({this.courseId});

  @override
  _ExploreSubscribedUsersState createState() => _ExploreSubscribedUsersState();
}

class _ExploreSubscribedUsersState extends State<ExploreSubscribedUsers> {
  List<UserResponse> allEnrolledUsers;

  @override
  Widget build(BuildContext context) {
    if (allEnrolledUsers == null) {
      BlocProvider.of<SubscribedCourseUsersBloc>(context).get(widget.courseId);
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
              child: BlocBuilder<SubscribedCourseUsersBloc,
                      SubscribedCourseUsersState>(
                  builder: (context, subscribedCourseUsersState) {
                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: Row(
                        children: [
                          TitleBody('Favourites'),
                        ],
                      ),
                    ),
                    subscribedCourseUsersState is SubscribedCourseUsersSuccess
                        ? usersGrid(subscribedCourseUsersState.users)
                        : SizedBox(),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: Row(
                        children: [
                          TitleBody('Everyone else'),
                        ],
                      ),
                    ),
                    subscribedCourseUsersState is SubscribedCourseUsersSuccess
                        ? usersGrid(subscribedCourseUsersState.users)
                        : SizedBox()
                  ],
                );
              }),
            ),
          ),
        ]),
      ),
    );
  }

  Widget _appBar() {
    return OlukoAppBar(
      showBackButton: true,
      title: ' ',
      showSearchBar: false,
    );
  }

  Widget usersGrid(List<UserResponse> users) {
    return GridView.count(
        childAspectRatio: 0.8,
        crossAxisCount: 4,
        physics: new NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        children: users
            .map((user) => Column(
                  children: [
                    StoriesItem(
                      maxRadius: 30,
                      imageUrl: user.avatar != null
                          ? user.avatar
                          : 'https://firebasestorage.googleapis.com/v0/b/oluko-development.appspot.com/o/avatar.png?alt=media&token=c16925c3-e2be-47fb-9d15-8cd1469d9790',
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
            .toList());
  }
}
