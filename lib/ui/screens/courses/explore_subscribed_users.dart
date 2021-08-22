import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:oluko_app/ui/components/black_app_bar.dart';
import 'package:oluko_app/utils/screen_utils.dart';

class ExploreSubscribedUsers extends StatefulWidget {
  String courseId;
  ExploreSubscribedUsers({this.courseId});

  @override
  _ExploreSubscribedUsersState createState() => _ExploreSubscribedUsersState();
}

class _ExploreSubscribedUsersState extends State<ExploreSubscribedUsers> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: _appBar(),
      body: Container(
        height: ScreenUtils.height(context),
        width: ScreenUtils.width(context),
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
}
