import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oluko_app/blocs/subscribed_course_users_bloc.dart';
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
  List<String> storiesItem = const [
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
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: _appBar(),
      body: Container(
        height: ScreenUtils.height(context),
        width: ScreenUtils.width(context),
        child: Padding(
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
                  usersGrid(),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: Row(
                      children: [
                        TitleBody('Everyone else'),
                      ],
                    ),
                  ),
                  subscribedCourseUsersState is SubscribedCourseUsersSuccess
                      ? usersGrid()
                      : SizedBox()
                ],
              );
            }),
          ),
        ),
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

  Widget usersGrid() {
    return GridView.count(
        childAspectRatio: 0.8,
        crossAxisCount: 4,
        shrinkWrap: true,
        children: storiesItem
            .map((e) => Column(
                  children: [
                    StoriesItem(
                      maxRadius: 30,
                      imageUrl: e,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0, bottom: 0.0),
                      child: Text(
                        'Joaquin Piñeiro',
                        style: TextStyle(color: Colors.white, fontSize: 13),
                      ),
                    ),
                    Text(
                      'Username',
                      style: TextStyle(color: Colors.grey, fontSize: 10),
                    )
                  ],
                ))
            .toList());
  }
}
