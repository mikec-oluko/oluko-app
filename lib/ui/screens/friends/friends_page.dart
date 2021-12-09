import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:oluko_app/blocs/friends/confirm_friend_bloc.dart';
import 'package:oluko_app/blocs/friends/friend_bloc.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/helpers/page_content.dart';
import 'package:oluko_app/ui/components/black_app_bar.dart';
import 'package:oluko_app/ui/components/bottom_navigation_bar.dart';
import 'package:oluko_app/ui/screens/friends/friends_list_page.dart';
import 'package:oluko_app/ui/screens/friends/friends_requests_page.dart';
import 'package:oluko_app/utils/app_navigator.dart';

class FriendsPage extends StatefulWidget {
  @override
  _FriendsPageState createState() => _FriendsPageState();
}

class _FriendsPageState extends State<FriendsPage> with SingleTickerProviderStateMixin {
  TabController _tabController;
  int _activeTabIndex;
  List<Widget> _pages = [FriendsListPage(), FriendsRequestPage()];
  final String _title = "Friends";

  @override
  void initState() {
    _tabController = TabController(length: _pages.length, vsync: this);
    super.initState();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _setActiveTabIndex({int value}) {
    setState(() {
      _activeTabIndex = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: OlukoAppBar(
        showBackButton: false,
        title: _title,
        showTitle: true,
      ),
      body: Container(
        color: OlukoNeumorphism.isNeumorphismDesign ? OlukoNeumorphismColors.olukoNeumorphicBackgroundDark : OlukoColors.black,
        child: WillPopScope(
          onWillPop: () => AppNavigator.onWillPop(context),
          child: Stack(
            children: [
              Column(
                children: [
                  Padding(
                    padding: OlukoNeumorphism.isNeumorphismDesign
                        ? const EdgeInsets.symmetric(horizontal: 5, vertical: 20)
                        : const EdgeInsets.symmetric(horizontal: 5),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 5),
                      child: OlukoNeumorphism.isNeumorphismDesign ? neumoprhicTabs() : defaultTabs(),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      color:
                          OlukoNeumorphism.isNeumorphismDesign ? OlukoNeumorphismColors.olukoNeumorphicBackgroundDark : OlukoColors.black,
                      child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: TabBarView(
                            controller: _tabController,
                            children: _pages,
                          )),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Neumorphic neumoprhicTabs() {
    return Neumorphic(
      style: const NeumorphicStyle(
          shape: NeumorphicShape.flat,
          boxShape: NeumorphicBoxShape.stadium(),
          depth: 5,
          intensity: 0.35,
          border: NeumorphicBorder(width: 1.5, color: OlukoNeumorphismColors.olukoNeumorphicBackgroundDark),
          color: OlukoNeumorphismColors.olukoNeumorphicBackgroundDark,
          lightSource: LightSource.topLeft,
          shadowDarkColorEmboss: Colors.black,
          shadowLightColorEmboss: OlukoNeumorphismColors.olukoNeumorphicBackgroundLigth,
          surfaceIntensity: 1,
          shadowLightColor: Colors.white,
          shadowDarkColor: Colors.black),
      child: friendsTabs(),
    );
  }

  Widget defaultTabs() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
        color: OlukoColors.grayColor,
      ),
      child: friendsTabs(),
    );
  }

  Row friendsTabs() {
    return Row(
      children: [
        Expanded(
          child: TabBar(
            onTap: (int value) {
              _setActiveTabIndex(value: value);
            },
            labelPadding: EdgeInsets.all(0),
            indicatorColor: OlukoColors.grayColor,
            indicator: BoxDecoration(
                borderRadius: _activeTabIndex == 0
                    ? BorderRadius.only(topLeft: Radius.circular(5), bottomLeft: Radius.circular(5))
                    : BorderRadius.only(topRight: Radius.circular(5), bottomRight: Radius.circular(5)),
                color: OlukoColors.primary),
            unselectedLabelColor: OlukoColors.white,
            labelColor: OlukoColors.white,
            controller: _tabController,
            tabs: [Tab(text: 'Friends'), Tab(text: 'Requests')],
          ),
          // Tab(text: 'Friends'), Tab(text: 'Requests')
        ),
      ],
    );
  }
}
