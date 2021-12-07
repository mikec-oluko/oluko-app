import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
        color: OlukoColors.black,
        child: WillPopScope(
          onWillPop: () => AppNavigator.onWillPop(context),
          child: Stack(
            children: [
              Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 5),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 5),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          color: OlukoColors.grayColor,
                        ),
                        child: Row(
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
                                labelColor: OlukoColors.black,
                                controller: _tabController,
                                tabs: [Tab(text: 'Friends'), Tab(text: 'Requests')],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      color: OlukoColors.black,
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
}
