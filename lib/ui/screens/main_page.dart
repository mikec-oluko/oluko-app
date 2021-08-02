import 'package:flutter/material.dart';
import 'package:oluko_app/constants/Theme.dart';
import 'package:oluko_app/ui/components/bottom_navigation_bar.dart';
import 'package:oluko_app/ui/screens/courses/courses.dart';
import 'package:oluko_app/ui/screens/friends/friends_page.dart';
import 'package:oluko_app/ui/screens/home.dart';
import 'package:oluko_app/ui/screens/home_page.dart';
import 'package:oluko_app/ui/screens/profile/profile.dart';

class MainPage extends StatefulWidget {
  MainPage({Key key}) : super(key: key);

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage>
    with SingleTickerProviderStateMixin {
  List<Widget> tabs = [
    Home(),
    //Reserved for Coach Section
    Container(
      color: Colors.black,
      child: Center(
        child: Text(
          'COACH SECTION',
          style: OlukoFonts.olukoBigFont(),
        ),
      ),
    ),
    // ----
    FriendsPage(),
    Courses(),
    ProfilePage()
  ];
  TabController tabController;

  @override
  void initState() {
    tabController = TabController(length: this.tabs.length, vsync: this);
    super.initState();
    tabController.addListener(() {
      this.setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: TabBarView(
        controller: this.tabController,
        children: tabs,
      ),
      bottomNavigationBar: OlukoBottomNavigationBar(
        selectedIndex: this.tabController.index,
        onPressed: (index) => this.setState(() {
          this.tabController.animateTo(index);
        }),
      ),
    );
  }
}
