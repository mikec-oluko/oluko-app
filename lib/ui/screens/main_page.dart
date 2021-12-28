import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oluko_app/blocs/auth_bloc.dart';
import 'package:oluko_app/blocs/views_bloc/hi_five_bloc.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/ui/components/bottom_navigation_bar.dart';
import 'package:oluko_app/ui/screens/coach/coach_page.dart';
import 'package:oluko_app/ui/screens/courses/courses.dart';
import 'package:oluko_app/ui/screens/friends/friends_page.dart';
import 'package:oluko_app/ui/screens/home.dart';
import 'package:oluko_app/ui/screens/profile/profile.dart';

import 'coach/coach_main_page.dart';
import 'coach/coach_no_assigned_timer_page.dart';

class MainPage extends StatefulWidget {
  MainPage({this.classIndex, this.index, this.tab, Key key}) : super(key: key);

  final int index;
  final int classIndex;
  int tab;

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> with SingleTickerProviderStateMixin {
  List<Widget> tabs = [
    /*
    //MyHomePage(),
    //TODO:Change to Home() when finished
    Home(),
    //Reserved for Coach Section
    // Container(
    //   color: Colors.black,
    //   child: Center(
    //     child: Text(
    //       'COACH SECTION',
    //       style: OlukoFonts.olukoBigFont(),
    //     ),
    //   ),
    // ),
    // ----
    // CoachPage(),
    CoachMainPage(),
    FriendsPage(),
    Courses(),
    ProfilePage()*/
  ];
  TabController tabController;

  List<Widget> getTabs() {
    return [getHomeTab(), CoachMainPage(), FriendsPage(), Courses(), ProfilePage()];
  }

  Widget getHomeTab() {
    if (widget.classIndex != null && widget.index != null) {
      return Home(index: widget.index, classIndex: widget.classIndex);
    } else if (widget.index != null) {
      return Home(index: widget.index);
    } else {
      return Home();
    }
  }

  @override
  void initState() {
    tabs = getTabs();
    tabController = TabController(length: this.tabs.length, vsync: this);
    super.initState();
    tabController.addListener(() {
      this.setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.tab != null) {
      this.tabController.index = widget.tab;
      tabController.animateTo(widget.tab);
      widget.tab = null;
    }
    return Scaffold(
      body: BlocBuilder<AuthBloc, AuthState>(builder: (context, authState) {
        if (authState is AuthSuccess) {
          BlocProvider.of<HiFiveBloc>(context).get(authState.user.id);
        }
        return Padding(
          padding: const EdgeInsets.only(bottom: 75),
          child: TabBarView(
            controller: this.tabController,
            children: tabs,
          ),
        );
      }),
      extendBody: true,
      bottomNavigationBar: OlukoBottomNavigationBar(
        selectedIndex: this.tabController.index,
        onPressed: (index) => this.setState(() {
          this.tabController.animateTo(index as int);
        }),
      ),
    );
  }
}
